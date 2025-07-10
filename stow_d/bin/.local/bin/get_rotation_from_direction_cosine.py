import numpy as np
from scipy.spatial.transform import Rotation as R

### Vector the capsule is currently pointing to
##v_start = np.array([0, 1, 0])
##
### Target direction cosine
##v_end = np.array([-0.563607, 0.7371925, -0.3726841])
##v_end = v_end / np.linalg.norm(v_end)
##
### Cross and dot products
##axis = np.cross(v_start, v_end)
##angle = np.arccos(np.clip(np.dot(v_start, v_end), -1.0, 1.0))
##
### If angle is small, no rotation needed
##if np.linalg.norm(axis) < 1e-6:
##    rot = R.identity()
##else:
##    axis = axis / np.linalg.norm(axis)
##    rot = R.from_rotvec(axis * angle)
##    flip = R.from_euler('y', 180, degrees=True)
##    rot = flip * rot
##
### Get Euler angles in degrees (XYZ order)
##euler_angles_deg = rot.as_euler('xyz', degrees=True)
##
##print("Euler angles (degrees):", euler_angles_deg)
##
##
### Using R.align_vectors
##v_end = np.array([0.563607, -0.7371925, 0.3726841])
##rot, _ = R.align_vectors([v_end], [v_start])
### Get Euler angles in degrees (XYZ order)
##euler_angles_deg = rot.as_euler('xyz', degrees=True)
##print("Euler angles (degrees):", euler_angles_deg)                         

##def rotation_from_to(v_from, v_to):
##    v_from = v_from / np.linalg.norm(v_from)
##    v_to = v_to / np.linalg.norm(v_to)
##    dot = np.dot(v_from, v_to)
##
##    # If vectors are almost the same, return identity
##    if np.isclose(dot, 1.0):
##        return R.identity()
##    
##    # If vectors are opposite, we need a special case
##    if np.isclose(dot, -1.0):
##        # Pick an arbitrary orthogonal axis
##        orthogonal = np.array([1, 0, 0]) if not np.allclose(v_from, [1, 0, 0]) else np.array([0, 1, 0])
##        axis = np.cross(v_from, orthogonal)
##        axis = axis / np.linalg.norm(axis)
##        return R.from_rotvec(np.pi * axis)  # 180 degree rotation
##
##    # Standard case
##    axis = np.cross(v_from, v_to)
##    angle = np.arccos(np.clip(dot, -1.0, 1.0))
##    return R.from_rotvec(axis / np.linalg.norm(axis) * angle)
##
### Inputs
##v_start = np.array([0, 1, 0])
##v_end = np.array([0.563607, -0.7371925, 0.3726841])
##
### Compute rotation
##rot = rotation_from_to(v_start, v_end)
##
### Euler angles
##euler = rot.as_euler('xyz', degrees=True)
##print("Euler angles:", euler)

def rotation_from_to(v_from, v_to):
    v_from = v_from / np.linalg.norm(v_from)
    v_to = v_to / np.linalg.norm(v_to)
    dot = np.dot(v_from, v_to)

    if np.isclose(dot, 1.0):
        return R.identity()

    if np.isclose(dot, -1.0):
        # Pick any orthogonal vector
        orthogonal = np.array([1, 0, 0]) if not np.allclose(v_from, [1, 0, 0]) else np.array([0, 0, 1])
        axis = np.cross(v_from, orthogonal)
        axis = axis / np.linalg.norm(axis)
        return R.from_rotvec(np.pi * axis)

    axis = np.cross(v_from, v_to)
    angle = np.arccos(np.clip(dot, -1.0, 1.0))
    return R.from_rotvec(axis / np.linalg.norm(axis) * angle)

# Start and target
v_start = np.array([0, 1, 0])  # initial capsule direction
v_end = np.array([-0.563607, 0.7371925, -0.3726841])  # inverted direction cosine
v_end = v_end / np.linalg.norm(v_end)

# Compute rotation
rot = rotation_from_to(v_start, v_end)

# Check what happens to v_start after rotation
rotated = rot.apply(v_start)

# Flip to match needed results
flip = R.from_euler('z', 180, degrees=True)
rot = flip * rot
flip = R.from_euler('y', 180, degrees=True)
rot = flip * rot

# Euler angles (you can change 'xyz' to 'zyx' depending on your engine)
euler_deg = rot.as_euler('xyz', degrees=True)

print("Euler angles:", euler_deg)
print("Rotated Y-axis:", rotated)
print("Should match:", v_end)
