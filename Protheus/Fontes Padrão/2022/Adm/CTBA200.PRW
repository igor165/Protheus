#INCLUDE "CTBA200.CH"
#INCLUDE "PROTHEUS.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADU��O RELEASE P10 1.2 - 21/07/08
Static lFWCodFil := FindFunction("FWCodFil")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA200  � Autor � Pilar S. Albaladejo   � Data � 04/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento Amarracao Moeda x Calendario                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA200()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA200()

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0005)  //"Cadastro Amarracao Moeda x Calendario"

SetKey(VK_F12, { || Pergunte("CTB010", .T.) })

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

mBrowse( 6, 1,22,75,"CTE")

SetKey(VK_F12, Nil)


Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a200Calend� Autor � Pilar S. Albaladejo   � Data � 04/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da  Amarracao Moeda x Calendario                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A200Calend(cMoeda,cCalend)                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Moeda                                              ���
���          � ExpC2 = Calendario                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A200Calend( cMoeda, cCalend )
Local lRet     := .T.		        ,;
		aCteArea := CTE->(GetArea()) ,;
		aCtgArea := CTG->(GetArea()) ,;
		cCalAnt
		
	// Posiciona no ultimo registro da moeda digitada
	If ! CTE->(DbSeek(IncLast(xFilial("CTE")+cMoeda),.T.)) .Or.;
		CTE->CTE_MOEDA != cMoeda
		CTE->(DbSkip(-1))
	Endif
	
	// Se ja existir um cadastro para a moeda
	If CTE->CTE_MOEDA == cMoeda
	
		cCalAnt := CTE->CTE_CALEND 
		// Localiza o calendario para verificar se o mesmo
		// nao esta conflitando com periodo do calendario
		// anterior da mesma moeda.
		CTG->(DbSeek(xFilial("CTG")+cCalend))
		dCtg_Ini := CTG->CTG_DTINI
		CTG->(DbSeek(xFilial("CTG")+cCalAnt))
		
		// Data final do calendario anterior deve ser menor que a 
		// data inicial do calendario atual
		If CTG->CTG_DTFIM >= dCtg_Ini
			lRet := .F.
			Help(" ",1,"CLDINVALID")
		Endif
		
	EndIf
	
	CTE->(RestArea(aCteArea))
	CTG->(RestArea(aCtgArea))
	
Return lRet                                             

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ctb200Inc � Autor � Simone Mie Sato       � Data � 19.12.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao de Amarracao Calendario x Moeda                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb200Inc(cAlias,nReg,nOpc)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias			                                  ���
���          � ExpN1 : Numero do Registro                                 ���
���          � ExpN2 : Opcao do Menu                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb200Inc(cAlias,nReg,nOpc,xReserv1,xReserv2,lGrvAssist,cMoeda,cCodCal)
Local nOpca      := 0
LOcal cCodMoeda  := ""
Local cCalend    := ""

Default lGrvAssist	:= .F.

dbSelectArea("CTE")
CTE->(dbSetOrder(1)) // Filial + Moeda + Calend�rio Cont�bil

Pergunte("CTB010", .F.)

If MV_PAR01 == 1 .And. ! lGrvAssist  //DEFAULT
	nOpca := AxInclui(cAlias, nReg, nOpc,,,, "Ctb200TOk()")

	// Integra��o SIGAPFS x SIGAFIN
	IIf(nOpca == 1 .And. FindFunction("JCQDCTE"), JCQDCTE(CTE->CTE_CALEND, CTE->CTE_MOEDA), Nil)
Else

	If ! lGrvAssist
		cCodCal := ""
		If Ctb200Cal(@cCodCal)
			Ctb200Wiz(cCodCal, .T., 1)		
		Else
			Return
		EndIf
	EndIf
	//quando chamado a rotina por assistente 
	M->CTE_MOEDA := cMoeda
	M->CTE_CALEND := cCodCal
	If 	cMoeda == NIL .Or. cCodCal == NIL //quando e chamado pela mbrose novamente apos inclusao tem q retornar 
		Return
	ElseIf dbSeek(xFilial("CTE")+cMoeda+cCodCal)
		Aviso(STR0010, STR0011 + cMoeda +" x "+STR0012+cCodCal+STR0013,{"OK"})  //"Atencao"###"Amarracao da Moeda "##"Calendario "##" ja existe. Verifique! "
		Return
    Else
		If Ctb200TOK()  //se tudo ok grava a amarracao de moeda x calendario 
			RecLock("CTE", .T.)
			CTE->CTE_FILIAL := xFilial("CTE")
			CTE->CTE_MOEDA := M->CTE_MOEDA
			CTE->CTE_CALEND := M->CTE_CALEND
			MsUnLock()

			// Integra��o SIGAPFS x SIGAFIN
			IIf(FindFunction("JCQDCTE"), JCQDCTE(cCodCal, M->CTE_MOEDA), Nil)
		EndIf
	EndIf
EndIf	

cCodMoeda 	:= CTE->CTE_MOEDA
cCalend 	:= CTE->CTE_CALEND

// ponto de entrada para depois da gravacao
// so executa o ponto na inclusao simples ou na inclusao pelo wizard
IF ExistBlock("CTB200Inc") .And. ( nOpca == 1 .Or. ( nOpc == 3 .And. lGrvAssist ) )
	ExecBlock( "CTB200Inc",.F.,.F.,{cCodMoeda, cCalend, lGrvAssist}) 
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ctb200Edt � Autor � Wagner Mobile Costa   � Data � 02.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alteracao/Exclusao de Amarracao Calendario x Moeda         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb200Edt(cAlias,nReg,nOpc)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias			                                  ���
���          � ExpN1 : Numero do Registro                                 ���
���          � ExpN2 : Opcao do Menu                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ctb200Edt(cAlias,nReg,nOpc)     

Local cCodMoeda := (cAlias)->CTE_MOEDA
Local cCalend	:= (cAlias)->CTE_CALEND

If nOpc = 4
	cDelFunc := "Ctb200TOk()"
	AxDeleta(cAlias,nReg,nOpc)
	
	// ponto de entrada para depois da exclusao
	IF ExistBlock("CTB200Del") 
		ExecBlock( "CTB200Del",.F.,.F.,{cCodMoeda, cCalend}) 
	Endif

Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ctb200TOk � Autor � Wagner Mobile Costa   � Data � 02.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a edicao da amarracao                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb200TOk                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias			                                  ���
���          � ExpN1 : Numero do Registro                                 ���
���          � ExpN2 : Opcao do Menu                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Ctb200TOk

Local lRet 		:= .T.
Local lDeleta 	:= ! INCLUI .And. ! ALTERA

// Valido se for exclusao M-> Nao existe (Exclusao = Nao INCLUI e Nao ALTERA)
// M->dos campos foram alterados e encontrou o calendario, na Inclusao nao eh necessario

Local cCodMoeda	:= 0
Local cCalend	:= ""               
Local aCalend	:= {}
Local aDataIni	
Local aDataFim
Local nIgual := 0
Local nCont

If INCLUI
	cCodMoeda	:= M->CTE_MOEDA	  
	cCalend		:= M->CTE_CALEND	
	
	//Guardo os calendarios ref. essa moeda
	dbSelectArea("CTE")
	dbSetOrder(1)
	dbSeek(xFilial()+cCodMoeda)
	While !Eof() .And. xFilial() == CTE->CTE_FILIAL .And. CTE->CTE_MOEDA == cCodMoeda
	
		//Se for o calendario que esta sendo incluido, pulo para o proximo			
		If CTE->CTE_CALEND == cCalend
			dbSkip() 
			Loop
		Endif			
		
		AADD(aCalend,CTE->CTE_CALEND)		
		
		dbSkip()
	End		                               
	
	dbSelectArea("CTG")
	dbSetOrder(1)
	//Guardo as datas do calendario da Amarracao a ser incluida   		
	If MsSeek(xFilial()+cCalend)    
		aDataIni := {}
		aDataFim := {}
		While CTG_FILIAL = xFilial() .And. CTG_CALEND = cCalend .And. ! Eof()
			Aadd(aDataIni, CTG->CTG_DTINI)
			Aadd(aDataFim, CTG->CTG_DTFIM)
			DbSkip()
		EndDo
	EndIf
	
	//Verifico todos os calendarios ref. essa moeda, se existe outro calendario
	//com a mesma data          
	For nCont    := 1 to Len(aCalend)
		nPeriodo := 1
		nIgual	 := 0
		If MsSeek(xFilial()+aCalend[nCont])
			While CTG_FILIAL = xFilial() .And. CTG_CALEND = aCalend[nCont] .And. ! Eof()
			 if Len(aDataIni)>0
				nIgual += 	If(	CTG->CTG_DTINI = aDataIni[nPeriodo] .Or.;
								CTG->CTG_DTFIM = aDataIni[nPeriodo], 1, 0)
             Endif
				CTG->(DbSkip())
			EndDo
			
			If nIgual > 0
				MsgAlert(STR0006 + aCalend[nCont] + ".")//"ATENCAO!!! A Data Inicial desse Calendario ja foi configurada para outro calendario." 				
				Return .F.
			EndIf 				
		EndIf		
	Next		                          
EndIf

If 	(lDeleta .Or.;
	 M->CTE_MOEDA <> CTE->CTE_MOEDA .Or. M->CTE_CALEND <> CTE->CTE_CALEND) .And.;
	! INCLUI .And. CTG->(dbSeek(xFilial()+CTE->CTE_CALEND, .T.))
	// Verifica se existem lancamentos para amarracao a ser excluida.
   Do While xFilial("CTG") == CTG->CTG_FILIAL 		.And.;
			CTG->CTG_CALEND == CTE->CTE_CALEND
		dbSelectArea("CT7")
		dbSetOrder(4)
		MsSeek(xFilial("CT7")+Dtos(CTG->Ctg_DtIni),.T.)		
		While CT7->CT7_FILIAL == xFilial("CT7") .AND.;
				Ct7->Ct7_Data  >= Ctg->Ctg_DtIni  .AND.;
	 			Ct7->Ct7_Data  <= Ctg->Ctg_DtFim 
	 			
				If CT7->CT7_MOEDA <> CTE->CTE_MOEDA
   	            	dbSkip()
   	            	Loop
				Else
				   	Help(" ",1,"EXISTELAN")
			 		lRet := .F.
			 		Return(lRet)
			 	EndIf   
			 	dbSkip()
	 	EndDo
		Ctg->(DbSkip())
	EndDo
Endif
		
Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �01/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Local aRotina := { 	{ OemToAnsi(STR0001),"AxPesqui"	,0 , 1,,.F.},;  //"Pesquisar"
						{ OemToAnsi(STR0002),"AxVisual"	,0 , 2},;  //"Visualizar"
						{ OemToAnsi(STR0003),"CTB200Inc",0 , 3},;  //"Incluir"
						{ OemToAnsi(STR0009),"Ctb200Edt",0 , 5} }   //Excluir"
Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ctb200Wiz �Autor  �Microsiga           � Data �  06/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Wizard para amarracao de calendario x Moeda                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Ctb200Wiz(cCalend, lAllMoedas, nOpca)
Local aWizAmarCalen
Local cCadastro := STR0005
Local nX
Local aWizCalAm, aPanelAm, aDadAmCal, aDadMoed, bFinalWiz

//�����������������������������������������������������Ŀ
//� Array aWizCalen - Estrutura:                        �
//� Posicao 1 - Titulo                                  �
//�         2 - Mensagem Explicativa                    �
//�         3 - bNext                                   �
//�         4 - bFinish                                 �
//�         5 - lPanel                                  �
//�         6 - lNoFist                                 �
//�������������������������������������������������������

aWizAmarCalen := {}
aAdd(aWizAmarCalen, cCadastro)
aAdd(aWizAmarCalen, STR0014+cCadastro+STR0015)  //"Este assistente do "###" vai lhe orientar no preenchimento dos dados."
aAdd(aWizAmarCalen, {||.T.})
aAdd(aWizAmarCalen, {||.T.})
aAdd(aWizAmarCalen, .T.)
aAdd(aWizAmarCalen, .F.)

//�����������������������������������������������������Ŀ
//� Paineis                                             �
//� Array aWizPanel - Estrutura:                        |
//� Para cada linha dete array multidimensional         �
//� Posicao 1 - Titulo do painel                        �
//�         2 - Mensagem Explicativa                    �
//�         3 - bNext                                   �
//�         4 - bFinish                                 �
//�         5 - lPanel                                  �
//�         6 - bBack                                   �
//�         7 - bExecute                                �
//�������������������������������������������������������

aWizCalAm   := {}
aPanelAm	:= {}
aDadAmCal 	:= {}
aDadMoed 	:= {}
bFinalWiz := {||  If(nOpca == 1, ;
					(	lRet := Aviso(STR0010,STR0016,{STR0017, STR0018})==1,;  //"Atencao"##"Confirma os Dados"##"Sim"##"Nao"
						If(lRet, .T., (nOpca := 0, .F.)) ;
					),;//else
					NIL);
			}

aAdd(aWizCalAm, {cCadastro+" -> "+cCalend, STR0019+" ("+cCalend+") x "+STR0020+CRLF+STR0021, {||.T.}, {||.T.}, .T., {||.T.}, {||Ctb200Am(aPanelAm[1],cCadastro,cCalend,aDadAmCal,aDadMoed),nOpca := 1,.T.} })  //"Amarracao do Calendario"##"Moedas"##"Preencha e Confirme os Dados"

CtbWizard(aWizAmarCalen, aWizCalAm, aPanelAm, /*lCenter*/, bFinalWiz/*bValid*/, /*bInit*/, /*bWhen*/)

If Len(aDadAmCal) == Len(aDadMoed)
	For nX := 1 TO Len(aDadMoed)
		If aDadAmCal[nX]   //se grava amarracao de moeda x calendario
			Ctb200Inc("CTE",0,3/*nOpc*/,/*xReserv1*/,/*xReserv2*/,.T./*lGrvAssist*/,aDadMoed[nX, 2]/*cMoeda*/,cCalend)	
		EndIf
	Next
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ctb200Am  �Autor  �Microsiga           � Data �  06/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Montagem check-box para amarracao moeda x calendario        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Ctb200Am(oDlg,cCadastro,cCalend,aDadAmCal,aDadMoed)
Local aParam   := {}

Default aDadAmCal := {}
Default aDadMoed := {}

dbSelectArea("CTO")
dbSetOrder(1)

dbSeek(xFilial("CTO"))

While CTO->(! Eof() .And. CTO_FILIAL == xFilial("CTO") )
	aAdd(aDadMoed, { Recno(), CTO_MOEDA, CTO_DESC })
	aAdd(aDadAmCal, .T.)
	aAdd(aParam , {4,"",aDadAmCal[Len(aDadAmCal)],CTO_MOEDA+"-"+CTO_DESC,165,.F.,.F.})
	CTO->(dbSkip())
EndDo

ParamBox(aParam ,cCadastro, aDadAmCal,,,.F.,120,3, oDlg)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ctb200Cal �Autor  �Microsiga           � Data �  06/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para informar codigo do calendario (parammbox)         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Ctb200Cal(cCodCal)
Local lRet := .F.
Local aArea := GetArea()
Local aResp := {Space(Len(CTG->CTG_CALEND))}

If ParamBox({	{ 1 ,STR0012 , aResp[1] ,"@!" 	 ,""  ,"CTG" ,".T." ,65 ,.T. } },STR0022, aResp)  //"Calendario "##"Informe o Calendario"
	If VldCldWiz(aResp[1])	
		lRet := .T.
		cCodCal := aResp[1]
	Endif
EndIf
RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  VldCldWiz �Autor  gustavo.campos       � Data �  03/12/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o para verificar existencia do calendario           ���
���          �  na tela de (parammbox)                                    ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldCldWiz(cCodCal)   
Local lExist as Logical

Default lExist := .T. 
Default cCodCal := ""

CTG->(dbSetOrder(1))
If !CTG->(dbSeek(xFilial("CTG")+cCodCal))
	Aviso(STR0010, STR0012 + cCodCal + STR0024 ,{"OK"})
	lExist := .F. //N�o encontrou
Endif

Return lExist