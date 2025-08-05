#!/usr/bin/env python3
"""
Hidrologger Ağ Tarama Scripti
Aynı WiFi ağındaki Hidrologger sunucusunu bulur
"""

import requests
import socket
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

def scan_ip(ip, port=8765, timeout=2):
    """Belirli bir IP'de Hidrologger sunucusunu ara"""
    try:
        url = f"http://{ip}:{port}/api/health"
        response = requests.get(url, timeout=timeout)
        if response.status_code == 200:
            data = response.json()
            if data.get('success') and data.get('server') == 'Hidrologger RESTful API':
                return ip, True, data
        return ip, False, None
    except requests.exceptions.ConnectTimeout:
        return ip, False, "Timeout"
    except requests.exceptions.ConnectionError:
        return ip, False, "Connection Error"
    except Exception as e:
        return ip, False, str(e)

def get_local_ip():
    """Yerel IP adresini al"""
    try:
        # Google DNS'e bağlanarak yerel IP'yi öğren
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        # Fallback IP'ler - farklı ağlar için
        fallback_ips = ["172.20.10.3", "192.168.1.100", "10.0.0.100"]
        return fallback_ips[0]

def scan_network():
    """Ağı tara"""
    local_ip = get_local_ip()
    print(f"🔍 Yerel IP: {local_ip}")
    
    # Subnet'i çıkar
    subnet = '.'.join(local_ip.split('.')[:-1])
    print(f"📡 Ağ taraması başlatılıyor: {subnet}.0/24")
    
    # Test edilecek IP'ler
    test_ips = []
    
    # Yerel IP'nin etrafındaki IP'ler
    local_last_octet = int(local_ip.split('.')[-1])
    for i in range(max(1, local_last_octet - 10), min(255, local_last_octet + 10)):
        test_ips.append(f"{subnet}.{i}")
    
    # Önemli IP'ler
    important_ips = [
        f"{subnet}.1",    # Router
        f"{subnet}.100",  # Yaygın DHCP aralığı
        f"{subnet}.200",  # Yaygın DHCP aralığı
        local_ip,         # Yerel IP
    ]
    
    # Önemli IP'leri başa ekle
    for ip in important_ips:
        if ip not in test_ips:
            test_ips.insert(0, ip)
    
    print(f"🎯 {len(test_ips)} IP adresi test edilecek")
    
    found_servers = []
    
    # Paralel tarama
    with ThreadPoolExecutor(max_workers=20) as executor:
        future_to_ip = {executor.submit(scan_ip, ip): ip for ip in test_ips}
        
        for future in as_completed(future_to_ip):
            ip, found, data = future.result()
            if found:
                found_servers.append((ip, data))
                print(f"✅ Sunucu bulundu: {ip}")
                print(f"   📊 Durum: {data.get('status', 'N/A')}")
                print(f"   🕐 Timestamp: {data.get('timestamp', 'N/A')}")
            else:
                print(f"❌ {ip}: Bağlantı yok")
    
    return found_servers

if __name__ == "__main__":
    print("🚀 Hidrologger Ağ Tarayıcısı")
    print("=" * 40)
    
    start_time = time.time()
    servers = scan_network()
    end_time = time.time()
    
    print("\n" + "=" * 40)
    print(f"⏱️  Tarama süresi: {end_time - start_time:.2f} saniye")
    
    if servers:
        print(f"\n🎉 {len(servers)} sunucu bulundu:")
        for ip, data in servers:
            print(f"   🌐 {ip}:8765")
            print(f"   📊 {data.get('server', 'N/A')}")
    else:
        print("\n❌ Hiçbir Hidrologger sunucusu bulunamadı")
        print("💡 Kontrol edilecekler:")
        print("   - Python sunucusu çalışıyor mu?")
        print("   - Firewall ayarları")
        print("   - Aynı WiFi ağında mısınız?")
    
    print("\n📱 Flutter uygulamasında bu IP'leri kullanabilirsiniz!") 