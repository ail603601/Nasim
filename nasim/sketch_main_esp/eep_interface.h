#if !defined(EEP_INTERFACE_H)
#define EEP_INTERFACE_H
enum eeprom_adresses
{
  FLASH_CLEANED_1TIME,
  DEVICE_INITIALIZED

};

void save_eep(int addr, int val)
{
  EEPROM.write(addr, val);
  EEPROM.commit();
}
int read_eep(int addr)
{
  return EEPROM.read(addr);
}
void eep_clear()
{
  // write a 0 to all 512 bytes of the EEPROM
  for (int i = 0; i < 512; i++)
  {
    EEPROM.write(i, 0);
  }
}



#endif // EEP_INTERFACE_H
