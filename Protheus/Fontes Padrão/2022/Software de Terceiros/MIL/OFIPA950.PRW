// 浜様様様曜様様様様�
// � Versao � 02     �
// 藩様様様擁様様様様�
#INCLUDE "ofipa950.ch"
#INCLUDE "protheus.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIPA950 � Autor �  Fabio                � Data � 13/07/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Marcas                                                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � (Pecas)                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION OFIPA950

PRIVATE cCadastro := OemToAnsi(STR0001) //"Marcas"

Private cFiltroVX5 := "028"

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
axCadastro("VE1", cCadastro,"OFIPA950EX()")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �OFIPA950EX� Autor � Eduardo Motta         � Data � 02/10/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Valida se pode ser feito a exclusao                        咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIPA950EX()
Local aArquivos := {}

aadd(aArquivos,{"VE2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VE5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VEI",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VEJ",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF7",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VF8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG3",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG9",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VGA",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VGB",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VGC",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH3",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH4",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VH6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI0",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI1",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI3",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI4",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI5",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI6",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI7",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VI9",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VIA",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VIB",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VIC",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VO7",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VO8",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VOC",2, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VOS",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VV1",3, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VV2",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VVC",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VVK",1, VE1->VE1_CODMAR,})
aadd(aArquivos,{"VVP",1, VE1->VE1_CODMAR,})

aadd(aArquivos,{"VC3","VC3_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VC6","VC6_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VFC","VFC_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VFD","VFD_CODMAR",VE1->VE1_CODMAR,})
aadd(aArquivos,{"VG4","VG4_CODMAR",VE1->VE1_CODMAR,})

Return FG_DELETA(aArquivos)

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)