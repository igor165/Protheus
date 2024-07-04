// 浜様様様曜様様様様�
// � Versao �  02    �
// 藩様様様擁様様様様�


#INCLUDE "VEIVA310.CH"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VEIVA310 � Autor �  Manoel               � Data � 15/06/05 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Faixas e Percentuais de Comissao               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA310()
Private aRotina   := MenuDef()
Private cCadastro := STR0001  //Cadastro de Faixas e Percentuais de Comissao
Private cMapSXB   := ""  // Variavel private utilizada no SXB -> VOQ
Private cTipAva   := "1" // Variavel private utilizada no SXB -> VS5

mBrowse( 6, 1,22,75,"VZ8",,,,,,)

Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VA310MAPA � Autor � Andre Luis Almeida   � Data � 22/12/11 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Carrega variavel private cMapSXB, utilizada no SXB VOQ     咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA310MAPA()
Local lRet := .t.
If !Empty(M->VZ8_MAPRES)
	VS5->(DbSetOrder(1))
	If !VS5->(DbSeek(xFilial("VS5")+M->VZ8_MAPRES))
		lRet := .f.
	EndIf
EndIf
cMapSXB := M->VZ8_MAPRES // Variavel private utilizada no SXB -> VOQ
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VA310MODV � Autor � Andre Luis Almeida   � Data � 27/12/11 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao do Modelo do Veiculo                             咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VA310MODV()
Local lRet := .t.
If VV2->VV2_MODVEI == M->VZ8_MODVEI
	M->VZ8_CODMAR := VV2->VV2_CODMAR
	M->VZ8_GRUMOD := VV2->VV2_GRUMOD
Else
	lRet := .f.
	If !Empty(M->VZ8_CODMAR)
		If FG_Seek("VV2","M->VZ8_CODMAR+M->VZ8_MODVEI",1,.f.)
			M->VZ8_GRUMOD := VV2->VV2_GRUMOD
			lRet := .t.
		EndIf
	EndIf
	If !lRet
		If FG_Seek("VV2","M->VZ8_MODVEI",4,.f.)
			M->VZ8_CODMAR := VV2->VV2_CODMAR
			M->VZ8_GRUMOD := VV2->VV2_GRUMOD
			lRet := .t.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao    � MenuDef  � Autor � Andre Luis Almeida   � Data � 22/12/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao � Menu (AROTINA)                                            咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Static Function MenuDef()
Local aRotina := {	{STR0002,"AxPesqui"	,0,1},; // Pesquisar
					{STR0003,"AxVisual"	,0,2},; // Visualizar
					{STR0004,"AxInclui"	,0,3},; // Incluir
					{STR0005,"VA310ALT"	,0,4},; // Alterar
					{STR0006,"VA310DEL"	,0,5}}  // Excluir
Return aRotina

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao    � VA310ALT � Autor � Andre Luis Almeida   � Data � 22/12/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao � Alteracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VA310ALT(cAlias,nReg,nOpc)
Local nRecVD2 := FM_SQL("SELECT VD2.R_E_C_N_O_ AS RECVD2 FROM "+RetSQLName("VD2")+" VD2 WHERE VD2.VD2_FILIAL='"+xFilial("VD2")+"' AND VD2.VD2_COMPRE='1' AND VD2.VD2_CDCMPR='"+VZ8->VZ8_CODCOM+"' AND VD2.D_E_L_E_T_=' '")
If nRecVD2 <= 0
	cMapSXB := VZ8->VZ8_MAPRES // Variavel private utilizada no SXB -> VOQ
	AxAltera(cAlias,nReg,nOpc)
Else
	MsgStop(STR0008,STR0007) // Comissao ja utilizada. Impossivel ALTERAR o cadastro! / Atencao
EndIf
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao    � VA310DEL � Autor � Andre Luis Almeida   � Data � 22/12/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao � Exclusao                                                  咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function VA310DEL(cAlias,nReg,nOpc)
Local aVetValid := {}
Aadd(aVetValid,{ "VD2" , "VD2_COMPRE + VD2_CDCMPR" , '1' + VZ8->VZ8_CODCOM  , NIL })
If FG_DELETA(aVetValid)
	AxDeleta(cAlias,nReg,nOpc)
EndIf
Return