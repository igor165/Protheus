#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA560.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fata560   �Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Amarracao entre Componentes e Tipos de Tarefa               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fata560()

Local aCores	:={	{"ADT->(DbSeek(ADS->(ADS_FILIAL+ADS_CODIGO)))" , 'BR_VERDE'},;
					{"!ADT->(DbSeek(ADS->(ADS_FILIAL+ADS_CODIGO)))", 'BR_PRETO'}}

Private cCadastro := STR0001//"Componentes x Tp. Tarefa"
Private aRotina := MenuDef()	
Private cDelFunc := ".F."

If !SX2->(DbSeek("ADT"))
	MsgStop(STR0002) //"Execute o update U_TKUPDADM antes de acessar esta rotina"
	Return Nil
EndIf

ADT->(DbSetOrder(1))
dbSelectArea("ADS")
dbSetOrder(1)

mBrowse( 6,1,22,75,"ADS",,,,,,aCores)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft560Edit �Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de edicao da amarracao entre componentes e tipos de  ���
���          �tarefa.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft560Edit(cAlias, nReg, nOpc)

Local aArea		:= GetArea()
Local aObjects	:= {}
Local aSize		:= {}
Local aInfo		:= {}
Local oDlg		:= Nil
Local oEnch		:= Nil
Local aField	:= {}
Local lMemoria	:= .T.  
Local cDelOk    := "AllWaysTrue()" 
Local cSeek		:= ""
Local aColsGd	:= {}
Local aHeadGd	:= {}
Local aYesFields:= {} 
Local bWhile	:= Nil
Local nX		:= 0
Local nItem		:= 0
Local aRecnos	:= {}
Local nPRec		:= 0 
Local nRecAtu	:= 0 
Local cFilADT	:= xFilial("ADT") 
Local nPosCmp	:= 0
Local nOpcA		:= 0
Local nGdOpc	:= IIf(INCLUI .OR. ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0)
Local cQueryAE1 := ""
Local cAliasAE1 := ""
                     
aField 		:= Ft560RetCp()
aYesFields	:= {"ADT_CODCMP","ADT_DSCCMP"}

ADT->(DbSetOrder(1))
ADT->(DbSeek(cFilADT+ADS->ADS_CODIGO))

#IFDEF TOP
	If nOpc == 4 
		cQueryAE1 := "SELECT AE1_COMPOS "
		cQueryAE1 += "FROM "+RetSqlName("AE1")+" AE1 "
		cQueryAE1 += "WHERE AE1.AE1_FILIAL='"+xFilial("AE1")+"' AND "
		cQueryAE1 += "AE1.AE1_TPTARE='"+ADS->ADS_CODIGO+"' AND "
		cQueryAE1 += "AE1.D_E_L_E_T_=' ' "
		cQueryAE1 += "ORDER BY AE1_COMPOS" 
		
		cAliasAE1 := GetNextAlias()	
		cQueryAE1 := ChangeQuery(cQueryAE1)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAE1),cAliasAE1,.T.,.T.)
		If !Empty((cAliasAE1)->AE1_COMPOS)
	   		MSGSTOP(STR0013 + " :" +(cAliasAE1)->AE1_COMPOS + " .")
	   		Return .F.
	    EndIf  
	EndIf    
#ENDIF
//������������������������������������������������������������������������Ŀ
//�Inicializa as variaveis da Enchoice e GetDados                          �
//��������������������������������������������������������������������������
RegToMemory( "ADT", .F., .F. )
M->ADT_CODTAR	:= ADS->ADS_CODIGO
M->ADT_DSCTAR	:= ADS->ADS_DESCRI

cSeek 		:= cFilADT+ADS->ADS_CODIGO
bWhile 		:= {||ADT->ADT_FILIAL + ADT->ADT_CODTAR}

FillGetDados(aRotina[nOpc][4],"ADT",1,cSeek,bWhile,,,aYesFields,,,,,@aHeadGD,@aColsGD,{|a,b|Ft560AfCol(a,b)})

//������������������������������������������������������Ŀ
//� Faz o calculo automatico de dimensoes de objetos     �
//��������������������������������������������������������
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

oEnch	:= MsMGet():New("ADT",nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,lMemoria,,,,,aField)
oGetD	:= MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nGdOpc,,,,,,512,,,cDelOk,oDlg,aHeadGd,aColsGd)

oGetD:lDelete	:= INCLUI .OR. ALTERA
oGetD:bLinhaOk	:= {||Ft560LinOk(@oGetD)}
oGetD:bTudoOk	:= {||Ft560TudOk(@oGetD)}
oGetD:cFieldOk	:= "Ft560FOk(@oGetD)"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(oGetD:TudoOk(),If(.F.,nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()})

If (nOpcA == 1) .AND. (aRotina[nOpc][4] <> 2)

	nPosCmp	:= aScan(oGetD:aHeader,{|x|AllTrim(x[2]) == "ADT_CODCMP" })
	nPRec	:= aScan(oGetD:aHeader,{|x|AllTrim(x[2]) == "ADT_REC_WT" })
	   
	DbSelectArea("ADT")
	DbSetOrder(1)
    
	If aRotina[nOpc][4] <> 5 //Alteracao e inclusao

		//��������������������������������Ŀ
		//�Armazena os recnos ja utilizados�
		//�e apaga os registros deletados. �
		//����������������������������������
		For nX := 1 to Len(oGetD:aCols)
			If oGetD:aCols[nX][nPRec] > 0
				If !aTail(oGetD:aCols[nX])
					AAdd(aRecnos,oGetD:aCols[nX][nPRec])
				Else
					ADT->(DbGoTo(oGetD:aCols[nX][nPRec]))
					RecLock("ADT",.F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		Next nX  
		
		//�����������������������������
		//�Gravacao das linhas validas�
		//�����������������������������
		For nX := 1 to Len(oGetD:aCols)
	
			If !aTail(oGetD:aCols[nX])
	
				nItem++
	
				If nItem <= Len(aRecnos)
					ADT->(DbGoTo(aRecnos[nItem]))
					RecLock("ADT",.F.)
				Else
					RecLock("ADT",.T.)
				EndIf
	            
	            Replace	ADT->ADT_FILIAL	With cFilADT
	            Replace ADT->ADT_CODTAR	With M->ADT_CODTAR
	            Replace ADT->ADT_CODCMP	With oGetD:aCols[nX][nPosCmp]
	            
				MsUnLock()
				
			EndIf
	
		Next nX
	Else //Exclusao

		aRecnos := {}
		ADT->(DbSeek(cFilADT+M->ADT_CODTAR))
		
		//������������������������������������Ŀ
		//�Armazena os recnos a serem deletados�
		//��������������������������������������
		While !ADT->(Eof()) .AND.;
			ADT->ADT_FILIAL == cFilADT .AND.;
			ADT->ADT_CODTAR == M->ADT_CODTAR
			
			AAdd(aRecnos,ADT->(Recno()))
			
			ADT->(DbSkip())			
		End
		
		//���������������������������Ŀ
		//�Deleta os registros na base�
		//�����������������������������
		For nX := 1 to Len(aRecnos)
			ADT->(DbGoTo(aRecnos[nX]))
			RecLock("ADT",.F.)
			DbDelete()
			MsUnLock()
		Next nX
	
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft560Leg  �Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda da rotina                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft560Leg()

Local aLegenda := {	{"BR_VERDE"		, STR0004	},;		//"Configurado"
					{"BR_PRETO"  	, STR0005	}}		//"Nao configurado"

BrwLegenda(cCadastro,STR0003,aLegenda)  //"Componente x Tarefa"

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Utilizacao do menu funcional                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRet	:= {{STR0006	,"AxPesqui"		,0,1},;		//"Pesquisar"
				{STR0007	,"Ft560Edit"	,0,2},;		//"Visualizar"
				{STR0008	,"Ft560Edit"	,0,4},;		//"Configurar"
				{STR0009	,"Ft560Edit"	,0,5},;		//"Exc.Config."
				{STR0010	,"Ft560Leg"		,0,2}}		//"Legenda"
Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft560RetCp�Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Campos a serem exibidos na getdados                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft560RetCp()
Local aCampos 	:= {}
Local aSArea	:= GetArea()
Local cCampos	:= "ADT_CODTAR/ADT_DSCTAR"

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("ADT") 
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "ADT"
		If X3USO(SX3->X3_USADO) .AND. (Alltrim(Upper(SX3->X3_CAMPO)) $ cCampos)
		   	Aadd( aCampos, {X3Titulo(),;
							SX3->X3_CAMPO,;
							SX3->X3_TIPO,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_PICTURE,;
							&("{||" + AllTrim(SX3->X3_VALID)+ "}"),;
							X3Obrigat(SX3->X3_CAMPO),;
							SX3->X3_NIVEL,;
							SX3->X3_RELACAO,;
							SX3->X3_F3,;
							&("{||" + AllTrim(SX3->X3_WHEN) + "}"),;
							SX3->X3_VISUAL=="V",;
							.F.,; 
							SX3->X3_CBOX,;
							VAL(SX3->X3_FOLDER),;
							.F.,;
							""} )
		Endif
		SX3->(DbSkip())
	End
Endif

RestArea(aSArea)

Return aCampos

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft540AfCol�Autor  �Vendas Clientes     � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa campos virtuais do aCols                         ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft560AfCol(aCols,aHeader)

Local aArea		:= GetArea()
Local nPos		:= Len(aCols)
Local nPDesc	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADT_DSCCMP"})
Local nPCod		:= aScan(aHeader,{|x|AllTrim(x[2])== "ADT_CODCMP"})

aCols[nPos][nPDesc]	:= Posicione("ADR",1,xFilial("ADR")+aCols[nPos][nPCod],"ADR_DESCRI")

RestArea(aArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft560LinOk�Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao de linha da getdados                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft560LinOk(oGetD)

Local nX	:= 0
Local nPCod	:= aScan(oGetD:aHeader,{|x|AllTrim(x[2])=="ADT_CODCMP"})
Local lRet	:= .T.

If !aTail(oGetD:aCols[oGetD:nAt])
	For nX := 1 to Len(oGetD:aCols)
		If	(nX <> oGetD:nAt) .AND. !aTail(oGetD:aCols[nX]) .AND.;
			(oGetD:aCols[nX][nPCod] == oGetD:aCols[oGetD:nAt][nPCod])
			
			lRet := .F.
			MsgStop(STR0011,STR0012)	//"O componente atual j� foi informado, favor corrigir."###"Atencao"
			
		EndIf
	Next nX
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft560TudOk�Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da getdados                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft560TudOk(oGetD)
Local lRet	:= Ft560LinOk(oGetD)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft560FOk  �Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao dos campos da GetDados                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA560                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft560FOk(oGetD)

Local nLin		:= oGetD:nAt
Local nPCod		:= aScan(oGetD:aHeader,{|x|AllTrim(x[2])=="ADT_CODCMP"})
Local nPDesc	:= aScan(oGetD:aHeader,{|x|AllTrim(x[2])=="ADT_DSCCMP"})

If AllTrim(ReadVar()) == "M->ADT_CODCMP"
	oGetD:aCols[nLin][nPDesc] := Posicione("ADR",1,xFilial("ADR")+M->ADT_CODCMP,"ADR_DESCRI")
EndIf

Return .T.
