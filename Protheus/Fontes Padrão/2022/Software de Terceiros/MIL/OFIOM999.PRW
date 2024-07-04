#INCLUDE "ofiom999.ch"


FUNCT OFIOM999

Private aRotina := { { OemToAnsi(ST0002), "axPesqui", 0, 1},;
                     { OemToAnsi(ST0003), "Vm030"	, 0, 2},;
                     { OemToAnsi(ST0004), "Vm030"	, 0, 3},;
                     { OemToAnsi(ST0005), "Vm030"	, 0, 4},;
                     { OemToAnsi(ST0006), "Vm030"	, 0, 5} }



Private cCadastro := OemToAnsi(STR0001) //"Lancto de Despesas com o Veiculo"


mBrowse( 6,1,22,75,"VV1")

Return


FUNCT Vm999()

return
