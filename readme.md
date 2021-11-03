# Presets and Sharing

A plugin for Openplanet in Trackmania.

## Packed Definition

### Header

| Byte | Bits | Data               | Description                        |
|------|------|--------------------|------------------------------------|
|    0 |  0-3 | Serializer version | Integer version for the serializer |
|    0 |  4-7 | Spare              | Spare                              |
|    1 |  0-7 | Settings count     | Number of settings in the file     |
|    2 |  0-7 | Plugin name hash   | One byte hash of the plugin name   |

### Bool Setting

| Byte | Bits | Data               | Description                        |
|------|------|--------------------|------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name     |
|    2 |  0-3 | Setting type       | Type enumeration                   |
|    2 |  4-6 | Spare              | Spare                              |
|    2 |    7 | Boolean value      | Bool data                          |

### Integer/Enum Setting

| Byte | Bits | Data               | Description                        |
|------|------|--------------------|------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name     |
|    2 |  0-3 | Setting type       | Type enumeration                   |
|    2 |  4-5 | Data bytes count   | enumeration of number of data bytes|
|    2 |    6 | Signed Flag        | Flag indicating the data is signed |
|    2 |    7 | Spare              | Spare                              |
|    n |  n*8 | Data               | Integer data                       |

### Float Setting

| Byte | Bits | Data               | Description                                |
|------|------|--------------------|--------------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name             |
|    2 |  0-3 | Setting type       | Type enumeration                           |
|    2 |  4-5 | Byte Num/Type Enum | Indicates bytes of scaled data or unscaled |
|    2 |  6-7 | Resolution Enum    | If scaling, denotes resolution used        |
|    n |  8*n | Data               | Scaled/unscaled float data                 |

### String Setting

| Byte | Bits | Data               | Description                                                                        |
|------|------|--------------------|------------------------------------------------------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name                                                     |
|    2 |  0-3 | Setting type       | Type enumeration                                                                   |
|    2 |  4-7 | Data Byte Count 1  | Number of bytes of data. If set to 15, then another byte of count data will follow |
|    3 |  0-7 | Data Byte Count 2  | [OPTIONAL] If previous field was 15 this is included and data count is sum of both |
|   3+ |  n*8 | String Data        | String data of count described                                                     |

### Vec2 Setting

| Byte | Bits | Data               | Description                           |
|------|------|--------------------|---------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name        |
|    2 |  0-3 | Setting type       | Type enumeration                      |
|    2 |  4-5 | Byte Number Enum X | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    2 |  6-7 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    3 |  0-1 | Byte Number Enum Y | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    3 |  2-3 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    3 |  4-7 | Spare              | Spare                                 |
|    n |  n*8 | Data X             | Scaled float data X                   |
|    n |  n*8 | Data Y             | Scaled float data Y                   |

### Vec3 Setting

| Byte | Bits | Data               | Description                           |
|------|------|--------------------|---------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name        |
|    2 |  0-3 | Setting type       | Type enumeration                      |
|    2 |  4-5 | Byte Number Enum X | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    2 |  6-7 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    3 |  0-1 | Byte Number Enum Y | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    3 |  2-3 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    3 |  4-5 | Byte Number Enum Z | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    3 |  6-7 | Resolution Enum Z  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    n |  n*8 | Data X             | Scaled float data X                   |
|    n |  n*8 | Data Y             | Scaled float data Y                   |
|    n |  n*8 | Data Z             | Scaled float data Y                   |

### Vec4 Setting

| Byte | Bits | Data               | Description                           |
|------|------|--------------------|---------------------------------------|
|  0-1 | 0-15 | VarName hash       | Hash of settings variable name        |
|    2 |  0-3 | Setting type       | Type enumeration                      |
|    2 |  4-5 | Byte Number Enum X | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    2 |  6-7 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    3 |  0-1 | Byte Number Enum Y | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    3 |  2-3 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    3 |  4-5 | Byte Number Enum Z | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    3 |  6-7 | Resolution Enum Z  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    4 |  0-1 | Byte Number Enum W | 0=0byte; 1=1bytes; 2=2bytes; 3=4bytes |
|    4 |  2-3 | Resolution Enum W  | 0=0.001; 1=0.01; 2=0.1; 3=1.0         |
|    4 |  4-7 | Spare              | Spare                                 |
|    n |  n*8 | Data X             | Scaled float data X                   |
|    n |  n*8 | Data Y             | Scaled float data Y                   |
|    n |  n*8 | Data Z             | Scaled float data Y                   |
|    n |  n*8 | Data W             | Scaled float data Y                   |

## Data Coherency

The following steps are taken to verify the integrity of serialized settings before applying them to a plugin:

* The serialized hash of the plugin ID is compared against the target plugin
* The number of settings saved is compared against the current number of settings
    * If there is a mismatch in these settings count, the serialization *may* still proceed
* Each setting is then read from the file until the end is reached
* An attempt is made to uniquely correlate the variable name hash and type to an associated setting in the target plugin
    * If this correlation reaches a defined level of confidence, the settings are applied to the plugin
