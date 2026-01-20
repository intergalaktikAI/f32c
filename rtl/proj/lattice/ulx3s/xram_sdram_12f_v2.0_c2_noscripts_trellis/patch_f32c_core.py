#!/usr/bin/env python3
"""
Patch f32c_core_ghdl.vhd for GHDL simulation compatibility.
Adds signal initializations that the original f32c design lacks.
"""

import re

# Read the file
with open('f32c_core_ghdl.vhd', 'r') as f:
    content = f.read()

# Track changes made
changes = []

# 1. Initialize R_reset to '1' (so reset is active on startup)
old = "signal R_reset: std_logic; -- registered reset input"
new = "signal R_reset: std_logic := '1'; -- registered reset input, GHDL: init to active"
if old in content:
    content = content.replace(old, new)
    changes.append("R_reset := '1'")

# 2. Initialize IF_PC to C_eff_init_PC
old = "signal IF_PC, IF_PC_next, IF_PC_ext_next: std_logic_vector(31 downto 2);"
new = "signal IF_PC, IF_PC_next, IF_PC_ext_next: std_logic_vector(31 downto 2) := C_eff_init_PC(31 downto 2); -- GHDL: init PC"
if old in content:
    content = content.replace(old, new)
    changes.append("IF_PC := C_eff_init_PC")

# 3. Initialize IF_ID_PC and related
old = "signal IF_ID_PC, IF_ID_PC_4, IF_ID_PC_next: std_logic_vector(31 downto 2);"
new = "signal IF_ID_PC, IF_ID_PC_4, IF_ID_PC_next: std_logic_vector(31 downto 2) := C_eff_init_PC(31 downto 2); -- GHDL: init PC"
if old in content:
    content = content.replace(old, new)
    changes.append("IF_ID_PC := C_eff_init_PC")

# 4. Initialize IF_ID_bubble to true (no valid instruction on startup)
old = "signal IF_ID_EIP, IF_ID_bubble: boolean;"
new = "signal IF_ID_EIP, IF_ID_bubble: boolean := true; -- GHDL: bubble on startup"
if old in content:
    content = content.replace(old, new)
    changes.append("IF_ID_bubble := true")

# 5. Initialize IF_ID_fetch_in_progress
old = "signal IF_ID_fetch_in_progress, IF_ID_incomplete_branch: boolean;"
new = "signal IF_ID_fetch_in_progress, IF_ID_incomplete_branch: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("IF_ID_fetch_in_progress := false")

# 6. Initialize IF_ID_instruction to NOP
old = "signal IF_ID_instruction: std_logic_vector(31 downto 0);"
new = 'signal IF_ID_instruction: std_logic_vector(31 downto 0) := x"00000000"; -- GHDL: NOP'
if old in content:
    content = content.replace(old, new)
    changes.append("IF_ID_instruction := NOP")

# 7. Initialize ID_EX_bubble to true
old = "signal ID_EX_EIP, ID_EX_bubble: boolean;"
new = "signal ID_EX_EIP, ID_EX_bubble: boolean := true; -- GHDL: bubble on startup"
if old in content:
    content = content.replace(old, new)
    changes.append("ID_EX_bubble := true")

# 8. Initialize EX_MEM_take_branch to false
old = "signal EX_MEM_take_branch: boolean;"
new = "signal EX_MEM_take_branch: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("EX_MEM_take_branch := false")

# 9. Initialize EX_MEM_branch_cycle to false
old = "signal EX_MEM_branch_cycle, EX_MEM_branch_taken: boolean;"
new = "signal EX_MEM_branch_cycle, EX_MEM_branch_taken: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("EX_MEM_branch_cycle := false")

# 10. Initialize ID_EX_mem_cycle and ID_EX_mem_write
old = "signal ID_EX_mem_cycle, ID_EX_mem_write: std_logic;"
new = "signal ID_EX_mem_cycle, ID_EX_mem_write: std_logic := '0'; -- GHDL: no mem access on startup"
if old in content:
    content = content.replace(old, new)
    changes.append("ID_EX_mem_cycle := '0'")

# 11. Initialize EX_MEM_mem_cycle
old = "signal EX_MEM_mem_cycle, EX_MEM_logic_cycle: std_logic;"
new = "signal EX_MEM_mem_cycle, EX_MEM_logic_cycle: std_logic := '0'; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("EX_MEM_mem_cycle := '0'")

# 12. Initialize MEM_WB_write_enable to '0'
old = "signal MEM_WB_write_enable: std_logic;"
new = "signal MEM_WB_write_enable: std_logic := '0'; -- GHDL: no writeback on startup"
if old in content:
    content = content.replace(old, new)
    changes.append("MEM_WB_write_enable := '0'")

# 13. Initialize MEM_WB_mem_cycle
old = "signal MEM_WB_mem_cycle: std_logic;"
new = "signal MEM_WB_mem_cycle: std_logic := '0'; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("MEM_WB_mem_cycle := '0'")

# 14. Initialize ID_EX_writeback_addr to "00000" (reg zero = no writeback)
old = "signal ID_EX_writeback_addr, ID_EX_cop0_addr: std_logic_vector(4 downto 0);"
new = 'signal ID_EX_writeback_addr, ID_EX_cop0_addr: std_logic_vector(4 downto 0) := "00000"; -- GHDL: reg0'
if old in content:
    content = content.replace(old, new)
    changes.append("ID_EX_writeback_addr := 0")

# 15. Initialize EX_MEM_writeback_addr
old = "signal EX_MEM_writeback_addr: std_logic_vector(4 downto 0);"
new = 'signal EX_MEM_writeback_addr: std_logic_vector(4 downto 0) := "00000"; -- GHDL: reg0'
if old in content:
    content = content.replace(old, new)
    changes.append("EX_MEM_writeback_addr := 0")

# 16. Initialize MEM_WB_writeback_addr
old = "signal MEM_WB_writeback_addr: std_logic_vector(4 downto 0);"
new = 'signal MEM_WB_writeback_addr: std_logic_vector(4 downto 0) := "00000"; -- GHDL: reg0'
if old in content:
    content = content.replace(old, new)
    changes.append("MEM_WB_writeback_addr := 0")

# 17. Initialize ID_EX_exception to false (will be set by reset logic)
old = "signal ID_EX_exception, ID_EX_ei, ID_EX_di: boolean;"
new = "signal ID_EX_exception, ID_EX_ei, ID_EX_di: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("ID_EX_exception := false")

# 18. Initialize ID_EX_wait
old = "signal ID_EX_cop0_write, ID_EX_wait: boolean;"
new = "signal ID_EX_cop0_write, ID_EX_wait: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("ID_EX_wait := false")

# 19. Initialize EX_MEM_EIP
old = "signal EX_MEM_EIP: boolean;"
new = "signal EX_MEM_EIP: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("EX_MEM_EIP := false")

# 20. Initialize ID_EX_cancel_next
old = "signal ID_EX_cancel_next, ID_EX_predict_taken: boolean;"
new = "signal ID_EX_cancel_next, ID_EX_predict_taken: boolean := false; -- GHDL: init"
if old in content:
    content = content.replace(old, new)
    changes.append("ID_EX_cancel_next := false")

# 21. Add MI32 reset handling - find the RV32 reset block and add MI32 version
# Looking for the pattern after line 464
rv32_reset_pattern = r"(-- crude reset hack for RV32.*?\n\s+if C_arch = ARCH_RV32 and R_reset = '1' then\n\s+IF_ID_PC <= R_cop0_EBASE and C_PC_mask\(31 downto 2\);\n\s+IF_ID_bubble <= true;\n\s+end if;)"

mi32_reset_addition = r"""\1
	    -- GHDL simulation: reset for MI32 (similar to RV32)
	    if C_arch = ARCH_MI32 and R_reset = '1' then
		IF_ID_PC <= C_eff_init_PC(31 downto 2);
		IF_ID_bubble <= true;
	    end if;"""

if re.search(rv32_reset_pattern, content, re.DOTALL):
    content = re.sub(rv32_reset_pattern, mi32_reset_addition, content, flags=re.DOTALL)
    changes.append("Added MI32 reset handling")

# Write the modified file
with open('f32c_core_ghdl.vhd', 'w') as f:
    f.write(content)

print("Patched f32c_core_ghdl.vhd with the following changes:")
for c in changes:
    print(f"  - {c}")
print(f"\nTotal: {len(changes)} modifications")
