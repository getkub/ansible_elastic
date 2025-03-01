# Elastic Stack Setup using Vagrant with VirtualBox

## Recommended Approach: Vagrant with VirtualBox

Given the need for **2 Linux hosts, 2 Windows hosts, and a full Elastic stack** (Fleet Server, Elasticsearch, Kibana), Vagrant with VirtualBox is the best choice because:

- Supports full **Linux and Windows VMs**, allowing **Elastic Agent** to run with **admin/root privileges**.
- Simulates a **distributed system** with separate "machines".
- Works natively on **macOS** with VirtualBox (**free**) or Parallels (**paid, faster on Apple Silicon**).

> **Note:** Docker and Kubernetes are lighter but can’t easily handle Windows hosts or fully replicate Elastic Agent’s host-level behavior (e.g., EDR requiring kernel access).

---

## Step-by-Step Vagrant Setup

### **Prerequisites**
#### **Hardware Requirements:**
- **MacBook**: **16 GB RAM recommended** (8 GB minimum, but expect slowdowns).
- **Disk Space**: ~**20-30 GB** for VMs (**Windows images are larger**).

#### **Software Requirements:**
- **Install VirtualBox** (Free, works on Intel and Apple Silicon via Rosetta).
- **Install Vagrant** (Run `brew install vagrant` on macOS).
- **Optional**: **Parallels Desktop** (if you prefer, requires a Vagrant plugin purchase).

---

## **1. Define the Vagrantfile**

Create a `Vagrantfile` in a project directory (e.g., `~/elastic-distributed`):

```ruby
Vagrant.configure("2") do |config|
  # Define 2 Linux hosts (Ubuntu 22.04)
  (1..2).each do |i|
    config.vm.define "linux#{i}" do |linux|
      linux.vm.box = "ubuntu/jammy64"
      linux.vm.hostname = "linux#{i}"
      linux.vm.network "private_network", ip: "192.168.56.#{10+i}"
      linux.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"  # 2 GB RAM
        vb.cpus = 1
      end
    end
  end

  # Define 2 Windows hosts (Windows Server 2022 trial)
  (1..2).each do |i|
    config.vm.define "windows#{i}" do |win|
      win.vm.box = "gusztavvargadr/windows-server"
      win.vm.hostname = "windows#{i}"
      win.vm.network "private_network", ip: "192.168.56.#{20+i}"
      win.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"  # 4 GB RAM (Windows is heavier)
        vb.cpus = 2
      end
      win.vm.communicator = "winrm"  # Use WinRM for Windows
      win.winrm.username = "vagrant"
      win.winrm.password = "vagrant"
    end
  end

  # Fleet Server, Elasticsearch, Kibana (Ubuntu 22.04)
  config.vm.define "elastic-stack" do |elastic|
    elastic.vm.box = "ubuntu/jammy64"
    elastic.vm.hostname = "elastic-stack"
    elastic.vm.network "private_network", ip: "192.168.56.100"
    elastic.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"  # 4 GB for Elastic Stack
      vb.cpus = 2
    end
  end
end
```

### **Notes:**
- **IPs** are in the `192.168.56.0/24` range for a private network.
- Adjust **RAM/CPU** based on your MacBook’s capacity (**e.g., 1 GB Linux, 2 GB Windows if 8 GB total**).
- **Windows box is a trial**; replace with your own **licensed box** if needed.

---

## **2. Start the VMs**

```bash
cd ~/elastic-distributed
vagrant up
```

- This provisions **5 VMs**: **2 Linux, 2 Windows, 1 Elastic Stack host**.
- Takes **~10-20 minutes** depending on internet speed and CPU power.

---

## **3. Install Elastic Stack on Elastic-Stack VM**

SSH into the **Elastic Stack VM**:

```bash
vagrant ssh elastic-stack
```

#### **Install Elasticsearch, Kibana, and Fleet Server:**
```bash
sudo apt update
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update
sudo apt install elasticsearch kibana -y
```

#### **Install Elastic Agent as Fleet Server:**
```bash
sudo apt install elastic-agent -y
sudo elastic-agent install --url=https://192.168.56.100:8220 --enrollment-token=<token-from-kibana>
```

- **Configure Elasticsearch** (`/etc/elasticsearch/elasticsearch.yml`) and **Kibana** (`/etc/kibana/kibana.yml`) with basic settings (**e.g., `network.host: 0.0.0.0`**).

- Start services:
```bash
sudo systemctl start elasticsearch kibana
```

---

## **4. Install Elastic Agent on Linux Hosts**

SSH into each **Linux VM**:

```bash
vagrant ssh linux1
```

Run:
```bash
sudo apt update
sudo apt install elastic-agent -y
sudo elastic-agent install --url=https://192.168.56.100:8220 --enrollment-token=<token-from-kibana>
```

> Requires **root access**.

---

## **5. Install Elastic Agent on Windows Hosts**

Use **RDP** or **Vagrant WinRM**:
```bash
vagrant winrm windows1
```

Download the **Elastic Agent installer** manually (ZIP from Elastic’s site).
Run in **elevated PowerShell**:

```powershell
.\elastic-agent.exe install --url=https://192.168.56.100:8220 --enrollment-token=<token-from-kibana>
```

> Requires **admin privileges**.

---

## **6. Configure Fleet and Verify**

1. **Access Kibana** at `http://192.168.56.100:5601` from your MacBook.
2. **Set up Fleet** in Kibana.
3. **Add the Elastic Defend integration** to policies.
4. **Assign policies to agents**.
5. **Check Fleet > Agents** to see all **4 hosts reporting**.

---

## **Resource Check**
| Resource  | Allocation |
|-----------|-----------|
| **RAM**   | Linux (4 GB) + Windows (8 GB) + Elastic Stack (4 GB) = **16 GB Total** |
| **CPU**   | 6-8 cores total (adjust as needed) |
| **Storage** | ~20-30 GB required |

> **If you have only 8 GB RAM**, reduce allocation:
> - **1 GB/Linux VM**
> - **2 GB/Windows VM**
> - **2 GB/Elastic Stack VM**

---

## **Conclusion**
This guide sets up a **distributed ELK Stack environment** with Windows and Linux hosts using **Vagrant & VirtualBox**. 🚀

