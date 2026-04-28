import json
import math
import matplotlib.pyplot as plt
from PIL import Image

def load_fingerprints(path):
    with open(path) as f:
        return json.load(f)

def euclidean_distance(scan1, scan2):
    map1 = {n['bssid']: n['rssi'] for n in scan1}
    total = 0
    shared = 0
    for n in scan2:
        if n['bssid'] in map1:
            total += (map1[n['bssid']] - n['rssi']) ** 2
            shared += 1
    if shared == 0:
        return float('inf')
    return math.sqrt(total)

def get_sorted_distances(test_networks, training):
    distances = []
    for fp in training:
        dist = euclidean_distance(test_networks, fp['networks'])
        if dist != float('inf'):
            distances.append((fp, dist))
    distances.sort(key=lambda x: x[1])
    return distances

def weighted_average(nearest):
    weighted_x, weighted_y, total_weight = 0, 0, 0
    for fp, dist in nearest:
        w = 1000.0 if dist == 0 else 1.0 / dist
        weighted_x += fp['x'] * w
        weighted_y += fp['y'] * w
        total_weight += w
    return (weighted_x / total_weight, weighted_y / total_weight)

def knn_basic(test_networks, training, k=3):
    distances = get_sorted_distances(test_networks, training)
    nearest = distances[:k]
    if not nearest:
        return None
    x = sum(fp['x'] for fp, _ in nearest) / len(nearest)
    y = sum(fp['y'] for fp, _ in nearest) / len(nearest)
    return (x, y)

def knn_weighted(test_networks, training, k=3):
    distances = get_sorted_distances(test_networks, training)
    nearest = distances[:k]
    if not nearest:
        return None
    return weighted_average(nearest)

def adaptive_k(sorted_distances, min_k=2, max_k=7):
    for k in range(min_k, min(max_k, len(sorted_distances))):
        if sorted_distances[k] > sorted_distances[0] * 2:
            return k
    return min(max_k, len(sorted_distances))

def knn_adaptive(test_networks, training):
    distances = get_sorted_distances(test_networks, training)
    if not distances:
        return None
    k = adaptive_k([d for _, d in distances])
    nearest = distances[:k]
    return weighted_average(nearest)

def evaluate(training, test_data, method, method_name, pixels_per_meter):
    errors = []
    for test in test_data:
        estimate = method(test['networks'], training)
        if estimate:
            error = math.sqrt((test['x'] - estimate[0]) ** 2 + (test['y'] - estimate[1]) ** 2)
            errors.append(error)
    errors_m = [e / pixels_per_meter for e in errors]
    avg = sum(errors_m) / len(errors_m)
    max_err = max(errors_m)
    min_err = min(errors_m)
    print(f"{method_name}: avg={avg:.1f}m, max={max_err:.1f}m, min={min_err:.1f}")
    return errors, errors_m

training = load_fingerprints('training_fingerprints.json')
test_data = load_fingerprints('test_fingerprints.json')

PIXELS_PER_METER = 14.3
DISPLAY_WIDTH = 350.7
FLOOR_PLAN_PATH = '../assets/planimetria_casa.jpg'

# Evaluate
results_px = {}
results_m = {}
for name, method in [('kNN', knn_basic), ('wkNN', knn_weighted), ('sawkNN', knn_adaptive)]:
    errors_px, errors_m = evaluate(training, test_data, method, name, PIXELS_PER_METER)
    results_px[name] = errors_px
    results_m[name] = errors_m

# Bar chart
methods = list(results_m.keys())
avgs = [sum(e) / len(e) for e in results_m.values()]
maxes = [max(e) for e in results_m.values()]

fig, ax = plt.subplots()
x = range(len(methods))
width = 0.35
ax.bar([i - width / 2 for i in x], avgs, width, label='Avg Error (m)')
ax.bar([i + width / 2 for i in x], maxes, width, label='Max Error (m)')
ax.set_ylabel('Error (meters)')
ax.set_xticks(x)
ax.set_xticklabels(methods)
ax.legend()
ax.set_title('Positioning Accuracy by Method')
plt.savefig('accuracy_comparison.png', dpi=150)
plt.show()

# Scatter plot
floor_plan = Image.open(FLOOR_PLAN_PATH)
img_width, img_height = floor_plan.size
scale = img_width / DISPLAY_WIDTH

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
for ax, (name, method) in zip(axes, [('kNN', knn_basic), ('wkNN', knn_weighted), ('sawkNN', knn_adaptive)]):
    ax.imshow(floor_plan)
    for test in test_data:
        estimate = method(test['networks'], training)
        if estimate:
            ax.plot(test['x'] * scale, test['y'] * scale, 'go', markersize=8)
            ax.plot(estimate[0] * scale, estimate[1] * scale, 'rx', markersize=8)
            ax.plot([test['x'] * scale, estimate[0] * scale], [test['y'] * scale, estimate[1] * scale], 'r-', alpha=0.3)
    ax.set_title(name)
    ax.axis('off')

plt.tight_layout()
plt.savefig('position_comparison.png', dpi=150)
plt.show()