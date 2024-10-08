// 浜様様様曜様様様様�
// � Versao �  04    �
// 藩様様様擁様様様様�

#Include "PROTHEUS.CH"
#Include "VEIVM170.CH"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VEIVM170 � Autor � Andre Luis Almeida    � Data � 26/10/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Atualiza Codigo do Indice e Carencia na Entrada de Veiculo 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos ( Entrada -> VVG )                                咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVM170()
Private cCadastro := STR0001 // Atualiza Codigo do Indice e Carencia na Entrada de Veiculo
Private aRotina   := MenuDef()
FilBrowse( "VV1" , {} , "VV1->VV1_GRASEV<>'6' .and. VM170FBROW()" ) 	// Filtra Browse
mBrowse( 6, 1,22,75,"VV1")
DbSelectArea("VV1")
dbClearFilter()
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �VM170FBROW� Autor � Andre Luis Almeida    � Data � 26/10/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Filtra o Browse do Veiculo VV1                             咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VM170FBROW()
Local lRet := .f.            
If VV1->VV1_SITVEI=="0" .and. !Empty(VV1->VV1_TRACPA) // Veiculo em Estoque
	VVG->(DbSetOrder(1))
	If VVG->(DbSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA+VV1->VV1_CHAINT)) // Veiculo possui Entrada
		lRet := .t.
	EndIf
EndIf
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VM170ALT � Autor � Andre Luis Almeida    � Data � 26/10/11 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Altera Codigo do Indice e Carencia da Entrada de Veiculo   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VM170ALT()
Local aParamBox := {}
Local aRet      := {}
If Empty(VV1->VV1_FILENT+VV1->VV1_TRACPA)
	MsgStop(STR0003,STR0002) // Veiculo sem registro de entrada! / Atencao
Else
	DbSelectArea("VVG")
	DbSetOrder(1) // VVG_FILIAL + VVG_TRACPA + VVG_CHAINT
	If !DbSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
		MsgStop(STR0004,STR0002) // Entrada n�o encontrada! / Atencao
	Else
		VVF->(DbSetOrder(1))
		VVF->(DbSeek(VVG->VVG_FILIAL+VVG->VVG_TRACPA))
		AADD(aParamBox,{1,STR0005,VVG->VVG_TRACPA,"@!","","",".F.",60,.f.})				// 1 - Transacao de Compra
		AADD(aParamBox,{1,STR0006,VVF->VVF_NUMNFI,"@!","","",".F.",60,.f.})				// 2 - Nro NF
		AADD(aParamBox,{1,STR0007,VVF->VVF_SERNFI,"@!","","",".F.",30,.f.})				// 3 - Serie NF
		AADD(aParamBox,{1,STR0012,VVG->VVG_CHASSI,"@!","","",".F.",80,.f.})				// 4 - Chassi
		AADD(aParamBox,{1,STR0008,VVG->VVG_VCNVEI,"@E 999,999,999.99","","",".F.",60,.f.})// 5 - Valor
		AADD(aParamBox,{1,STR0009,VVG->VVG_CODIND,"@!","","",".F.",30,.f.})				// 6 - Codigo anterior do Indice
		AADD(aParamBox,{1,STR0010,space(len(VVG->VVG_CODIND)),"@!",'vazio().or.FG_Seek("VVH","MV_PAR07",1,.f.,"MV_PAR08","VVH_DIACAR")',"VVH","",30,.f.}) // 7 - Codigo atual do Indice
		AADD(aParamBox,{1,STR0011,VVG->VVG_DIACAR,"@E 999",'MV_PAR08>=0',"","",30,.f.})	// 8 - Dias de Carencia
		If ParamBox(aParamBox,STR0014,@aRet,,,,,,,,.f.) // Alterar
			DbSelectArea("VVG")
			RecLock("VVG",.f.)
				If !Empty(aRet[7])
					VVG->VVG_CODIND := aRet[7] // Codigo atual do Indice
				EndIf
				VVG->VVG_DIACAR := aRet[8] // Dia de Carencia
			MsUnLock()
		EndIf
	EndIf
	DbSelectArea("VV1")
EndIf
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � MenuDef  � Autor � Andre Luis Almeida    � Data � 30/03/10 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Menu (AROTINA)                                             咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := {	{STR0013,"AxPesqui"	,0,1},;		// Pesquisar
					{STR0014,"VM170ALT"	,0,4}}		// Alterar
Return aRotina