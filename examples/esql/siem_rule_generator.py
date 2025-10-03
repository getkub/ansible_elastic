#!/usr/bin/env python3
"""
SIEM Rule Generator - Python Fallback
Use this only if Ansible approach has limitations for your use case
"""

import csv
import yaml
import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from typing import Dict, Any, Optional


def load_metadata(csv_path: str) -> Dict[str, Dict[str, str]]:
    """Load metadata from CSV file"""
    metadata = {}
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            metadata[row['uc_id']] = row
    return metadata


def load_priority_mappings(csv_path: str) -> Dict[str, Dict[str, str]]:
    """Load priority mappings from CSV file"""
    priority_map = {}
    try:
        with open(csv_path, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                priority_map[row['object_name']] = row
    except FileNotFoundError:
        print(f"Priority file {csv_path} not found, using default priority")
    return priority_map


def load_rule_yaml(yaml_path: str) -> Dict[str, Any]:
    """Load rule definition from YAML file"""
    with open(yaml_path, 'r') as f:
        return yaml.safe_load(f)


def calculate_risk_score(severity: int, priority: int = 4) -> int:
    """Calculate risk score as severity * priority"""
    return severity * priority


def get_priority(object_name: str, priority_map: Dict, default: int = 4) -> int:
    """Get priority for an object, returning default if not found"""
    if object_name in priority_map:
        try:
            return int(priority_map[object_name]['priority'])
        except (ValueError, KeyError):
            return default
    return default


def calculate_severity_string(severity_score: int) -> str:
    """Calculate severity string from numeric score"""
    if severity_score <= 3:
        return "low"
    elif severity_score <= 6:
        return "medium"
    elif severity_score <= 8:
        return "high"
    else:
        return "critical"


def generate_rule(meta: Dict[str, str], rule: Dict[str, Any], 
                  priority_map: Dict, default_priority: int,
                  template_env: Environment) -> str:
    """Generate final rule JSON using Jinja2 template"""
    
    # Calculate base risk score with default priority
    severity = int(meta['uc_severity'])
    base_risk_score = calculate_risk_score(severity, default_priority)
    
    # Prepare template variables
    template_vars = {
        'meta': meta,
        'rule': rule,
        'priority_map': priority_map,
        'default_priority': default_priority,
        'base_risk_score': base_risk_score
    }
    
    # Load and render template
    template = template_env.get_template('rule_template.json.j2')
    return template.render(template_vars)


def main():
    # Configuration
    META_CSV = 'meta.rules.csv'
    PRIORITY_CSV = 'priority.csv'
    RULES_DIR = '.'
    OUTPUT_DIR = 'output'
    TEMPLATE_DIR = '.'
    DEFAULT_PRIORITY = 4
    
    # Create output directory if it doesn't exist
    Path(OUTPUT_DIR).mkdir(exist_ok=True)
    
    # Setup Jinja2 environment
    env = Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        trim_blocks=True,
        lstrip_blocks=True
    )
    
    # Load metadata
    print(f"Loading metadata from {META_CSV}...")
    metadata = load_metadata(META_CSV)
    print(f"Loaded {len(metadata)} rule metadata entries")
    
    # Load priority mappings
    print(f"Loading priority mappings from {PRIORITY_CSV}...")
    priority_map = load_priority_mappings(PRIORITY_CSV)
    if priority_map:
        print(f"Loaded {len(priority_map)} priority mappings")
    else:
        print(f"Using default priority: {DEFAULT_PRIORITY}")
    
    # Process each rule
    for uc_id, meta in metadata.items():
        rule_yaml_path = Path(RULES_DIR) / f"{uc_id}.yml"
        
        if not rule_yaml_path.exists():
            print(f"Warning: Rule file not found for {uc_id}, skipping...")
            continue
        
        print(f"Processing {uc_id}...")
        
        # Load rule YAML
        rule = load_rule_yaml(str(rule_yaml_path))
        
        # Generate final rule JSON
        output_json = generate_rule(meta, rule, priority_map, 
                                   DEFAULT_PRIORITY, env)
        
        # Write output file
        output_path = Path(OUTPUT_DIR) / f"{uc_id}.json"
        with open(output_path, 'w') as f:
            # Parse and re-dump to ensure valid JSON formatting
            json_obj = json.loads(output_json)
            json.dump(json_obj, f, indent=4)
        
        severity = int(meta['uc_severity'])
        risk_score = calculate_risk_score(severity, DEFAULT_PRIORITY)
        print(f"  Generated: {output_path} (severity={severity}, "
              f"base_risk_score={risk_score})")
    
    print("\n" + "="*60)
    print("Rule generation complete!")
    print(f"Output directory: {OUTPUT_DIR}/")
    print("="*60)


if __name__ == "__main__":
    main()
