[lb]
%{ for ip in haproxy ~}
${ip}
%{ endfor ~}

[workers]
%{ for ip in workers_public ~}
${ip}
%{ endfor ~}