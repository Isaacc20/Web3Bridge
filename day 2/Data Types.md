# Structs, Mappings and Arrays

## Where are your structs, mappings and arrays stored?

- Structs, mappings and arrays are reference types, and can be stored anywhere depending on the use case.
- Where they are stored depends on how they are being used.
- If they are called/created as a state variable (not within a function), they will be stored in **storage**.
- If they are called/created within a function, the location must be specified as **memory**, **calldata**, or **storage** (for structs and arrays).
- **Mappings can only live in storage** — they cannot be created in memory or calldata because their size is not defined and they don’t store keys.

---

## How they behave when executed or called

- Structs, mappings and arrays are data containers — they don’t execute anything by themselves.
- When a function accesses them, the EVM loads only the required values from their location (storage, memory, or calldata) onto the **stack** for the operation to be perfomed.
- Arrays and structs load only the indexed field or element being accessed — not the entire structure unless you explicitly copy it to memory.

---

## Why you don’t need to specify memory or storage with mappings

- Mappings are **storage-only types** — they cannot exist in memory or calldata.
- Because of that, Solidity already knows their data location and does not allow any other option.
- That’s why you never write `mapping(...) memory` or `mapping(...) calldata`.
- When passed into functions, mappings are always passed as **storage references**.
