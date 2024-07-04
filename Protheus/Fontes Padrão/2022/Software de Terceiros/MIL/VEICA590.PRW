// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "veica590.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ VEICA590 ³ Autor ³  Fabio                ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Bolsa de Veiculos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA590

PRIVATE aMemos := {{"VC4_OBSMEM","VC4_OBSERV"}}
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006) //"Bolsa de Veiculos" 
                                            
////////////////////////////////////////////////////////
// CRIADO GATILHO PARA LIMPAR AS VARIAVEIS DE MEMORIA //
// RAFAEL GONCALVES - FNC 17666/2009 - 24/08/2009	  //
////////////////////////////////////////////////////////
//dbSelectArea("SX3")
//dbSetOrder(2)
//If dbSeek("VC4_VEI_CV")
//	If SX3->X3_TRIGGER == " "
//		RecLock("SX3",.f.)
//			SX3->X3_TRIGGER := "S"
//   		MsUnlock()
//    Endif
//Endif

//////////////////////////////////////////////////////////////////////
// BOBY - FNC 3999 - VERSAO 11 ->SX7->X7_REGRA FOI ALTERADO, POIS NAO 
//        DEIXAVA PASSAR VC4_VEI_CV QUANDO ERA OPCAO "0" - 03/03/2010

/*dbSelectArea("SX7")
dbSetOrder(1)
If !dbSeek("VC4_VEI_CV"+"001")
	RecLock("SX7",.T.)
Else
	RecLock("SX7",.F.)
EndIf		
SX7->X7_CAMPO	:= "VC4_VEI_CV"
SX7->X7_SEQUENC	:= "001"
SX7->X7_REGRA	:= "IIF(M->VC4_VEI_CV=='"+'0'+"', M->VC4_CHASSI:=SPACE(LEN(VC4->VC4_CHASSI)),)"
SX7->X7_CDOMIN	:= "VC4_CHASSI"
SX7->X7_TIPO	:= "P"
SX7->X7_SEEK	:= "N"
SX7->X7_ALIAS	:= ""
SX7->X7_ORDEM	:= 0
SX7->X7_CHAVE	:= ""
SX7->X7_CONDIC	:= "" 
SX7->X7_PROPRI	:= "S"
MsUnlock()

If !dbSeek("VC4_VEI_CV"+"002")
	RecLock("SX7",.T.)
Else
	RecLock("SX7",.F.)
EndIf	
SX7->X7_CAMPO 	:= "VC4_VEI_CV"
SX7->X7_SEQUENC := "002"
SX7->X7_REGRA 	:= "IIF(M->VC4_VEI_CV=='"+'0'+"', M->VC4_CHASSI:=SPACE(LEN(VC4->VC4_PLAVEI)),)"
SX7->X7_CDOMIN 	:= "VC4_PLAVEI"
SX7->X7_TIPO 	:= "P"
SX7->X7_SEEK 	:= "N"
SX7->X7_ALIAS 	:= ""
SX7->X7_ORDEM 	:= 0
SX7->X7_CHAVE 	:= ""
SX7->X7_CONDIC 	:= "" 
SX7->X7_PROPRI 	:= "S" 
MsUnlock()
*/
////////////////////////////////////////////////////////
//		F I M   D A   A L T E R A C A O      		  //
////////////////////////////////////////////////////////
                 

DbSelectArea("VC4")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VC4")

Return


********************************
Function VA590V(cAlias,nReg,nOpc)

RCAMPO590()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return


********************************
Function VA590I(cAlias,nReg,nOpc)

RCAMPO590()
AxInclui(cAlias,nReg,nOpc,aCampos)

Return

********************************
Function VA590A(cAlias,nReg,nOpc)

RCAMPO590()
AxAltera(cAlias,nReg,nOpc,aCampos)

Return

********************************
Function VA590E(cAlias,nReg,nOpc)

RCAMPO590()
AxDeleta(cAlias,nReg,nOpc,aCampos)

Return

*******************
Function RCAMPO590()

DbSelectArea("SX3")        
DbSetOrder(1)
dbseek("VC4")
aCampos := {}

do While !eof() .and. x3_arquivo == "VC4"

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      aadd(aCampos,x3_campo)
   EndIf

   dbskip()

Enddo
DbSelectArea("VC4")

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0 , 1},;    //"Pesquisar"
                     { STR0002 ,"VA590V", 0 , 2},;    //"Visualizar"
                     { STR0003 ,"VA590I", 0 , 3},;    //"Incluir"
                     { STR0004 ,"VA590A", 0 , 4},;    //"Alterar"
                     { STR0005 ,"VA590E", 0 , 5} }    //"Excluir"
Return aRotina
