```bash
## DHCP部分
/etc/dhcp/dhcpd.conf（添加）:

subnet 192.168.42.0 netmask 255.255.255.0 {
    range 192.168.42.50 192.168.42.150;
    
    option routers 192.168.42.1;

    host host1 {
        hardware ethernet 05:42:c0:a8:00:03;
        fixed-address 192.168.42.100;
    }
}

## DNS部分
/etc/named.conf（添加）：
zone "test-louplus.com" IN {
    type master;
    file "test-louplus.zone";
};

zone "42.168.192.in-addr.arpa" IN {
    type master;
    file "42.168.192.zone";
};

## 正向解析zone文件
vi /var/named/test-louplus.zone

@ SOA dns.test-louplus.com. admin.test-louplus.com.(
    2018102701
    21600
    3600
    604800
    86400
)

@ IN NS dns

@ IN MX 10 mail.test-louplus.com.

dns  IN  A 192.168.42.103
mail IN  A 192.168.42.100
nfs  IN  A 192.168.42.102
dev  IN  A 192.168.42.101
##注意com后的"."，别丢，代表根域

## 反向解析zone文件
vi /var/named/42.168.192.zone

@ SOA dns.test-louplus.com. admin.test-louplus.com.(
    2018102701
    21600
    3600
    604800
    86400
    )

    IN NS dns.test-louplus.com.

100 IN PTR mail.test-louplus.com.
101 IN PTR dev.test-louplus.com.
102 IN PTR nfs.test-louplus.com.
103 IN PTR dns.test-louplus.com.

## 配置本机dns服务
编辑 /etc/resolv.conf：
nameserver 127.0.0.1

```

