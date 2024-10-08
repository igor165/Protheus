#INCLUDE "plsa226.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

STATIC cMatric := ""
STATIC lB40B49 := ( PLSALIASEXI("B40") .And. PLSALIASEXI("B49") )
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA226 � Autor � Alexander Santos	    � Data � 27.01.12 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualizacao do Cadastro de Usuarios WEB                    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA226(xAutoCab,xAutoItens,xOpcAuto,nReg)                                            
                                           
LOCAL aAliasItem 	:= { { "BSO","Prestador","PLSVLDLI('1')","PLSVLDDEL('1')",,,{||PLSVLDFOC('1')},,{||PLSINIDL(1)} } ,{ "B40","Empresa","PLSVLDLI('2')","PLSVLDDEL('2')",,,{||PLSVLDFOC('2')},,{||PLSINIDL(2)} } ,{"B49","Benefici�rio","PLSVLDLI('3')","PLSVLDDEL('3')",,,{||PLSVLDFOC('3')}}} 
LOCAL aKeyItem 	 	:= { "M->BSW_CODUSR","M->BSW_CODUSR","M->BSW_CODUSR" }
LOCAL aCondItem  	:= { "BSO_CODUSR","B40_CODUSR","B49_CODUSR" }
LOCAL aChavCab 	 	:= { {{"BSO_CODUSR","M->BSW_CODUSR"}},{{"B40_CODUSR","M->BSW_CODUSR"}},{{"B49_CODUSR","M->BSW_CODUSR"}}}
LOCAL nIndice		:= 0

PRIVATE aCols    	:= {}
PRIVATE aHeader  	:= {}
PRIVATE n        	:= 1                                                            
PRIVATE cCodInt 	:= PLSINTPAD()
PRIVATE cCodEmp 	:= ""
PRIVATE cCodConVer	:= ""
PRIVATE cCodRda 	:= ""
PRIVATE cCodPortal
Private aRotAdic := {"Alterar Senha" , "PLSPORSEN(Nil,'BSW_SENHA')", 0,2}

//���������������������������������������������������������������������������
//� Verifica se o alias existe
//���������������������������������������������������������������������������
If PLSALIASEXI("B95")
     aAdd(aAliasItem, {"B95","Atalhos Portal","PLSVLDLI('4')","PLSVLDDEL('4')",,, } )  
     aAdd(aKeyItem, "M->BSW_CODUSR" )
     aAdd(aCondItem, "B95_CODUSR")
     aAdd(aChavCab, {{"B95_CODUSR","M->BSW_CODUSR"}} ) 
     
    aAdd(aAliasItem,{"BX1","Historico de Acesso Portal","PLSVLDLI('5')","PLSVLDDEL('5')",,,.F.})
Else
	aAdd(aAliasItem,{"BX1","Historico de Acesso Portal","PLSVLDLI('4')","PLSVLDDEL('4')",,,.F.})
EndIf
aAdd(aKeyItem, "M->BSW_CODUSR" )
aAdd(aCondItem, "BX1_CODUSR")
aAdd(aChavCab, {{"BX1_CODUSR","M->BSW_CODUSR"}} )

If !lB40B49

	AxCadastro("BSW" ,STR0001,,,aRotAdic,,{|| Iif(Inclui ,(A226USRCOD(),PLSPORSEN(Nil,"BSW_SENHA")),.T.) } ) //"Usu�rios do Portal"
Else	
	//���������������������������������������������������������������������������
	//� CabItem
	//���������������������������������������������������������������������������
	IF BX1->(FieldPos("BX1_CODUSR")) > 0 .AND. BX1->(FieldPos("BX1_QTACES")) > 0 .AND. BSW->(FieldPos("BSW_DTSEN")) > 0
		nIndice := 6
	Else
		nIndice := 1
	ENDIF	
	PlsCabItem("BSW","Usuarios do Portal",aAliasItem,IIF(PLSALIASEXI("B95"),{1,1,1,1,nIndice},{1,1,1,nIndice}),aKeyItem,aCondItem,aChavCab,nil,nil,xAutoCab,xAutoItens,xOpcAuto,nReg,{|| Iif(Inclui,(A226USRCOD(),PLSPORSEN(Nil,"BSW_SENHA",.T.)),.T.) },nil,nil,nil,nil,nil,.T.,,.T.)
EndIf
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSCV     �Autor  �Microsiga           � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza variavel e campos								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSCV(cTp)
LOCAL lRet := .T.

Do Case
	Case cTp == '0'  
		cCodRda := M->BSO_CODIGO                   

	Case cTp == '1'
		cCodEmp := M->B40_CODEMP
		
	Case cTp == '2'
		cCodConVer := M->(B40_NUMCON+B40_VERCON)
		
	Case cTp == '3'
		cCodInt := PLSINTPAD()
		cCodEmp := M->B40_CODEMP

	Case cTp == '4'
 	cCodInt := PLSINTPAD()
	
	Case cTp == '5'
		cCodInt := PLSINTPAD()
EndCase		
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return(lRet)		
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSVLDFOC �Autor  �Microsiga           � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se e permitido edicao no folder					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSVLDFOC(cTp)
//���������������������������������������������������������������������������
//� Atualiza variavel privada
//���������������������������������������������������������������������������
cCodInt 	:= PLSINTPAD()                                                  
cCodRda 	:= BSO->BSO_CODIGO             
If !Empty(M->BSW_TPPOR)
    If M->BSW_TPPOR ==  '1'
       cCodPortal := "000008"
    Else 
       cCodPortal := "000010"     
    EndIf 
EndIf  
//���������������������������������������������������������������������������
//� Se a tabela existe
//���������������������������������������������������������������������������
If lB40B49
	cCodEmp 	:= B40->B40_CODEMP
	cCodConVer	:= B40->(B40_NUMCON+B40_VERCON)
EndIf	
//���������������������������������������������������������������������������
//� Verifica se o tipo de portal permite edicao para o folder
//���������������������������������������������������������������������������
If !Empty(M->BSW_TPPOR)
	If M->BSW_TPPOR != cTp
		If ValType(oEnchoice) == "O"
			oEnchoice:SetFocus()
		EndIf	                             
	EndIf
EndIf	
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return(.T.)                                                               
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSVLDLI  �Autor  �Microsiga           � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao na linha do browse								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSVLDLI(cTp)
LOCAL lRet 		:= .T.
LOCAL _oObj 	:= NIL
LOCAL cSubCon 	:= ""
LOCAL cVerCon 	:= ""
LOCAL nI		:= 0
LOCAL nLin		:= 0
LOCAL nTamFam	:= TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]
//���������������������������������������������������������������������������
//� Prestador
//���������������������������������������������������������������������������
If cTp == '1'

	lRet := PlsVldGD( {"BSO_CODINT","BSO_CODIGO","BSO_CODLOC"} )
//���������������������������������������������������������������������������
//� Empresa
//���������������������������������������������������������������������������
ElseIf cTp == '2'                                    
	//���������������������������������������������������������������������������
	//� Verifica se ja foi informado contrato sem subcontrato
	//���������������������������������������������������������������������������
    If !Empty( M->(B40_SUBCON+B40_VERSUB) )
		cSubCon 		:= M->B40_SUBCON
		cVerCon 		:= M->B40_VERSUB    
		M->B40_SUBCON 	:= Space(TamSx3("B40_SUBCON")[1])
		M->B40_VERSUB 	:= Space(TamSx3("B40_VERSUB")[1])
    
		lRet := PlsVldGD( {"B40_CODINT","B40_CODEMP","B40_NUMCON","B40_VERCON","B40_SUBCON","B40_VERSUB"})
		
		M->B40_SUBCON 	:= cSubCon
		M->B40_VERSUB 	:= cVerCon
	Else
		lRet := PlsVldGD( {"B40_CODINT","B40_CODEMP","B40_NUMCON","B40_VERCON"})
	EndIf
	//���������������������������������������������������������������������������
	//� Verifica contrato e subcontrato
	//���������������������������������������������������������������������������
	If lRet	
		lRet := PlsVldGD( {"B40_CODINT","B40_CODEMP","B40_NUMCON","B40_VERCON","B40_SUBCON","B40_VERSUB"} )
	EndIf	
//���������������������������������������������������������������������������
//� Familia
//���������������������������������������������������������������������������
ElseIf cTp == '3'

	lRet := PlsVldGD( {"B49_BENEFI"} )
	//���������������������������������������������������������������������������
	//� Se nao existe ja cadastrado
	//���������������������������������������������������������������������������
	If lRet                    
		//���������������������������������������������������������������������������
		//� Monta obj do browse
		//���������������������������������������������������������������������������
		_oObj := aObjGD[Val(cTp)]
		//���������������������������������������������������������������������������
		//� Pega o primeiro nao deletado para checar se e da mesma familia
		//���������������������������������������������������������������������������
		For nI:=1 To Len(_oObj:aCols)
			If !_oObj:aCols[nI, Len(_oObj:aHeader)+1 ]
				nLin := nI
				Exit
			EndIf	
		Next
		//���������������������������������������������������������������������������
		//� Verifica se o usuario informado pertence a mesma familia
		//���������������������������������������������������������������������������
		If nLin > 0 .And. !Empty( _oObj:aCols[ nLin, _oObj:FieldPos("B49_BENEFI") ] )
			//���������������������������������������������������������������������������
			//� Se nao pertencer a mesma familia nega a inclusao
			//���������������������������������������������������������������������������
			lRet := ( Left(M->B49_BENEFI,nTamFam) $ _oObj:aCols[ nLin, _oObj:FieldPos("B49_BENEFI") ] )
			
			If !lRet
				MsgStop('Benefici�rio n�o pertence a esta fam��ia!')
			EndIf                    
		EndIf	
		//���������������������������������������������������������������������������
		//� Verifica se e o titular
		//���������������������������������������������������������������������������
		If lRet .And. SubStr(M->B49_BENEFI,(nTamFam+1),2) == GetNewPar("MV_PLTRTIT","00")
			If MsgYesNo("Deseja incluir tamb�m os dependentes?")
				cMatric	:= M->B49_BENEFI              
				_oObj:lInAddLine := .F.
				_oObj:bAfterAdd := {||PLSINDEP(_oObj)}
			EndIf
		EndIf	
	EndIf
ElseIf (PLSALIASEXI("B95") .And. cTp == '5').Or. (!PLSALIASEXI("B95") .And. cTp == '4')
	lRet := PlsVldGD( {"BX1_ALIAS","BX1_RECNO","BX1_TIPO","BX1_USUARI","BX1_DATA","BX1_HORA","BX1_ROTINA"} )
EndIf	                                
//���������������������������������������������������������������������������
//� Se foi informado item atribui o tipo de portal
//���������������������������������������������������������������������������
M->BSW_TPPOR := cTp
IF (PLSALIASEXI("B95") .And. cTp == '5').Or. (!PLSALIASEXI("B95") .And. cTp == '4')
	cTp	:= '1'
	M->BSW_TPPOR := cTp
ENDIF	

//���������������������������������������������������������������������������
//� Refresh do browse
//���������������������������������������������������������������������������
oEnchoice:Refresh()
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return(lRet)
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSVLDDEL �Autor  �Microsiga           � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida del												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSVLDDEL(cTp)
LOCAL lRet 		:= .T.
LOCAL nI		:= 1
LOCAL _oObj 	:= aObjGD[ Val(cTp) ]
LOCAL lLinDel	:= _oObj:IsDeleted( _oObj:Linha() )
//���������������������������������������������������������������������������
//� Alinha sera deletada
//���������������������������������������������������������������������������
If !lLinDel
	//���������������������������������������������������������������������������
	//� Verifico se tem alguma linha valida (nao deletada)
	//���������������������������������������������������������������������������
	For nI:=1 To Len(_oObj:aCols)                           
		If nI <> _oObj:Linha() .And. !_oObj:IsDeleted(nI)
			lRet := .F.
		EndIf
	Next
//���������������������������������������������������������������������������
//� Estava deletada e sera restaurada
//���������������������������������������������������������������������������
Else 
	lRet := .F.
EndIf
//���������������������������������������������������������������������������
//� Se deletou todos os registro do item limpa o tipo de portal
//���������������������������������������������������������������������������
If lRet
	M->BSW_TPPOR := ''
ElseIf Empty(M->BSW_TPPOR) .And. PLSVLDDLG( Val(cTp) )
	M->BSW_TPPOR := cTp
ElseIF (PLSALIASEXI("B95") .And. cTp == '5').Or. (!PLSALIASEXI("B95") .And. cTp == '4')
	cTp := '1'
	M->BSW_TPPOR := cTp
EndIf

oEnchoice:Refresh()
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return(.T.)
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSINIDL  �Autor  �Microsiga           � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seta a operadora referete ao item multi-operadora		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSINIDL(nTp)
LOCAL _oObj := aObjGD[nTp]
//���������������������������������������������������������������������������
//� Atualiza statica para multi-operadora
//���������������������������������������������������������������������������
If !Inclui
	If nTp == 1
		__cOpePad 	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("BSO_CODINT") ]
		cCodRda		:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("BSO_CODIGO") ]

	ElseIf	nTp == 2
		__cOpePad 	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_CODINT") ]
		cCodEmp 	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_CODEMP") ]
		cCodConVer	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_NUMCON") ]+_oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_VERCON") ]
	EndIf 
EndIf

cCodInt := PLSINTPAD()                                                  
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSVLDDLG �Autor  �Microsiga           � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se foi informado item								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSVLDDLG(nTp)
LOCAL _oObj := aObjGD[nTp]
LOCAL nI	:= 1
LOCAL nPos	:= 0
LOCAL lRet	:= .F.
//���������������������������������������������������������������������������
//� Neste passo a linha nao esta mais deletada mesmo a acols ainda nao estando atualizada
//���������������������������������������������������������������������������
For nI:=1 To Len(_oObj:aCols)                           
	//���������������������������������������������������������������������������
	//� Verifico se tem conteudo
	//���������������������������������������������������������������������������
	If (nPos := _oObj:FieldPos("BSO_CODIGO")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])
	ElseIf (nPos := _oObj:FieldPos("BX1_USUARI")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])	
	ElseIf (nPos := _oObj:FieldPos("B40_CODEMP")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])
	ElseIf (nPos := _oObj:FieldPos("B49_BENEFI")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])
	EndIf
	//���������������������������������������������������������������������������
	//� Aborto a checagem
	//���������������������������������������������������������������������������
	If lRet
		Exit
	EndIf
Next
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return(lRet)
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSMREL   �Autor  �Microsiga           � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Mostra senha real										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSMREL()
LOCAL cRet := ""   

If M->BSW_TPPOR == '2'
	cRet := PLSCRIDEC(2,AllTrim(M->BSW_SENHA))
EndIf
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return(cRet)
/*                                                                                              
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSINDEP  �Autor  �Microsiga           � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inclui dependentes										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                           
Static Function PLSINDEP(oObj)
LOCAL nLin  	:= 0
LOCAL nI		:= 0
LOCAL cConteudo := ""           
LOCAL nTamFam	:= TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]
//���������������������������������������������������������������������������
//� Posiciona na familia correspondente
//���������������������������������������������������������������������������
BA1->( DbSetOrder(1) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO
BA1->( MsSeek( xFilial("BA1") + Left(cMatric,nTamFam) ) )	
//���������������������������������������������������������������������������
//� Pega todos os componentes da familia
//���������������������������������������������������������������������������
While !BA1->( Eof() ) .And. Left(cMatric,nTamFam) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
	//���������������������������������������������������������������������������
	//� Se for diferente do usuario titular informado
	//���������������������������������������������������������������������������
	If cMatric <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And. aScan(oObj:aCols,{|x| !x[Len(oObj:aHeader)+1] .And. x[PLRETPOS('B49_BENEFI',oObj:aHeader)] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) }) == 0
		//���������������������������������������������������������������������������
		//� Inclui linha vazia
		//���������������������������������������������������������������������������
  	    oObj:AddBlank()
  	    nLin := Len(oObj:aCols) 
		oObj:SetPos( nLin )  
		//���������������������������������������������������������������������������
		//� monta a cols
		//���������������������������������������������������������������������������
		For nI:=1 To Len(oObj:aHeader)+1
			
			If nI <= Len(oObj:aHeader)
				//���������������������������������������������������������������������������
				//� Campos correspondentes na aheader
				//���������������������������������������������������������������������������
				cConteudo := ""
				Do Case
					Case oObj:aHeader[nI,2] == 'B49_CODUSR'
						cConteudo := CriaVar(oObj:aHeader[nI,2],.T.)
						
					Case oObj:aHeader[nI,2] == 'B49_BENEFI'
						cConteudo := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
						
					Case oObj:aHeader[nI,2] == 'B49_NOMBEN'
						cConteudo := BA1->BA1_NOMUSR
						
				EndCase
				//���������������������������������������������������������������������������
				//� coloca o conteudo na acols
				//���������������������������������������������������������������������������
				oObj:FieldPut(oObj:aHeader[nI,2],cConteudo,nLin)
			EndIf
		Next
	EndIf
BA1->( DbSkip() )
EndDo
           
oObj:Refresh()
//���������������������������������������������������������������������������
//� Fim da Rotina...                                                         
//���������������������������������������������������������������������������
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA226NLC � Autor � 		             � Data � 28/06/12���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibe Desc. Local	 no INIBRW BSO_DESLOC                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PLSA226NLC()  
Return(BB8->(Posicione("BB8",1,xFilial("BB8")+BSO->BSO_CODIGO+PLSINTPAD()+BSO->BSO_CODLOC,"BB8_DESLOC")))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  PLSEdiSDir   � Autor � Karine Riquena   � Data �21/11/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao �  Fun��o para selecionar imagem para atalho no portal       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �  Retorna Verdadeiro ou Falso                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  PLS                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSEdiSDir()

Local aArea	   := GetArea()
Local cTipo			 := ""
Local cCpoVld  := ReadVar()
LOCAL cWebDir  := getWebDir()
LOCAL cSkinPls := getSkinPls()
LOCAL cFile    := ""
LOCAL nAt

 	cFile := cGetFile("*.JPG|*.jpg|*.bmp|*.BMP|*.png|*.PNG","Selecione a Imagem",1,'SERVIDOR' + cWebDir + cSkinPls,.F.,GETF_NETWORKDRIVE+GETF_NOCHANGEDIR)   //"Selecione o Arquivo"
 	nAt := At(cSkinPls, cFile)
	&(cCpoVld) := Substr(cFile, nAt, Len(cFile))
	RestArea(aArea)

Return(.T.) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  A226USRCOD   � Autor � Geraldo Felix   � Data �23/08/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao �  Gera c�digo do usu�rio       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �  nulo                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  PLS                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A226USRCOD(lAuto)
LOCAL cSql 		:= ""
LOCAL cCodBSW 	:= ""
LOCAL nCnt 		:= 0
LOCAL _oObj 	:= nil
LOCAL cAlias 	:= ""
LOCAL nPos 		:= 0  
LOCAL nX		:= 0

Default lAuto := .F.

//Seleciona o titulo de maio recno, desde que ele nao seja um titulo de imposto.
cSQL := "SELECT MAX(BSW_CODUSR) CODUSR"
cSQL += " FROM " + RetSqlName("BSW")
cSQL += " WHERE BSW_FILIAL = '" + xFilial("BSW") + "' "
cSQL += " AND BSW_CODUSR NOT LIKE '%AUTO%'"
cSQL += " AND D_E_L_E_T_ = ' '"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BSWMAX",.F.,.T.)
DbSelectArea("BSWMAX")

If BSWMAX->( Eof() )
	cCodBSW := StrZero(1,Len(BSW->BSW_CODUSR))
Else
	cCodBSW := Soma1(BSWMAX->CODUSR)
Endif




if !lAuto
	// Atualiza o campo chave no cabecalho
	M->BSW_CODUSR := cCodBSW
	
	// Atualiza todos os browses 
	For nCnt := 1 To len(aObjGD)
		_oObj := aObjGD[nCnt]
			
		cAlias := _oObj:cAlias	
		nPos := _oObj:FieldPos(cAlias+"_CODUSR")
		If nPos > 0
			For nX := 1 to Len(_oObj:aCols) 
				_oObj:FieldPut(cAlias+"_CODUSR", cCodBSW, nX)
			Next
		Endif
	Next
EndIf
 
// Fecha a �rea de trabalho
BSWMAX->( dbCloseArea() )

Return(cCodBSW)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := PLSMnDefY( .T., "BSW", , )

Return(aRotina)