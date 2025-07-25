# 🚀 Kubernetes Storage Benchmark Project

Kubernetes 환경에서 다양한 스토리지 솔루션의 성능을 체계적으로 벤치마킹하기 위한 FIO 기반 테스트 도구입니다.

## 📋 목차

- [프로젝트 개요](#-프로젝트-개요)
- [지원하는 스토리지](#-지원하는-스토리지)
- [프로젝트 구조](#-프로젝트-구조)
- [파일 명명 규칙](#-파일-명명-규칙)
- [사전 요구사항](#-사전-요구사항)
- [사용 방법](#-사용-방법)
- [테스트 시나리오](#-테스트-시나리오)
- [주요 특징](#-주요-특징)
- [성능 모니터링](#-성능-모니터링)
- [문제 해결](#-문제-해결)
- [기여하기](#-기여하기)

## 🎯 프로젝트 개요

이 프로젝트는 Kubernetes 클러스터에서 **Ceph**와 **Longhorn** 스토리지의 성능을 실제 운영 환경에 가까운 조건에서 벤치마킹할 수 있는 도구입니다.

### 핵심 목표
- **실용성**: 4k 랜덤 I/O 중심의 실제 워크로드 시뮬레이션
- **확장성**: 단일/다중 Pod 환경에서의 성능 비교
- **일관성**: 표준화된 테스트 조건과 파라미터
- **운영성**: 프로덕션 환경에서 바로 사용 가능한 설정

## 💾 지원하는 스토리지

| 스토리지 | Access Mode | 사용 사례 |
|----------|-------------|-----------|
| **Ceph** | RWX (ReadWriteMany) | 다중 Pod 공유 스토리지 |
| **Ceph** | RWO (ReadWriteOnce) | 개별 Pod 전용 블록 스토리지 |
| **Longhorn** | RWX (ReadWriteMany) | 분산 공유 파일 시스템 |
| **Longhorn** | RWO (ReadWriteOnce) | 개별 Pod 전용 볼륨 |

## 📁 프로젝트 구조

```
fio-project/
├── README.md
├── ceph/
│   ├── ceph-pvc.yaml                                    # Ceph RWX PVC 정의
│   ├── single-job/                                      # 단일 Pod 테스트
│   │   ├── 01-ceph-rwx-4k-rr-single-job.yaml          # RWX 랜덤 읽기
│   │   ├── 02-ceph-rwx-4k-rw-single-job.yaml          # RWX 랜덤 쓰기
│   │   ├── 03-ceph-rwo-4k-rr-single-sts.yaml          # RWO 랜덤 읽기
│   │   └── 04-ceph-rwo-4k-rw-single-sts.yaml          # RWO 랜덤 쓰기
│   └── multi-job/                                       # 다중 Pod 테스트
│       ├── 01-ceph-rwx-4k-rr-multi-job.yaml           # RWX 랜덤 읽기 (6 Pods)
│       ├── 02-ceph-rwx-4k-rw-multi-job.yaml           # RWX 랜덤 쓰기 (6 Pods)
│       ├── 03-ceph-rwo-4k-rr-multi-sts.yaml           # RWO 랜덤 읽기 (3 Pods)
│       └── 04-ceph-rwo-4k-rw-multi-sts.yaml           # RWO 랜덤 쓰기 (3 Pods)
└── longhorn/
    ├── longhorn-pvc.yaml                                # Longhorn RWX PVC 정의
    ├── single-job/                                      # 단일 Pod 테스트
    │   ├── 01-longhorn-rwx-4k-rr-single-job.yaml      # RWX 랜덤 읽기
    │   ├── 02-longhorn-rwx-4k-rw-single-job.yaml      # RWX 랜덤 쓰기
    │   ├── 03-longhorn-rwo-4k-rr-single-sts.yaml      # RWO 랜덤 읽기
    │   └── 04-longhorn-rwo-4k-rw-single-sts.yaml      # RWO 랜덤 쓰기
    └── multi-job/                                       # 다중 Pod 테스트
        ├── 01-longhorn-rwx-4k-rr-multi-job.yaml       # RWX 랜덤 읽기 (6 Pods)
        ├── 02-longhorn-rwx-4k-rw-multi-job.yaml       # RWX 랜덤 쓰기 (6 Pods)
        ├── 03-longhorn-rwo-4k-rr-multi-sts.yaml       # RWO 랜덤 읽기 (3 Pods)
        └── 04-longhorn-rwo-4k-rw-multi-sts.yaml       # RWO 랜덤 쓰기 (3 Pods)
```

## 🏷️ 파일 명명 규칙

모든 YAML 파일은 다음과 같은 일관된 명명 규칙을 따릅니다:

```
XX-{storage}-{accessMode}-4k-{type}-{mode}-{resource}.yaml
```

### 구성 요소 설명

| 구성 요소 | 설명 | 예시 |
|-----------|------|------|
| `XX` | 순서 번호 (01-04) | `01`, `02`, `03`, `04` |
| `{storage}` | 스토리지 타입 | `ceph`, `longhorn` |
| `{accessMode}` | 접근 모드 | `rwx` (ReadWriteMany), `rwo` (ReadWriteOnce) |
| `4k` | 블록 크기 | `4k` (4KB 고정) |
| `{type}` | I/O 타입 | `rr` (randread), `rw` (randwrite) |
| `{mode}` | 실행 모드 | `single`, `multi` |
| `{resource}` | Kubernetes 리소스 | `job`, `sts` (StatefulSet) |

### 명명 예시
- `01-ceph-rwx-4k-rr-single-job.yaml`: Ceph RWX 단일 Pod 랜덤 읽기 Job
- `03-longhorn-rwo-4k-rw-multi-sts.yaml`: Longhorn RWO 다중 Pod 랜덤 쓰기 StatefulSet

## 🔧 사전 요구사항

### Kubernetes 클러스터
- Kubernetes v1.20 이상
- 최소 3개의 워커 노드 (다중 Pod 테스트용)
- 워커 노드에 `kubernetes.io/role=compute-node` 레이블 설정

```bash
# 워커 노드에 레이블 추가
kubectl label nodes <worker-node-name> kubernetes.io/role=compute-node
```

### 스토리지 준비
- **Ceph**: CephFS와 Ceph Block 스토리지 클래스 구성
  - `ceph-filesystem` (RWX용)
  - `ceph-block` (RWO용)
- **Longhorn**: Longhorn 스토리지 시스템 설치 및 구성
  - `longhorn` 스토리지 클래스

### FIO 컨테이너 이미지
이 프로젝트는 `projectgreenist/fio-project:1.0` 이미지를 사용합니다.

## 🚀 사용 방법

### 1. PVC 생성
먼저 공유 볼륨용 PVC를 생성합니다:

```bash
# Ceph PVC 생성
kubectl apply -f ceph/ceph-pvc.yaml

# Longhorn PVC 생성
kubectl apply -f longhorn/longhorn-pvc.yaml
```

### 2. 테스트 실행

#### 단일 Pod 테스트
```bash
# Ceph RWX 랜덤 읽기 테스트
kubectl apply -f ceph/single-job/01-ceph-rwx-4k-rr-single-job.yaml

# Longhorn RWO 랜덤 쓰기 테스트
kubectl apply -f longhorn/single-job/04-longhorn-rwo-4k-rw-single-sts.yaml
```

#### 다중 Pod 테스트
```bash
# Ceph 다중 Pod 랜덤 읽기 테스트 (6개 Pod)
kubectl apply -f ceph/multi-job/01-ceph-rwx-4k-rr-multi-job.yaml

# Longhorn 다중 Pod RWO 테스트 (3개 StatefulSet Pod)
kubectl apply -f longhorn/multi-job/03-longhorn-rwo-4k-rr-multi-sts.yaml
```

### 3. 결과 확인

#### Job 상태 확인
```bash
kubectl get jobs
kubectl get pods
```

#### StatefulSet 상태 확인
```bash
kubectl get statefulsets
kubectl get pods -l app=<app-label>
```

#### 로그 확인
```bash
# Job Pod 로그
kubectl logs <job-pod-name>

# StatefulSet Pod 로그
kubectl logs <statefulset-pod-name>
```

### 4. 정리
```bash
# Job 정리
kubectl delete jobs --all

# StatefulSet 정리
kubectl delete statefulsets --all

# PVC 정리 (주의: 데이터 손실됨)
kubectl delete pvc --all
```

## 🎯 테스트 시나리오

### FIO 테스트 파라미터

모든 테스트는 다음과 같은 일관된 파라미터를 사용합니다:

```bash
fio --name=<test-name> \
    --filename=/data/fiotest-${HOSTNAME}.tmp \
    --rw=<randread|randwrite> \
    --bs=4k \
    --ioengine=libaio \
    --direct=1 \
    --size=2G \
    --numjobs=2 \
    --iodepth=64 \
    --runtime=60s \
    --time_based \
    --group_reporting
```

### 테스트 매트릭스

| 테스트 | 스토리지 | Access Mode | I/O 패턴 | Pod 수 | 용도 |
|--------|----------|-------------|----------|--------|------|
| 01 | Ceph/Longhorn | RWX | 랜덤 읽기 | 1/6 | 공유 스토리지 읽기 성능 |
| 02 | Ceph/Longhorn | RWX | 랜덤 쓰기 | 1/6 | 공유 스토리지 쓰기 성능 |
| 03 | Ceph/Longhorn | RWO | 랜덤 읽기 | 1/3 | 개별 볼륨 읽기 성능 |
| 04 | Ceph/Longhorn | RWO | 랜덤 쓰기 | 1/3 | 개별 볼륨 쓰기 성능 |

## ✨ 주요 특징

### 🔄 리소스 타입별 최적화
- **Job (RWX)**: 공유 볼륨에서 동시 실행, 작업 완료 후 자동 종료
- **StatefulSet (RWO)**: 개별 볼륨 자동 생성, `sleep infinity`로 결과 확인 용이

### 📊 노드 분산 정책
```yaml
# 노드 분산을 위한 설정
topologySpreadConstraints:
- maxSkew: 2  # RWX Job: 최대 2개 Pod 차이 허용
- maxSkew: 1  # RWO StatefulSet: 최대 1개 Pod 차이 허용
  topologyKey: "kubernetes.io/hostname"
  whenUnsatisfiable: DoNotSchedule

# 컴퓨트 노드 전용 스케줄링
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: kubernetes.io/role
        operator: In
        values: ["compute-node"]
```

### 💾 볼륨 관리
- **RWX**: 사전 정의된 PVC 사용 (공유)
- **RWO**: `volumeClaimTemplates`로 개별 PVC 자동 생성

### 🎛️ 확장성
- `replicas` 값 조정으로 쉬운 스케일링
- Pod별 고유한 테스트 파일 생성 (`fiotest-${HOSTNAME}.tmp`)

## 📈 성능 모니터링

### 주요 메트릭
FIO 결과에서 다음 메트릭을 확인하세요:

```
# 읽기 성능
read: IOPS=XXXk, BW=XXXMiB/s
# 쓰기 성능  
write: IOPS=XXXk, BW=XXXMiB/s
# 지연시간
lat (usec): min=XX, max=XXXX, avg=XXX.XX
```

### 모니터링 명령어
```bash
# 실시간 Pod 상태 모니터링
watch kubectl get pods

# 리소스 사용량 확인
kubectl top pods
kubectl top nodes

# 스토리지 사용량 확인
kubectl get pvc
```

## 🔍 문제 해결

### 일반적인 문제

#### 1. Pod가 Pending 상태
```bash
# 원인 파악
kubectl describe pod <pod-name>

# 해결책
# - 노드 레이블 확인: kubernetes.io/role=compute-node
# - 리소스 부족 확인
# - 스토리지 클래스 상태 확인
```

#### 2. StatefulSet Pod 재시작
```bash
# 현재 이 프로젝트는 sleep infinity로 해결됨
# 만약 문제가 지속되면 로그 확인:
kubectl logs <statefulset-pod-name>
```

#### 3. PVC Pending 상태
```bash
# 스토리지 클래스 확인
kubectl get storageclass

# PVC 상세 정보 확인
kubectl describe pvc <pvc-name>
```

### 성능 최적화 팁

1. **노드 리소스**: CPU/메모리 충분한 노드 사용
2. **네트워크**: 10Gbps 이상 네트워크 권장
3. **스토리지**: SSD 기반 스토리지 사용
4. **동시성**: 너무 많은 Pod 동시 실행 방지

## 🤝 기여하기

### 개선 아이디어
- 새로운 스토리지 솔루션 추가 (예: OpenEBS, Rook)
- 다양한 블록 크기 테스트 (8k, 16k, 64k)
- 혼합 워크로드 테스트 (읽기/쓰기 비율 조절)
- Prometheus 메트릭 수집 통합

### 기여 방법
1. Fork this repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 제공됩니다.

## 🔗 관련 링크

- [FIO 공식 문서](https://fio.readthedocs.io/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Ceph 스토리지](https://ceph.io/)
- [Longhorn 스토리지](https://longhorn.io/)

---

**이 프로젝트로 Kubernetes 스토리지의 진정한 성능을 발견해보세요!** 🚀✨ 