#INCLUDE "HSPAHAC1.ch"
#include "protheus.CH"
#include "colors.CH"
#include "topconn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHAC1  º Autor ³ Monica/Wiliam      º Data ³	Agosto/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Orgao Emissor                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHAC1()
 Private cTab := "64"
 Private cAlias := "SX5"
 Private cCadastro := STR0001 //"Orgao Emissor"
 Private nOpc    := 0
 Private aRotina := {{OemToAnsi(STR0002 ), "axPesqui"   , 0, 1}, ; //"Pesquisar"
                     {OemToAnsi(STR0003), 'HS_AC1(2)', 0, 2}, ; //"Visualizar"
                     {OemToAnsi(STR0004   ), 'HS_AC1(3)', 0, 3}, ; //"Incluir"
                     {OemToAnsi(STR0005   ), 'HS_AC1(4)', 0, 4, 2}, ; //"Alterar"
                     {OemToAnsi(STR0006   ), 'HS_AC1(5)', 0, 5, 1}} //"Excluir"

 DbSelectArea(cAlias)
 DbSetOrder(1)
 mBrowse(06, 01, 22, 75, "SX5",,,,,,,,,,,,,, "X5_TABELA = '"+cTab+"'")
 
 Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HS_AC1   ³ Autor ³  Monica/Wiliam        ³ Data ³15/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Inclusao/Alteracao/Visualizacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_AC1(nOpc)

 cSayCpo1 := STR0007 //"Orgao Emissor"
 cSayCpo2 := STR0008 //"Descricao"

 HS_TelSx5('HS_EXC1()','HS_CkC1()',nOpc,3,Replicate("!",3))

Return

Function HS_CkC1()                            
	If len(Trim(M->X5_CHAVE)) > 3
  HS_MsgInf(STR0014, STR0010, STR0012) //"Quantidade de dígitos do Órgão Emissor deve ser 3"###"Atencao"###"Validacao dos Campos"
  Return(.F.)
	Endif
 If DbSeek(xFilial("SX5") + "64" + M->X5_CHAVE)
  HS_MsgInf(STR0009, STR0010, STR0012) //"Orgao Emissor ja cadastrado"###"Atencao"###"Validacao dos Campos"
  Return(.F.)
 Endif
Return(.T.)
                                                                                                     
// Funcao de Exclusao
Function HS_EXC1()                         
 Local lRet := .T., cAliasOld := Alias()
	cSql := "SELECT COUNT(*) AS Reg"
	cSql += " FROM "                         
	cSql += " " + RetSqlName("GBH") + " GBH"
	cSql += " WHERE"
	cSql += " GBH.GBH_ORGEMI = '" + Trim(M->X5_CHAVE) + "' AND GBH.D_E_L_E_T_ <> '*'" 
	//cSql := ChangeQuery(cSql)
	TCQUERY cSql NEW ALIAS "TMPPAC"
	
 DbSelectArea("TMPPAC")

 If TMPPAC->Reg > 0
  HS_MsgInf(STR0011, STR0010, STR0013) //"Existe um paciente cadastrado com este Orgao Emissor. Impossivel Exclui-lo!"###"Atencao"###"Exclusao nao permitida"
  lRet := .F.
 EndIf                 

	DbCloseArea()
 DbSelectArea(cAliasOld)
 
 If lRet 
  nOpca := 1
  oDlg:End()          
 EndIf
Return(lRet)