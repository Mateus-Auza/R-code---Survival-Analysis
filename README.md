## Disclaimer

This project was completed as part of a university course at UCLouvain.
It is shared for educational and portfolio purposes only.


## Dataset Description

This dataset comes from an experimental study investigating whether invasive (non-native) populations of *Ulmus pumila* (Siberian elm) differ in their germination dynamics compared to native populations. The dataset can be found using this link **https://zenodo.org/records/5002291**

The central ecological question is whether non-native populations exhibit faster or more successful germination, which may contribute to their invasion success.

### Seed Origin

Seeds were collected from two geographic ranges:

- **China** — native range  
- **United States** — non-native range  

### Experimental Design

Germination experiments were conducted under two controlled temperature treatments:

- **20 °C** (moderate temperature)  
- **30 °C** (warm temperature)  

For each seed, the time to germination was recorded. Seeds that did not germinate by the end of the observation period were treated as **right-censored** observations.

---

## Research Question

Do non-native populations of *Ulmus pumila* germinate faster or more successfully than native populations, and how is this affected by temperature?

---

## Recorded Variables

- **seed**: Index of the seed within each experimental replicate (values range from 1 to 20).  
  *Note:* This variable is not a unique identifier, as the same seed index appears across multiple replicates.
- **Range**: Geographic origin of the seed (`China` = native, `USA` = non-native).
- **Population**: Specific population within each geographic range.
- **Replicate**: Experimental replicate or batch to which the seed belongs.
- **Germination_day**: Day on which germination occurred (discrete time variable).
- **Status**: Censoring indicator (`1` = seed germinated, `0` = seed did not germinate by the end of the study).
- **Temperature_treatment**: Temperature condition under which the seed was incubated (`20 °C` or `30 °C`).

---

## Statistical Framework

Because germination time is observed as a discrete time-to-event variable with right censoring, the data naturally lend themselves to **survival analysis** methods, including:

- Kaplan–Meier estimators  
- Log-rank tests  
- Cox proportional hazards models  

---

*SurvivalAnalysisProject — December 30, 2025*
