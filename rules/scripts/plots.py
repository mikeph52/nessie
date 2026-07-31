import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import pandas as pd
import re
import os

# ── Parse QUAST reports ──────────────────────────────────────────────
def parse_quast(filepath):
    data = {}
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if "\t" in line:
                key, val = line.split("\t", 1)
                data[key.strip()] = val.strip()
    return data

# ── Parse BUSCO summary ──────────────────────────────────────────────
def parse_busco(filepath):
    data = {}
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            m = re.search(r'C:(\d+\.\d+)%\[S:(\d+\.\d+)%,D:(\d+\.\d+)%\],F:(\d+\.\d+)%,M:(\d+\.\d+)%', line)
            if m:
                data["Complete"]    = float(m.group(1))
                data["Single"]      = float(m.group(2))
                data["Duplicated"]  = float(m.group(3))
                data["Fragmented"]  = float(m.group(4))
                data["Missing"]     = float(m.group(5))
    return data

# ── Parse NanoStat ───────────────────────────────────────────────────
def parse_nanostat(filepath):
    data = {}
    with open(filepath) as f:
        for line in f:
            if ":" in line:
                key, val = line.strip().split(":", 1)
                data[key.strip()] = val.strip()
    return data

# ── Load data ────────────────────────────────────────────────────────
quast_files   = snakemake.input.quast
busco_files   = snakemake.input.busco
nanostat_files = snakemake.input.nanostat

samples = snakemake.config["samples"]

quast_data   = {s: parse_quast(f)   for s, f in zip(samples, quast_files)}
busco_data   = {s: parse_busco(f)   for s, f in zip(samples, busco_files)}
nanostat_data = {s: parse_nanostat(f) for s, f in zip(samples, nanostat_files)}

# ── Plot ─────────────────────────────────────────────────────────────
fig = plt.figure(figsize=(16, 12))
fig.suptitle("Nessie — Assembly Statistics Summary", fontsize=16, fontweight="bold", y=1.01)

gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.45, wspace=0.35)

ax1 = fig.add_subplot(gs[0, 0])  # N50
ax2 = fig.add_subplot(gs[0, 1])  # Total length
ax3 = fig.add_subplot(gs[0, 2])  # Number of contigs
ax4 = fig.add_subplot(gs[1, 0])  # BUSCO stacked bar
ax5 = fig.add_subplot(gs[1, 1])  # Read N50
ax6 = fig.add_subplot(gs[1, 2])  # GC content

colors = plt.cm.Set2.colors

# ── N50 ──────────────────────────────────────────────────────────────
n50_vals = []
for s in samples:
    val = quast_data[s].get("N50", "0")
    n50_vals.append(int(val) / 1e6)  # convert to Mb

bars = ax1.bar(samples, n50_vals, color=colors[:len(samples)])
ax1.set_title("Assembly N50")
ax1.set_ylabel("N50 (Mb)")
ax1.set_xticks(range(len(samples)))
ax1.set_xticklabels(samples, rotation=15, ha="right")
for bar, val in zip(bars, n50_vals):
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
             f"{val:.1f}", ha="center", va="bottom", fontsize=9)

# ── Total length ─────────────────────────────────────────────────────
len_vals = []
for s in samples:
    val = quast_data[s].get("Total length", "0")
    len_vals.append(int(val) / 1e9)  # convert to Gb

bars = ax2.bar(samples, len_vals, color=colors[:len(samples)])
ax2.set_title("Total Assembly Length")
ax2.set_ylabel("Length (Gb)")
ax2.set_xticks(range(len(samples)))
ax2.set_xticklabels(samples, rotation=15, ha="right")
for bar, val in zip(bars, len_vals):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.005,
             f"{val:.2f}", ha="center", va="bottom", fontsize=9)

# ── Number of contigs ────────────────────────────────────────────────
contig_vals = []
for s in samples:
    val = quast_data[s].get("# contigs", "0")
    contig_vals.append(int(val))

bars = ax3.bar(samples, contig_vals, color=colors[:len(samples)])
ax3.set_title("Number of Contigs")
ax3.set_ylabel("Count")
ax3.set_xticks(range(len(samples)))
ax3.set_xticklabels(samples, rotation=15, ha="right")
for bar, val in zip(bars, contig_vals):
    ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 10,
             f"{val:,}", ha="center", va="bottom", fontsize=9)

# ── BUSCO stacked bar ────────────────────────────────────────────────
busco_categories = ["Single", "Duplicated", "Fragmented", "Missing"]
busco_colors     = ["#2ecc71", "#f39c12", "#e67e22", "#e74c3c"]
bottom = [0] * len(samples)

for cat, col in zip(busco_categories, busco_colors):
    vals = [busco_data[s].get(cat, 0) for s in samples]
    ax4.bar(samples, vals, bottom=bottom, label=cat, color=col)
    bottom = [b + v for b, v in zip(bottom, vals)]

ax4.set_title("BUSCO Completeness")
ax4.set_ylabel("% BUSCOs")
ax4.set_ylim(0, 105)
ax4.set_xticks(range(len(samples)))
ax4.set_xticklabels(samples, rotation=15, ha="right")
ax4.legend(loc="lower right", fontsize=8)

# ── Read N50 ─────────────────────────────────────────────────────────
read_n50_vals = []
for s in samples:
    val = nanostat_data[s].get("Read N50", "0 bp").replace(",", "").split()[0]
    read_n50_vals.append(int(val) / 1e3)  # convert to kb

bars = ax5.bar(samples, read_n50_vals, color=colors[:len(samples)])
ax5.set_title("Read N50")
ax5.set_ylabel("Read N50 (kb)")
ax5.set_xticks(range(len(samples)))
ax5.set_xticklabels(samples, rotation=15, ha="right")
for bar, val in zip(bars, read_n50_vals):
    ax5.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
             f"{val:.1f}", ha="center", va="bottom", fontsize=9)

# ── GC content ───────────────────────────────────────────────────────
gc_vals = []
for s in samples:
    val = quast_data[s].get("GC (%)", "0")
    gc_vals.append(float(val))

bars = ax6.bar(samples, gc_vals, color=colors[:len(samples)])
ax6.set_title("GC Content")
ax6.set_ylabel("GC (%)")
ax6.set_ylim(0, 60)
ax6.set_xticks(range(len(samples)))
ax6.set_xticklabels(samples, rotation=15, ha="right")
for bar, val in zip(bars, gc_vals):
    ax6.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
             f"{val:.1f}%", ha="center", va="bottom", fontsize=9)

plt.savefig(snakemake.output.plot, dpi=150, bbox_inches="tight")
print(f"Plot saved to {snakemake.output.plot}")