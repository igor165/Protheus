#Include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ Fa087COL ³ AUTOR ³ Lucas                 ³ DATA ³ 06.02.01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Ponto de Entrada permitir que o usuario configure o posiciona- ³±±
±±³ 		 ³ mento das colunas na MarkBrowse de Selecao dos Títulos para  - ³±±
±±³ 		 ³ Cobranzas.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ FINA087 y FINA097 Recibos e Pré-Recibos                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Fa087Col()
Local aCampos1 := {}

SX3->(dbSetOrder(2))

aCampos1:={}
Aadd(aCampos1,{"OK"      ,""," "})

SX3->(dbSeek("E1_PREFIXO"))
Aadd(aCampos1,{"PREFIXO" ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_NUM"))
Aadd(aCampos1,{"NUM"     ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_SALDO"))
Aadd(aCampos1,{"SALDO"   ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_MOEDA"))
Aadd(aCampos1,{"MOEDA"   ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_VALOR"))
Aadd(aCampos1,{"VALOR"   ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

AADD(aCampos1,{"MOETIT"  ,"",OemToAnsi("Moeda Titulo")    ,PesqPict("SE1","E1_VALOR")})

AADD(aCampos1,{"VLOTRMOE","",OeMToAnsi("Vlr. Otra Moneda"),PesqPict("SE1","E1_VALOR")})

AADD(aCampos1,{"MOEDACOB","",OemToAnsi("Otra Moneda")})

SX3->(dbSeek("E1_TIPO"))
Aadd(aCampos1,{"TIPO"    ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_VLCRUZ"))
Aadd(aCampos1,{"VLCRUZ"  ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_EMISSAO"))
Aadd(aCampos1,{"EMISSAO" ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_VENCREA"))
Aadd(aCampos1,{"VENCREA" ,"",SX3->X3_TITULO,SX3->X3_PICTURE})

SX3->(dbSeek("E1_NATUREZ"))
Aadd(aCampos1,{"NATUREZA","",SX3->X3_TITULO,SX3->X3_PICTURE})

Aadd(aCampos1,{"DIF_1","","Dif.Cambio +"}) //"Val. Orig."

Aadd(aCampos1,{"DIF_2","","Dif.Cambio -"}) //"Val. Orig."

Aadd(aCampos1,{"MOTIVO","","Motivo"})
SX3->( dbSetOrder(1) )

Return( aCampos1 )
