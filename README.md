# 802.11a WLAN PHY Implementation

Final Project of **ASIC/FPGA Chip Design** course (EE-25776) @ Sharif University of Technology.

Instructor: Dr. Mahdi Shabany; Fall 2020

---

In this project, I implemented the physical layer (PHY) of the well-known WLAN standard on both MATLAB and HDL platform. The implemented design in each section synthesized and verified on a Virtex-6 FPGA. This project was based on the 802.11a and the goal was to implement the transmitter and receiver side of this standard.

| Phase | Task 
| --------------- | --------------- 
| 1 | Frame structure, scrambling, and descrambling
| 2 | Encoding and decoding (Viterbi Decoder)
| 3 | Interleaving and de-interleaving
| 4 | Integration and matching

<img src="https://user-images.githubusercontent.com/94138466/154808659-5b998afa-669d-450a-bc04-808cc2bdbb4b.png" width=100% height=100%>

### PPDU frame format:
<img src="https://user-images.githubusercontent.com/94138466/154808730-dbb9f8c5-799f-4f18-a947-b7fd49901b3f.png" width=50% height=50%>

### Rate-dependent parameters:
<img src="https://user-images.githubusercontent.com/94138466/154808766-c94a9843-a293-4e92-869b-cb7d3103be96.png" width=50% height=50%>

### SIGNAL field bit assignment:
<img src="https://user-images.githubusercontent.com/94138466/154808772-e60442fc-f2e0-4704-aa0f-0055e2fe4cfb.png" width=50% height=50%>

### PLCP DATA scrambler and descrambler:
<img src="https://user-images.githubusercontent.com/94138466/154808787-454d5eb1-12c7-4341-acc7-3166e596886c.png" width=50% height=50%>

### Convolutional encoder (k = 7):
<img src="https://user-images.githubusercontent.com/94138466/154808821-2f140366-07e3-4c3b-9e87-746e116f3d0c.png" width=50% height=50%>

### Viterbi Decoder:
<img src="https://user-images.githubusercontent.com/94138466/154808894-9c6338d6-4492-4200-90b5-3a17bd9b4b0a.png" width=40% height=40%>

### Interleaving and de-interleaving (r = 2/3)
<img src="https://user-images.githubusercontent.com/94138466/154808947-3561ed04-a02d-49a9-a412-1384a5969634.png" width=50% height=50%>

### Transmitter:
<img src="https://user-images.githubusercontent.com/94138466/154809003-f8bd767a-fa54-4a1e-878c-33ebd9ace6ab.png" width=50% height=50%>

### Receiver:
<img src="https://user-images.githubusercontent.com/94138466/154809009-a0cd4afd-0451-4ede-8f3b-d4ea7787bd17.png" width=50% height=50%>



