# Understanding Concepts

I will start telling what is Kubernetes.

Kubernetes is just a API + database that stores desired state. Besides that, Kubernetes is really a kind of distributed operating system for clusters: its core job is continuous reconciliation — always driving the actual state of workloads, networks, storage back toward the desired state you declared.

So, we have some actors, and I'm going to explain them in an order that makes sense based on necessity.

0. **The application:** This is the main purpose that brings us here: an application that provides some resource to the world, but it cannot work on its own. It implements only a small part of use case. This is a common scenario nowadays: the main philosophy in software engineering is to break applications into small pieces — we chopped monoliths into microservices because apparently we enjoy debugging networks instead of functions... jokes aside, I'll explain later why this shift happend in the [Why the Microservice Paradigm?](#why-the-microservice-paradigm)

1. **The Runtime:** If there's no place for your application to run, then it simply does nothing. So, you must have an enviroment capable of running the application: the `runtime`. In kubernetes, isn't just "somewhere to run the app". It's specifically a container that follows the `Container Runtime Interface (CRI)`. In the session [Why containers?](#why-containers) i will explain what's so special abount containers.

2. **Kubelet:** You make a choice on build this distributed system and now you need to coordinate a potential set of applications and services, but perceive that they don't recognize themselves as part of a larger system. In fact, the runtime running the applications has no awareness of Kubernetes at all. That's why you need a process that connects the application on the runtime to the cluster. This process is the `kubelet`, an agent that makes the application truly part of the ecosystem.

32. **Node:** The kubelet makes the machine's computing capacity available to the cluster by using a container runtime that implements the CRI. A machine (VM or bare-metal) providing CPU, memory, network, and storage runs the kubelet and becomes part of the cluster. To emphasize: a node is simply an individual machine with a running kubelet plus a container runtime.

4. **Pod:** In some sense, a Node is 'idle capacity' waiting for workloads. To use that capacity efficiently, Kubernetes introduces an abstraction: the `pod`. A pod is the smallest unit you can schedule onto a node. A pod is a wrapper around one or more containers that share the same network and storage. Pods can run business applications or cluster services (like DNS). They aren't 'jobs' themselves, but they're the basic building blocks that everything else schedules and manages.

so far, an important distinction:
- **Node** → the machine, part of the cluster because a kubelet and a container runtime are running on it; it provides capacity.
- **Pod**  → the workload abstraction, the smallest schedulable unit, wrapping one or more containers; it consumes the node’s capacity.


5. **API Server:** This is the central Hub. It receives and exposes the cluster's internal state as an API. It doesn't 'act' itself, but everything passes through it. It's backed by the `etcd` database and implemented as a REST server in `Go` . Actually, almost all of Kubernetes is written in Go, more on that in [Where did come Gollang?](#where-did-come-gollang).

6. **Scheduler:**


7. **Controllers:** they watch the API server for objects they care about (i'll comment on this in a moment) and they write back changes to the API server to move the cluster closer to desired state.



I bit more about the 'move to the desired state' statement that i made.

Something important do be understanded is that clients can 'watch' keys for changes and get updates immediately

Each `provider` is nothing more than a `controller` 


# Why the Microservice Paradigm?

# Why containers?

# Where did come Gollang?