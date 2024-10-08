#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA590.CH"
Static _nLastLin:= 0
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA590   � Autor �Vendas Clientes     � Data �  20/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Cadastro de perfis de contato                               ���
�������������������������������������������������������������������������͹��
���Uso       �FATA590                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FATA590()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

dbSelectArea("ADM")
dbSetOrder(1)

AxCadastro("ADM",STR0001,cVldExc,cVldAlt)//"Perfis de contato"  

Return Nil 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft590Perf �Autor  �Vendas Clientes     � Data �  20/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para selecao dos perfis do contato                     ���
�������������������������������������������������������������������������͹��
���Uso       �FATA590                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft590Perf(nOpc,cEnt,cCodigo,cLoja)

Local oDlg         
Local nSup	    	:= C(036)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsq	    	:= C(008)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInf	  	 	:= C(096)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDir	    	:= C(277)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem            
Local oLbx
Local oGd
Local nMax			:= 999
Local nOpcGD       	:= 0
Local aDadosSU5		:= {}
Local aColsCon		:= {}
Local aHeadPer		:= {}
Local aColsPer		:= {}
Local cSeek			:= ""
Local cEmpresa		:= ""
Local bWhile		:= Nil
Local oFont			:= Nil
Local cBLine		:= ""
Local nPosCont		:= 0
Local aColsBK		:= {}

Default nOpc		:= 4 

_nLastLin := 0

If Type("INCLUI") == "U"
	INCLUI	:= .F.
EndIf

If Type("ALTERA") == "U"
	ALTERA	:= .T.
EndIf

//���������������������������������������Ŀ
//�Permissao para altera itens na getdados�
//�����������������������������������������
If INCLUI .OR. ALTERA
	nOpcGd	:= GD_INSERT+GD_DELETE+GD_UPDATE
EndIf

//��������������������������������������������Ŀ
//�Nome do campo 'Descricao' para cada entidade�
//����������������������������������������������
Do Case
	Case cEnt == "SA1"
		cCampo	:= "A1_NOME"
	Case cEnt == "SA2"
		cCampo	:= "A2_NOME"
	Case cEnt == "AC4"
		cCampo	:= "AC4_NOME"
	Case cEnt == "ACH"
		cCampo	:= "ACH_RAZAO"
	Case cEnt == "SA4"
		cCampo	:= "A4_NOME"
	Case cEnt == "SU2"
		cCampo	:= "U2_CONCOR" 
	Case cEnt == "SUS"
		cCampo	:= "US_NOME"
EndCase

//���������������������Ŀ
//�Busca nome da empresa�
//�����������������������
cEmpresa := AllTrim(Capital(Posicione(cEnt,1,xFilial(cEnt)+cCodigo+cLoja,cCampo)))

Define Font oFont Name "Arial" Size 10,14 Bold

//��������������������������������������Ŀ
//�Carrega arrays da getdados de Contatos�
//���������������������������������������� 
aDadosSU5:= Ft590Head( @cBLine)
aColsCon := Ft590Cols(	cEnt , cCodigo	, cLoja	, aDadosSU5[2] )

//������������������������������������Ŀ
//�Carrega arrays da getdados de perfis�
//��������������������������������������     
nPosCont:= aScan(aDadosSU5[2],{|x|AllTrim(x)=="U5_CODCONT"})
cSeek 	:= 	xFilial("ADN")+aColsCon[1][nPosCont]
bWhile	:=	{||ADN->ADN_FILIAL+ADN->ADN_CODCON}

FillGetDados(nOpc,"ADN",1,cSeek,bWhile,,,,,,,,@aHeadPer,@aColsPer,{|a,b|Ft590AfCol(a,b)})

DEFINE MSDIALOG oDlg TITLE STR0001 FROM C(178),C(181) TO C(621),C(765) PIXEL // "Perfil dos contatos"

	@ C(023),C(004) TO C(105),C(287) LABEL STR0002 PIXEL OF oDlg // "Contatos"
	@ C(109),C(004) TO C(190),C(287) LABEL STR0001 PIXEL OF oDlg //"Perfis do contato"

	//ListBox - Contatos
	oLbx := TWBrowse():New(c(36),c(8),C(275),C(60) ,Nil,aDadosSU5[1],,oDlg,,,,;
			{||Ft590AtCol(@oGD,aColsCon,oLbx:nAt,nPosCont,nOpc,@aColsBk)},,,,,,,,,,.T.)
	oLbx:SetArray(aColsCon)
	oLbx:bLine := &("{||{"+ cBLine + "}}")

	//GetDados - Perfis
	oGD:= MsNewGetDados():New(nSup+96,nEsq,nInf+96,nDir,nOpcGD,;
			{||Ft590LinOk(oGD,oLbx)},,,,,nMax,,,,oDlg,aHeadPer,aColsPer) 

	oGD:oBrowse:bLostFocus := {||Ft590LinOk(oGd,oLbx)}

	@ C(010),C(010) Say cEmpresa Size C(200),C(008) COLOR CLR_BLUE PIXEL OF oDlg Font oFont
 
	DEFINE SBUTTON FROM C(200),C(230) TYPE 2 ENABLE OF oDlg Action(oDlg:End())
	DEFINE SBUTTON FROM C(200),C(260) TYPE 1 ENABLE OF oDlg Action(Ft590Grava(@oGd,@oLbx,@aColsBk,nPosCont),oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores � Norbert/Ernani/Mansano � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam) 

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor   

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//���������������������������Ŀ
//�Tratamento para tema "Flat"�
//�����������������������������
If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
	nTam *= 0.90
EndIf

Return Int(nTam)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft590Cols �Autor  �Vendas Clientes     � Data �  20/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o aCols de contatos para a entidade selecionada        ���
�������������������������������������������������������������������������͹��
���Uso       �TMKA070                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft590Cols(	cEnt	, cCodigo	, cLoja	, aFields)

Local aArea		:= GetArea()
Local aCol		:= {}
Local cFilAC8	:= xFilial("AC8")
Local cFilSU5	:= xFilial("SU5")
Local cFilEnt	:= xFilial(cEnt)
Local nX		:= 0
Local nLin		:= 0
Local cCampo	:= ""

DbSelectArea("SU5")
DbSetOrder(1)//U5_FILIAL+U5_CODCONT

DbSelectArea("AC8")
DbSetOrder(2)//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
DbSeek(cFilAC8+cEnt+cFilEnt+cCodigo+cLoja)

//�����������������������������������Ŀ
//�Busca todos os contatos da entidade�
//�������������������������������������
While AC8->(!Eof()) .AND. AllTrim(AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT)) == AllTrim(cFilAC8+cEnt+cFilEnt+cCodigo+cLoja)

	SU5->(DbSeek(cFilSU5+AC8->AC8_CODCON))

	AAdd(aCol, Array(Len(aFields)) )
	nLin++

	For nX := 1 to Len(aFields)
		aCol[nLin][nX] := SU5->&(aFields[nX])
	Next nX
	
	AC8->(DbSkip())

End

RestArea(aArea)

Return aCol

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft590Head �Autor  �Vendas Clientes     � Data �  21/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria lista de campos utilizados na listbox                  ���
�������������������������������������������������������������������������͹��
���Uso       �Fata590                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft590Head(cBLine)

Local aCpos	:= {}
Local aHead	:= {}
Local cSep	:= ""
Local nCont	:= 0

Default cBLine	:= ""

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SU5")

While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SU5"
	
	If X3Uso(SX3->X3_USADO) .AND. (cNivel >= SX3->X3_NIVEL) .AND. SX3->X3_CONTEXT <> "V"
		
		AAdd(aHead, X3Titulo())
		AAdd(aCpos,SX3->X3_CAMPO) 

		cBLine	+= cSep + "aColsCon[oLbx:nAt," + AllTrim(Str(++nCont)) + "]"
		cSep	:= ","
		
	EndIf
	
	SX3->(DbSkip())

End       

Return {aClone(aHead),aClone(aCpos)}


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA590   �Autor  �Vendas Clientes     � Data �  21/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza a getdados a cada troca de linha                   ���
�������������������������������������������������������������������������͹��
���Uso       �Fata590                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft590AtCol(	oGD		, aColsCon	, nLin	, nPosCont	,;
							nOpc	, aColsBk	)

Local cSeek 	:= 	xFilial("ADN")+AllTrim(aColsCon[nLin][nPosCont])
Local bWhile	:=	{||ADN->ADN_FILIAL+ADN->ADN_CODCON}
Local aDummy	:= {}
Local nPos		:= 0

//�����������������������Ŀ
//�Armazena aCols anterior�
//�������������������������
If _nLastLin <> 0
	nPos := aScan(aColsBk,{|x| x[1] == _nLastLin})
	    
	If nPos > 0  
		aColsBK[nPos][2] := aClone(oGd:aCols)
	Else
		AAdd(aColsBk,{_nLastLin,aClone(oGd:aCols)})
	EndIf
EndIf

//�������������������������������������Ŀ
//�Inicializa o aCols para a linha atual�
//���������������������������������������
nPos := aScan(aColsBk,{|x| x[1] == nLin})
    
If nPos > 0
	oGd:aCols	:= aClone(aColsBK[nPos][2])
Else
	oGD:aCols := {}
	FillGetDados(nOpc,"ADN",1,cSeek,bWhile,,,,,,,,aDummy,oGD:aCols,{|a,b|Ft590AfCol(a,b)})
EndIf

_nLastLin := nLin

oGd:Refresh()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft590LinOk�Autor  �Vendas Clientes     � Data �  21/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da linha da getdados                              ���
�������������������������������������������������������������������������͹��
���Uso       �Fata590                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft590LinOk(oGd,oLbx)

Local lRet 		:= F531ChkCol(oGd)
Local nX		:= 0
Local nPPerf	:= aScan(oGD:aHeader,{|x|AllTrim(x[2])=="ADN_CODPER"})

If lRet
	For nX := 1 to Len(oGd:aCols)
		If (oGd:nAt <> nX) .AND. !aTail(oGD:aCols[nX]) .AND. (oGD:aCols[nX][nPPerf] == oGD:aCols[oGd:nAt][nPPerf])
			lRet	:= .F.
			MsgStop(STR0003,STR0004)// "Este perfil ja foi incluido." , "Aten��o" 
		EndIf
	Next nX

EndIf

If !lRet
	oGd:oBrowse:SetFocus()
EndIf

Return lRet          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft590Grava�Autor  �Vendas Clientes     � Data �  21/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gravacao dos dados                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Fata590                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft590Grava(oGd,oLbx,aColsBk,nPosCont)

Local nPos 		:= aScan(aColsBk,{|x| x[1] == oLbx:nAt})
Local nX		:= 0
Local nY		:= 0
Local nPosRec	:= aScan(oGd:aHeader,{|x|AllTrim(x[2]) == "ADN_REC_WT"})
Local cFilADN	:= xFilial("ADN")
    
If nPos > 0  
	aColsBK[nPos][2] := aClone(oGd:aCols)
Else
	AAdd(aColsBk,{_nLastLin,aClone(oGd:aCols)})
EndIf
     
DbSelectArea("ADN")
DbSetOrder(1)

Begin Transaction

For nPos := 1 to Len(aColsBk)
	For nX := 1 to Len(aColsBk[nPos][2])
		If !aTail(aColsBk[nPos][2][nX])
	
	  		If aColsBk[nPos][2][nx][nPosRec] <> 0
	  			DbGoTo(aColsBk[nPos][2][nx][nPosRec])
	  			RecLock("ADN",.F.)
	  		Else
	  			RecLock("ADN",.T.)
	  		EndIf
	
		  	For nY := 1 to Len(oGd:aHeader)
		  		If oGd:aHeader[nY][10] <> "V"
					ADN->&(oGd:aHeader[nY][2]) := aColsBk[nPos][2][nx][nY]
				EndIf
		  	Next nY 
		  	
		  	ADN->ADN_FILIAL	:= cFilADN
		  	ADN->ADN_CODCON	:= oLbx:aArray[aColsBk[nPos][1]][nPosCont]
		  	
	  		MsUnLock()

		ElseIf (aColsBk[nPos][2][nx][nPosRec] <> 0)

  			DbGoTo(aColsBk[nPos][2][nx][nPosRec])
  			RecLock("ADN",.F.)
  			DbDelete()
  			MsUnLock()

		EndIf
	Next nX
Next nPos      

End Transaction

Return Nil
                                         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft590AfCol�Autor  �Vendas Clientes     � Data �  21/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa o campo virtual do acols                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Fata590                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft590AfCol(aCols,aHeader)

Local aArea		:= GetArea()
Local nX 		:= 0
Local cFilADM	:= xFilial("ADM")
Local nPPerf    := aScan(aHeader,{|x|AllTrim(x[2])=="ADN_CODPER"})
Local nPDesc    := aScan(aHeader,{|x|AllTrim(x[2])=="ADN_DESCRI"})

For nX := 1 to Len(aCols)
	aCols[nX][nPDesc]	:= Posicione("ADM",1,cFilADM+aCols[nX][nPPerf],"ADM_DESCRI")
Next nX

RestArea(aArea)

Return .T.
