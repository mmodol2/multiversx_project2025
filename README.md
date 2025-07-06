# multiversx_project2025
Projecte de crowfunding amb multiversX


````markdown
# 🖥️ Crowdfunding CLI - Guia d'ús del `client.sh`

Aquest projecte inclou un script bash (`client.sh`) que permet interactuar de forma fàcil amb el contracte de crowdfunding desplegat a MultiversX (Devnet).

---

## 📜 Menú principal

Quan executeu:

```bash
./client.sh
````

us apareixerà un menú com aquest:

```
==== Crowdfunding SC Menu ====
1) Donar (fund)
2) Reclamar (claim)
3) Status
4) Fons actuals
5) Target
6) Deadline
7) Donació d'una address
8) Assignar límits globals
9) Consultar límits globals
0) Sortir
```

---

## 🔍 Descripció de cada opció i els paràmetres

### 1️⃣ Donar (fund)

* Fa una donació al contracte.
* **Paràmetres:**

  * El script et demanarà:

    ```
    Quantitat a donar (wei):
    ```

    Has d’introduir l'import en wei.

    * Ex: `10000000000000000` (0.01 EGLD).

---

### 2️⃣ Reclamar (claim)

* Reclama fons si el projecte ha estat exitós (només pot fer-ho el propietari del contracte).
* **Paràmetres:**

  * No es demana cap paràmetre. Només signa amb el teu `.pem`.

---

### 3️⃣ Status

* Mostra l’estat del projecte crowdfunding:

  * `FundingPeriod` → Període actiu.
  * `Successful` → Objectiu aconseguit.
  * `Failed` → Deadline passat sense aconseguir objectiu.
* **Paràmetres:**

  * No introdueixes res.

---

### 4️⃣ Fons actuals

* Mostra la quantitat total recaptada fins ara.
* Es mostra tant en wei com en EGLD.
* **Paràmetres:**

  * No introdueixes res.

---

### 5️⃣ Target

* Mostra el target del projecte (objectiu total).
* En wei i convertit a EGLD.
* **Paràmetres:**

  * No introdueixes res.

---

### 6️⃣ Deadline

* Mostra la data límit (timestamp) i la seva conversió a data/hora humana.
* **Paràmetres:**

  * No introdueixes res.

---

### 7️⃣ Donació d'una address

* Consulta quina quantitat ha aportat un donant concret.
* **Paràmetres:**

  * El script et demanarà:

    ```
    Address del donant:
    ```

    Has d’introduir l’adreça en format MultiversX (ex: `erd1...`).

---

### 8️⃣ Assignar límits globals

* Només el propietari del contracte pot executar aquesta opció.
* Permet modificar:

  * `min_per_tx`: mínim per transacció
  * `max_per_wallet`: màxim acumulat per wallet
  * `max_total`: màxim total del projecte
* **Paràmetres:**

  * El script et demanarà:

    ```
    Mín per tx (wei):
    Màxim per wallet (wei):
    Màxim total projecte (wei):
    ```

---

### 9️⃣ Consultar límits globals

* Mostra els límits actuals configurats al contracte:

  * `min_per_tx`
  * `max_per_wallet`
  * `max_total`
* En wei i convertits a EGLD.
* **Paràmetres:**

  * No introdueixes res.

---

### 0️⃣ Sortir

* Tanca el script.

---

## 🔄 Conversió ràpida EGLD a wei

| EGLD  | Wei                   |
| ----- | --------------------- |
| 1     | `1000000000000000000` |
| 0.1   | `100000000000000000`  |
| 0.01  | `10000000000000000`   |
| 0.001 | `1000000000000000`    |

---

## ✅ Exemple ràpid

Per donar `0.01 EGLD`:

```
==== Crowdfunding SC Menu ====
1) Donar (fund)
...
Opció: 1
Quantitat a donar (wei): 10000000000000000
```

---

## 🔒 Notes finals

* El contracte **controla automàticament** els límits:

  * Mínim per transacció
  * Màxim acumulat per wallet
  * Màxim total del projecte
* Qualsevol wallet pot participar enviant EGLD directament amb:

  * **Recipient:** adreça del contracte
  * **Amount:** import en EGLD
  * **Data:** `fund`
  * **Gas limit:** recomanat `60000000`

---

> ✍️ Projecte per proves a Devnet.
> Pots adaptar els valors i límits fàcilment per experimentar.

```

---

✅ Aquest fitxer està **en pur Markdown GitHub**, així que pots copiar-lo directament com `README.md` i es veurà perfectament al teu repositori.

Si vols, et puc fer un petit `diagrama mermaid` dins el mateix README per mostrar el flux `donar → status → claim/refund`. Vols que t’ho afegeixi?
```
