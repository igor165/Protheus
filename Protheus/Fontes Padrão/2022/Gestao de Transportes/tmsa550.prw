#INCLUDE "FIVEWIN.CH"
#INCLUDE "TMSA550.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSA550  � Autor �Patricia A. Salomao    � Data �15.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Solicitacao de Reembolso                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550()

Local aCores    := {}
Local cBot550   := ""
Local aHlpPor1  := {"Para baixar um ou mais Reembolsos ser� ","necess�rio o preenchimento do campo ","Data e Valor do Reembolso."}
Local aHlpIng1  := {"To post one or more reimbursements you ","will need to fill out the field ","Reimbursement Date and Val"}
Local aHlpEsp1  := {"Para bajar uno o mas Reembolsos es ","necesario el rellenado del campo ","Fecha y Valor del Reembolso."}
Local aHlpPor2  := {"O Reembolso somente poder� ser gerado ","para indeniza��es que possuem o valor ","do prejuizo informado."}
Local aHlpIng2  := {"The reimbursements can only be generated","for compensations with the amount of  ","the loss entered. "}
Local aHlpEsp2  := {"El Reembolso solamente podra generarse ","para indemnizaciones que tienen el valor ","del perjuicio informado."}

//Ajuste de Novos Helps
PutHelp("TMSA55008",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)
PutHelp("TMSA55007",aHlpPor2,aHlpIng2,aHlpEsp2,.F.)

Private cTop550   := ""
Private cCadastro := STR0001 // 'Solicitacao de Reembolso'
Private aRotina	:= MenuDef()
							
AAdd(aCores,{"DUB_STAREB=='2'",'BR_AMARELO'  })	
AAdd(aCores,{"DUB_STAREB=='3'",'BR_AZUL'	  })	
AAdd(aCores,{"DUB_STAREB=='4'",'BR_VERMELHO' })	

dbSelectArea("DUB")
dbSetOrder(7)

//�����������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE.                                          �
//�������������������������������������������������������������������������
cTop550 :=  'xFilial("DUB") + "0"'
cBot550 :=  'xFilial("DUB") + "z"'

mBrowse(6,1,22,75,"DUB",,,,,,aCores,cTop550,cBot550)

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Mnt  � Autor � Patricia A. Salomao � Data �04.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao das Notas Fiscais do Cliente                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550Mnt( cAlias, nReg, nOpcx )

Local oEnchoice
Local nOpca		 := 0
Local aAreaDUB   := DUB->(GetArea())
Local aObjects	 := {}
Local aPosObj 	 := {}
Local aInfo	 	 := {}
Local aSize	 	 := {}
Local aButtons   := {}
Local aVisual    := {}
Local aNoFields  := {}
Local aYesFields := {}
Local nOpcB      := nOpcx
Local aAlter, bSeekFor
Local oSay1, oSay2, oSay3
Local aAltEnc
Local lBxEstorno := .F.
Local nCont        := 0
Local aSomaButtons := {}
Local aDUBStru     := FwFormStru(2,"DUB")
Local ni           := 1

Private aHeader  := {}
Private aCols    := {}
Private aTela[0][0],aGets[0]
Private oGet, oDlg

If DUB->DUB_STAREB == '4'  .And. nOpcx <> 2 .And. nOpcx <> 6
   Help("",1,"TMSA55006") // Lotes Sem Reembolso so poderao ser Visualizados/Estornados ...
   Return 
EndIf

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM550BUT')
	aSomaButtons:=ExecBlock('TM550BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCont:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCont])
		Next
	EndIf
EndIf
               
AAdd(aVisual, "DUB_NUMLRB" )
AAdd(aVisual, "DUB_DATLRB" )
AAdd(aVisual, "DUB_NUMPRO" ) 
AAdd(aVisual, "DUB_CERVIS" )

aNoFields := AClone(aVisual)

AAdd(aYesFields, 'DUB_NUMRID')
AAdd(aYesFields, 'DUB_ITEM')
AAdd(aYesFields, 'DUB_FILDOC')
AAdd(aYesFields, 'DUB_DOC')
AAdd(aYesFields, 'DUB_SERIE')
AAdd(aYesFields, 'DUB_CODCLI')
AAdd(aYesFields, 'DUB_LOJCLI')
AAdd(aYesFields, 'DUB_NOMCLI')
AAdd(aYesFields, 'DUB_VALPRE')
AAdd(aYesFields, 'DUB_DATVEN')
AAdd(aYesFields, 'DUB_DATREB')
AAdd(aYesFields, 'DUB_VALREB')
AAdd(aYesFields, 'DUB_VALIND')
                                                     
//-- Lista os campos que n�o devem ser exibidos da tabela DUB - Hist�rico do Seguro.
For ni := 1 To Len(aDUBStru:aFields)
	If 	AScan(aYesFields, {|x| x == AllTrim(aDUBStru:aFields[ni,1]) }) == 0
		Aadd( aNofields, AllTrim(aDUBStru:aFields[ni,1]) )
	EndIf
Next ni

//-- Configura variaveis da Enchoice
RegToMemory(cAlias, nOpcx == 3) 

If nOpcx == 5  // Alterar
    nOpcx    := 4        
    aAlter   := {}
    aAltEnc  := { 'DUB_CERVIS', 'DUB_NUMPRO' }    
    bSeekFor := {|| DUB->DUB_STAREB <> "3" .And.  DUB->DUB_STAREB <> "4"}    
    
ElseIf nOpcx == 6 // Estornar     
    nOpcx    := 4            
    AAdd(aYesFields, 'DUB_ESTORN')
    aAlter   :=  { 'DUB_ESTORN' } 
    bSeekFor := {|| Empty(DUB->DUB_DATREB) }    
    aAltEnc  := {}
    
ElseIf nOpcx == 7 // Baixar
    nOpcx    := 4        
    aAlter   := { 'DUB_DATREB', 'DUB_VALREB' }          
    aAltEnc  := {}    
    bSeekFor := {|| !Empty(DUB->DUB_CERVIS) .And. !Empty(DUB->DUB_NUMPRO) .And. (Empty(DUB->DUB_VALREB) .Or. Empty(DUB->DUB_DATREB))  }    
    
ElseIf nOpcx == 8 // Estornar Baixa
    nOpcx    := 4        
    AAdd(aYesFields, 'DUB_ESTORN')
    aAlter   :=  { 'DUB_ESTORN' } 
    aAltEnc  := {}    
    bSeekFor := {|| DUB->DUB_STAREB == '3' }        
EndIf                             

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DUB', 7, xFilial( 'DUB' ) + M->DUB_NUMLRB,{ ||	DUB->DUB_FILIAL + DUB->DUB_NUMLRB } , bSeekFor, aNoFields, aYesFields)

If Len(aCols)==1 .And. Empty(aCols[1,1]) 
   If nOpcB == 5 // Alterar
      Help(' ', 1, 'TMSA55001')	 //Alteracao Nao Permitida 
      Return .T.
   ElseIf nOpcB == 6 // Estornar 
      Help(' ', 1, 'TMSA55002')	 //Estorno nao sera efetuado ...
      Return .T.
   ElseIf nOpcB == 7 // Baixar
      Help(' ', 1, 'TMSA55003')	 //A Baixa Nao podera ser efetuada ...
      Return .T.
   ElseIf nOpcB == 8 // Estornar Pagto
      Help(' ', 1, 'TMSA55004')	// O Estorno da Baixa nao sera efetuado ...              
      Return .T.
   EndIf
EndIf   																			 

aEval(aCols, {|x| IIf(Empty(x[GdFieldPos('DUB_ITEM')]), x[GdFieldPos('DUB_ITEM')] == StrZero(1, Len(DUB->DUB_ITEM)), .T.) })                                         

//-- Dimensoes padroes                                  
aSize := MsAdvSize()
AAdd( aObjects, { 100, 050, .T., .T. } )
AAdd( aObjects, { 160, 160, .T., .T. } ) 
AAdd( aObjects, { 030, 030, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	//���������������������������������������������������������������������������Ŀ
	//� Monta a Enchoice                                                          �
	//�����������������������������������������������������������������������������
	oEnchoice:= MsMGet():New("DUB", nReg, nOpcx,,,,aVisual,aPosObj[1], aAltEnc,3,,,,,,.T. )

    oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[3,4]-aPosObj[3,2]), (aPosObj[3,3]-aPosObj[3,1]), .T.) 
	
	@  005,005  SAY STR0011	SIZE 050,009 OF oPanel 	PIXEL COLOR CLR_BLUE // "Total Indenizacao : "
	@  005,040  SAY oSAY1 VAR 0 PICTURE PesqPict('DUB','DUB_VALIND')	SIZE 050,009 OF oPanel 	PIXEL
	@  005,095  SAY STR0012 SIZE 050,009 OF oPanel 	PIXEL COLOR CLR_BLUE // "Total Reembolsado : "
	@  005,135  SAY oSAY2 VAR 0 PICTURE PesqPict('DUB','DUB_VALREB')	SIZE 050,009 OF oPanel	PIXEL
	@  005,195  SAY STR0013 SIZE 080,009 OF oPanel 	PIXEL COLOR CLR_BLUE // "Saldo para Reembolso : "
	@  005,275  SAY oSAY3 VAR 0 PICTURE PesqPict('DUB','DUB_VALREB')	SIZE 050,009 OF oPanel	PIXEL

	oDlg:Cargo := {|n1,n2,n3| oSay1:SetText(n1), oSay2:SetText(n2), oSay3:SetText(n3)}
		
	oGet:=MSGetDados():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "TMSA550LinOk", 'AllWaysTrue', '+DUB_ITEM', nOpcx==3, aAlter )
	
	If nOpcx == 4
		oGet:oBrowse:bAdd    := { || .f. }    // Nao Permite a inclusao de Linhas
	EndIf
	    
    TMSA550Tot(oDlg, aCols)
     	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1, If(Obrigatorio(aGets, aTela) .And. TMSA550TudOk(nOpcx),oDlg:End(),nOpca := 0)},{||oDlg:End()},, aButtons )

If	nOpca == 1 .And. nOpcx <> 2
    nOpcx := nOpcB
	Begin Transaction
		Processa({|| TMSA550Grv(nOpcx,@lBxEstorno)},cCadastro)
	End Transaction
EndIf

RestArea( aAreaDUB )

//-- Para evitar que o Browser se perca no estorno, posiciona no primeiro registro encontrado.
If lBxEstorno
	DUB->(MsSeek(&(cTop550)))
EndIf

Return NIL 
          
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Lin� Autor � Patricia A. Salomao   � Data �19.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Linha Digitada                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550LinOk()                                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550LinOk()

Local lRet := .T.

If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	If OGet:nOpc == 5 .And. GdFieldGet('DUB_ESTORN',n) == '1' .And. !Empty(GdFieldGet('DUB_DATREB',n))		
		Help("",1,"TMSA55002")  //Estorno nao sera efetuado ...
		lRet := .F.
	EndIf
EndIf

If lRet
	TMSA550Tot(,aCols) // Totaliza
EndIf

Return(lRet)       

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Vld� Autor � Patricia A. Salomao   � Data �19.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos Campos                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550Vld()

Local lRet   := .T. 
Local cCampo := ReadVar()

If cCampo == 'M->DUB_VALREB'
   If M->DUB_VALREB > GdFieldGet('DUB_VALIND', n)
       Help('',1,'TMSA55005') // O Valor do Reembolso nao pode ser Maior que o Valor da Indenizacao ...
       lRet := .F.
   EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Tud� Autor � Patricia A. Salomao   � Data �19.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � TudoOk da GetDados                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550TudOk(ExpN1)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao Selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550TudOk()
Return TMSA550LinOk() //-- Analisa LinhaOk

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Grv� Autor � Patricia A. Salomao   � Data �19.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Grv(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Opcao Selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA550Grv(nOpcx,lBxEstorno)

Local nA         := 0
Local nY         := 0
Local lHelpReemb := .T.
Local nx

DUB->(dbSetOrder(2))

If nOpcx == 5 //Alterar
    For nA:=1 to Len(aCols)		    
    	If !GdDeleted(n) .And. DUB->(MsSeek(xFilial('DUB')+ cFilAnt + GdFieldGet('DUB_NUMRID',nA)+GdFieldGet('DUB_ITEM',nA) ))
			RecLock("DUB", .F.)        
			
			// Grava os Dados da Enchoice
			For nX := 1 TO FCount()
				If "FILIAL"$Field(nX)
					FieldPut(nX,xFilial())
				Else
					If TYPE("M->"+FieldName(nX)) <> "U"
						FieldPut(nX,M->&(FieldName(nX)))
					EndIf
				EndIf
			Next i
			// Grava os Dados da GetDados
			For nY:= 1 to Len(aHeader)
				If aHeader[nY][10] # "V"
					DUB->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nA][nY]))
				EndIf
			Next
			DUB->(MsUnLock())

		EndIf
	Next nA	
	
ElseIf nOpcx == 6 // Estornar                      
    For nA:=1 to Len(aCols)
		If GdFieldGet('DUB_ESTORN',nA) == '1'	.And. DUB->(MsSeek(xFilial('DUB')+ cFilAnt + GdFieldGet('DUB_NUMRID',nA)+GdFieldGet('DUB_ITEM',nA) ))
			RecLock("DUB", .F.)
			DUB->DUB_NUMLRB := CriaVar('DUB_NUMLRB', .F.)
			DUB->DUB_DATLRB := CriaVar('DUB_DATLRB', .F.)	 					
			DUB->DUB_STAREB := '1'  // Em Aberto
			DUB->(MsUnLock())
			lBxEstorno := .T.
		EndIf
	Next nA	
	
ElseIf nOpcx == 7 //Baixar   
    For nA:=1 to Len(aCols)
		If !Empty(GdFieldGet('DUB_DATREB',nA)) .And. !Empty(GdFieldGet('DUB_VALREB',nA)) .And. ;
				DUB->(MsSeek(xFilial('DUB')+ cFilAnt +GdFieldGet('DUB_NUMRID',nA)+GdFieldGet('DUB_ITEM',nA) ))
			RecLock("DUB", .F.)
			DUB->DUB_DATREB := GdFieldGet('DUB_DATREB',nA)
			DUB->DUB_VALREB := GdFieldGet('DUB_VALREB',nA)
			DUB->DUB_STAREB := '3'  // Baixado    
			DUB->(MsUnLock())
			lHelpReemb := .F.
		EndIf
	Next nA		

	If lHelpReemb
		Help(" ",1,"TMSA55008") // "Para baixar um ou mais Reembolsos sera necessario o preenchimento do campo Data e Valor do Reembolso."
	EndIf

ElseIf nOpcx == 8 // Estornar Baixa
    For nA:=1 to Len(aCols)
		If GdFieldGet('DUB_ESTORN',nA) == '1' 	.And. DUB->(MsSeek(xFilial('DUB')+ cFilAnt + GdFieldGet('DUB_NUMRID',nA)+GdFieldGet('DUB_ITEM',nA) ))
			RecLock("DUB", .F.)
			DUB->DUB_VALREB := CriaVar('DUB_VALREB', .F.)
			DUB->DUB_DATREB := CriaVar('DUB_DATREB', .F.)  
			DUB->DUB_STAREB := '2'  // Solicitado
			DUB->(MsUnLock())
		EndIf
	Next nA				
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Lot� Autor � Patricia A. Salomao   � Data �16.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para escolha dos Lotes de Reembolso               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Lot(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA550Lot(cAlias,nReg,nOpcx)

Local aAreaDUB  := DUB->(GetArea())
Local aButtons  := {}
Local cArqDUB   := ""
Local cFilDUB   := ""
Local cKeyDUB   := ""
Local cCondicao := ""
Local nIndex    := 0
Local nOpca     := 0
Local oDlg
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aSize		:= {}
Local lInvert	:= .F.
Local oMark                  
Local cFilter := DUB->( dbFilter() )
                  
//��������������������������������������������������������������Ŀ
//� mv_par01 - Ramo de Seguro De								 �
//� mv_par02 - Ramo de Seguro Ate								 �
//� mv_par03 - Data de Vencto De                                 �
//� mv_par04 - Data de Vencto Ate                                �
//� mv_par05 - Valor da Indenizacao De                           �
//� mv_par06 - Valor da Indenizacao Ate                          �
//� mv_par07 - Parametros abaixo ? (Sim/Nao)                     �
//� mv_par08 - No.Processo De                                    �
//� mv_par09 - No.Processo Ate                                   �
//����������������������������������������������������������������
If Pergunte("TMA550",.T.)
	
	dbSelectArea("DUB")

	cCondicao := 'DUB->DUB_FILIAL == "' + xFilial("DUB") + '" .And. DUB->DUB_STAREB == "1" .And. '
	cCondicao += 'DUB->DUB_COMSEG >= "' + mv_par01 + '" .And. DUB->DUB_COMSEG <= "' + mv_par02 + '" .And. '
	cCondicao += 'DTOS(DUB->DUB_DATVEN) >= "' + DTOS(mv_par03) + '" .And. DTOS(DUB->DUB_DATVEN) <= "' + DTOS(mv_par04) + '" .And. '
	cCondicao += 'DUB->DUB_VALIND >= ' + AllTrim(STR(mv_par05)) + ' .And. DUB->DUB_VALIND <= ' + AllTrim(STR(mv_par06))

	If mv_par07 == 1
		cCondicao += ' .And. DUB->DUB_NUMPRO >= "' + mv_par08 + '" .And. DUB->DUB_NUMPRO <= "' + mv_par09 + '" '
	EndIf
		
	cArqDUB := CriaTrab(NIL,.F.)
	cKeyDUB := "DUB_FILIAL+DUB_NUMPRO+DUB_COMSEG+DUB_FILDOC+DUB_DOC+DUB_SERIE"
	
	IndRegua("DUB",cArqDUB,cKeyDUB,,cCondicao,STR0014) // "Selecionando Registros ..."
	
	nIndex := Retindex("DUB")

	dbSetOrder(nIndex + 1)
	dbGoTop()
	
	If Bof() .and. Eof()
		Help(" ",1,"RECNO") //"Nao existem registros no arquivo em pauta"
	Else
	                                                                                           	
		cMark := GetMark()

		//-- Controle de dimensoes de objetos
		AAdd( aObjects, { 100, 100,.T.,.T. } )

		aSize   := MsAdvSize()
		aInfo   := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects,.T. )

		Aadd(aButtons	, {'PESQUISA',{||TMSXPesqui()}, STR0002 , STR0020 }) // "Pesquisar" 
	
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 

			oMark := MsSelect():New("DUB","DUB_OK",,,@lInvert,@cMark,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]})
			oMark:bMark := {|| TMSA550Mrk(), oMark:oBrowse:Refresh()}
			oMark:oBrowse:lHasMark		:= .T.
			oMark:oBrowse:lCanAllMark 	:= .T.


		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End() },{|| oDlg:End()},, aButtons )
		
		If nOpca == 1 .And. nOpcx <> 2
			Begin Transaction
				Processa({|| A550GrvReb(nOpcx)},STR0001, STR0015, .F.) // "Solicitacao de Reembolso" ### "Aguarde, Gerando Lotes ..."
			End Transaction
		EndIf
		MBRCHGLoop() // Nao chama novamente a tela de inlusao.
	EndIf
EndIf

DbSelectArea("DUB")
RetIndex("DUB")
If File(cArqDUB+OrdBagExt())
	FErase(cArqDUB+OrdBagExt())
Endif                       

Set Filter to &(cFilter)

RestArea( aAreaDUB )
DUB->(MsSeek(&(cTop550))) //-- Posiciona no primeiro registro encontrado, Atualiza Browser.

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A550GrvReb� Autor � Patricia A. Salomao   � Data �16.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os Lotes dos Registros marcados                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A550GrvReb(ExpN1,ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao Escolhida                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function A550GrvReb(nOpcx)

Local cNumPro := ""
Local cComSeg := ""
Local cNumLRB := ""

DUB->( DbGoTop() )
	
Do While !DUB->( Eof() )
	
	If	!DUB->( IsMark( 'DUB_OK', ThisMark(), ThisInv() ) ) .Or. DUB->( Eof() )
		dbSkip()
		Loop
	EndIf	          
	
	If DUB->DUB_NUMPRO+DUB->DUB_COMSEG <> cNumPro + cComSeg
	    cNumPro := DUB->DUB_NUMPRO   
	    cComSeg := DUB->DUB_COMSEG
	    cNumLRB := GetSx8Num("DUB", "DUB_NUMLRB",,7)
		If __lSX8
	      ConfirmSX8()
	    EndIf    	    
    EndIf
    
    RecLock("DUB", .F.)      		
    DUB->DUB_NUMLRB := cNumLRB
    DUB->DUB_DATLRB := dDataBase
    If nOpcx == 3  // Lote com Reembolso
        DUB->DUB_STAREB := '2' // Solicitado Reembolso
    ElseIf nOpcx == 4  // Lote sem Reembolso 
        DUB->DUB_STAREB := '4' // Sem Reembolso
    EndIf    	     
    MsUnLock()
      	 	    
    DUB->(dbSkip())	          	
   	
EndDo    

Return
          
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Tot� Autor � Patricia A. Salomao   � Data �19.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Totalizar o Rodape                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Tot(ExpO1, ExpA1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto Dialog                                      ��� 
���          � ExpA1 = aCols                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMSA550Tot(oDlg, aCols)

Local nA, nTotValInd, nTotValReb

If oDlg == NIL
	oDlg := GetWndDefault()
	If ValType(oDlg:Cargo)<>"B" 
		oDlg := oDlg:oWnd
	EndIf
EndIf

If ValType(oDlg:Cargo)!="B" 
   Return .F.
EndIf

nTotValInd := nTotValReb := 0

For nA := 1 to len(aCols)   
   If !GdDeleted(nA)
	   nTotValInd += GdFieldGet('DUB_VALIND', nA)
	   nTotValReb += GdFieldGet('DUB_VALREB', nA)
	EndIf	   
Next

Eval(oDlg:Cargo, nTotValInd, nTotValReb, nTotValInd - nTotValReb)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Leg� Autor � Patricia A. Salomao   � Data �15.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a legenda de status                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Leg()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550Leg()

Local aStatus := {	{ 'BR_AMARELO'	, STR0016 },; // 'Solicitado'
					      { 'BR_AZUL'	   , STR0017 },; // 'Reembolsado'
					      { 'BR_VERMELHO', STR0018 } } // 'Sem Reembolso'

BrwLegenda(STR0001,STR0019, aStatus ) // "Solicitacao de Reembolso" ### "Status"

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA550Mrk� Autor � Eduardo de Souza      � Data � 18/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida marca da markbrowse.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA550Mrk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA550                                                    ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA550Mrk()

If	DUB->( IsMark( 'DUB_OK', ThisMark(), ThisInv() ) )
	If DUB->DUB_VALPRE == 0
		Help(" ",1 ,"TMSA55007") // O Reembolso somente podera ser gerado para indenizacoes que possuem o valor do prejuizo informado.
		RecLock("DUB",.F.)
		DUB->DUB_OK := CriaVar("DUB_OK",.F.)
		MsUnLock()
	EndIf
EndIf

Return NIL

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     
Private aRotina:= {	{STR0002, "TmsxPesqui" ,0,1,0,.F.},; // "Pesquisar"
							{STR0003, "TMSA550Mnt" ,0,2,0,NIL},; // "Visualizar"
							{STR0004, "TMSA550Lot" ,0,3,0,NIL},; // "Lote com Reemb"
							{STR0005, "TMSA550Lot" ,0,3,0,NIL},; // "Lote sem Reemb"
							{STR0006, "TMSA550Mnt" ,0,5,0,NIL},; // "Alterar"
							{STR0007, "TMSA550Mnt" ,0,6,0,NIL},; // "Estornar"
							{STR0008, "TMSA550Mnt" ,0,7,0,NIL},; // "Baixar"
							{STR0009, "TMSA550Mnt" ,0,8,0,NIL},; // "Estornar Baixa"
							{STR0010, "TMSA550Leg" ,0,9,0,.F.} } // "Legenda"


If ExistBlock("TM550MNU")
	ExecBlock("TM550MNU",.F.,.F.)
EndIf

Return(aRotina)

