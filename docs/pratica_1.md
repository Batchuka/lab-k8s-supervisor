1. Comandos Executados:


```bash
kubectl get nodes
```

```bash
kubectl get pods -o wide
```

```bash
cat <<EOF > app.yaml
...
EOF
```

```bash
kubectl apply -f app.yaml
```

```bash
kubectl get svc web-svc
```

```bash
curl http://localhost:30080
```

```bash
sudo netstat -tulpn | grep 30080
```

```bash
kubectl get daemonset -n kube-system
```


2. O que concluí: 

- O kubectl get pods mostrou dois pods nginx, então o Deployment funcionou.
- O Service apareceu como NodePort, então teoricamente deveria expor a porta.
- O curl local não funcionou; isso já indica que o host não abriu a porta.

3. O que deu certo (e por quê): 

- Deploy do nginx funcionou porque o cluster resolve o agendamento e o kubelet puxou a imagem do Docker Hub.
- Os pods ficaram em Running porque o YAML estava correto e o container é simples.

4. O que não deu certo (e por quê):

- NodePort não abriu a porta porque o cluster é Kind rodando dentro da EC2 como bootstrap do CAPI, e o Kind isola rede em containers.
- O host externo (EC2) não recebeu tráfego porque o kube-proxy configurou regras dentro do container do Kind, não no host real.
- curl no localhost falhou, confirmando que o problema é interno ao cluster, não AWS.

5. Conclusão

Descobri que o cluster que eu tinha não serve para testar NodePort, porque é um bootstrap Kind/CAPI reduzido. Ele cria pods, mas não expõe rede para fora. Então a prática serviu para entender a diferença entre Pod, Service e NodePort, e para perceber que preciso criar um cluster de verdade para continuar testando exposição externa.