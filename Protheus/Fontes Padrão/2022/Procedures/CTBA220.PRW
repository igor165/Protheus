#Include "CTBA220.Ch"
#Include "PROTHEUS.Ch"
#Include  "FONT.CH"
#Include  "COLORS.CH"

#DEFINE DEF_DB_ORACLE               "ORACLE"
#DEFINE DEF_DB_MSSQL                "MSSQL"
#DEFINE DEF_DB_MSSQL7               "MSSQL7"
#DEFINE DEF_DB_POSTGRES             "POSTGRES"
#DEFINE DEF_DB_DB2                  "DB2"
#DEFINE DEF_DB_INFORMIX             "INFORMIX"
#DEFINE DEF_DB_MYSQL                "MYSQL"
#DEFINE DEF_DB_SYBASE               "SYBASE"

STATIC nTamCta		:= Len(CriaVar("CT1_CONTA"))
STATIC nTamCC		:= Len(CriaVar("CTT_CUSTO"))
STATIC nTamItem		:= Len(CriaVar("CTD_ITEM"))
STATIC nTamClVl		:= Len(CriavAr("CTH_CLVL"))
STATIC cArqTrab		:= ""
STATIC cArqIND1		:= ""
STATIC cArqIND2		:= ""
STATIC nMAX_LINHA	:= CtbLinMax(GetMv("MV_NUMLIN"))
STATIC __lBlind		:= IsBlind()
STATIC __nChkFile	:= 1
Static lFWCodFil := FindFunction("FWCodFil")
Static lFWLoadSM0:= FindFunction("FWLoadSM0")
Static lCt2Contin      := .F.
Static _oCTBA2201

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ctba220  ³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Aglutina‡„o de dados                                       ³±±
±±³           ³ Segue o mesmo modelo do SIGACON -> Aglut mod A             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctba220()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ N„o h                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba220 (lBat)

Local aEmp		:= {}		// Matriz com todas as empresas do Sistema
Local aQuais				// Matriz com Arquivos a serem consolidados
Local cCadastro	:= STR0001	//"Consolida‡„o de Empresas / Filiais"
Local cVarQ 	:= "  "
Local cVarE 	:= "  "
Local cMensagem	:= ""
Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem	:= CtbSayApro("CTD")
Local cSayClVL	:= CtbSayApro("CTH")
Local nReg		:= SM0->(Recno())
Local nOpca
Local oDlg
Local oEmp
Local oQual
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local lMarcado  := __lBlind
Local cEmpresa	:= ""
Local cModo		:= ""
Local lExecCheck:= .F.
Local cFunction		:= "CTBA220"
Local cPerg			:= "CTB220"
Local cTitle		:= STR0001	//"Consolida‡„o de Empresas / Filiais"
Local cDescription	:= STR0032 + Chr(13) + Chr(10) +;//"A rotina de consolidação tem como objetivo permitir a emissão das demonstrações contábeis"
                       STR0033 + Chr(13) + Chr(10) +;//"consolidadas. As demonstrações contábeis consolidadas representam a integração das"
					STR0034	 + Chr(13) + Chr(10) +;//"demonstrações contábeis relativas a duas ou mais sociedades com personalidades jurídicas"
					STR0035 + Chr(13) + Chr(10) +;//	"distintas e têm como objetivo apresentar a sócios ou acionistas, credores e outros"
					STR0036 + Chr(13) + Chr(10) +;//	"interessados a posição financeira e os resultados das operações da empresa controladora e"
					STR0037	 + Chr(13) + Chr(10) +;//"de suas controladas, como se o conjunto dessas empresas fosse uma única empresa que tivesse"
					STR0038 //"uma ou mais filiais, departamentos ou divisões."

Local bProcess		:= { || .T. }
Local lRpo1_1		:= Iif(GetRpoRelease() == "R1.1",.T.,.F.)
Local lCt220Emp	:= IIf(ExistBlock("CT220EMP"),.T.,.F.)
Local lCt220Ent	:= IIf(ExistBlock("CT220ENT"),.T.,.F.)
Local aSM0			:= AdmAbreSM0()
Local nContFil		:= 0
Local nEmpAtu		:= aScan(aSM0,{ |x| x[SM0_GRPEMP] + x[SM0_CODFIL] == cEmpAnt + cFilAnt } )
Local nX		:= 0
Local nQtdEntid := If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor

Private aDados	:= {}
Private aRegCT0	:= {}     
Private __cEmpAnt := cEmpAnt
Private __cFilAnt := cFilAnt

DEFAULT lBat	:= .F.

If lBat
	lMarcado := .T.
Endif

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

dbSelectArea("CT1")
dbSelectArea("CT2")
dbSelectArea("CTZ")

If Ctb240Emp() //Se estiver na empresa/filial DESTINO (de acordo com o param. MV_CONSOLD
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Matriz com arquivos a serem consolidados			   ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aQuais := {	{.t.,STR0002},;		//"Plano de Contas"
				{.t.,STR0003},;	//"Lan‡amentos cont beis"
				{.t.,cSayCusto},;	//"Centros de Custos"
				{.t.,cSayItem},;	//"Item Contabil"
				{.t.,cSayCLVL}} 	//"Classe de Valor"

	For nContFil := 1 to Len(aSM0)
		If nContFil <> nEmpAtu
			cEmpAnt := aSM0[nContFil][SM0_GRPEMP]
			cFilAnt := aSM0[nContFil][SM0_CODFIL] 

			//Verificar através das funções de Frame o compartilhamento das tabelas
			cModo := FWModeAccess("CT2",3,cEmpAnt)	        

			// Isto garante que a empresa seja aberta somente uma vez!!
			aAdd(aEmp ,{lMarcado, aSM0[nContFil][SM0_GRPEMP], PADR(aSM0[nContFil][SM0_CODFIL],12)  + " " + aSM0[nContFil][SM0_NOME],"- "+ aSM0[nContFil][SM0_NOMRED],,cModo})

		EndIf
	Next nContFil

	aEmp := Ct220Ajust(aEmp)
	If lExecCheck
		RpcClearEnv()
		OpenSM0()
	EndIf
   	
	If lExecCheck
		RpcSetType(3)
		RpcSetEnv(aSM0[nEmpAtu][SM0_GRPEMP], aSM0[nEmpAtu][SM0_CODFIL],,"CTB")
	EndIf

	cEmpAnt := SM0->M0_CODIGO
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	
	//ponto de entrada para manipular array aQuais
	If lCt220Ent
		aQuais := ExecBlock("CT220ENT",.f.,.f.,{aQuais})
	EndIf
	//ponto de entrada para manipular array aEmp
	If lCt220Emp
		aEmp := ExecBlock("CT220EMP",.f.,.f.,{aEmp})
	EndIf

	IF Len(aEmp) == 0
		If !__lBlind
			Help(" ",1,"UNIFILIAL")
		EndIf
		
		CloseCTB220()
		DeleteObject(oOk)
		DeleteObject(oNo)
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra tela de aviso - processar exclusivo                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !__lBlind .And. ! lBat
		cMensagem := STR0004+chr(13)  		//"E' melhor que os arquivos associados a"
		cMensagem += STR0005+chr(13)  		//"esta rotina nao  estejam  em  uso  por"
		cMensagem += STR0006+chr(13)  		//"outras esta‡”es."
		cMensagem += STR0007+chr(13)  		//"Fa‡a com que os outros usu rios saiam do"
		cMensagem += STR0008+chr(13)  		//"sistema."
		IF !MsgYesNo(cMensagem,STR0009)		//"ATEN€O"
			CloseCTB220()
			Return
		Endif
	Else
		BatchProcess( 	cCadastro, cDescription, "CTB220",;
						{ || Ct220Prep(aEmp, aQuais, .T.,,aSM0) },;
						{ || .F. })
		
		CloseCTB220()				 
		Return .T.
	Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Limpa Consolidacao?                          ³
//³ mv_par02     // da data                                      ³
//³ mv_par03     // Ate a data                                   ³
//³ mv_par04     // Apaga? periodo  ou Tudo?                     ³
//³ mv_par05     // Escolhe Moeda?                               ³
//³ mv_par06     // Qual Moeda?                                  ³
//³ mv_par07     // Tipo de Saldo? X3_F3 = SLD                   ³
//³ mv_par08     // Gera lançamento de saldo inicial?            ³
//³ mv_par09     // Lote de saldo inicial?                       ³
//³ mv_par10     // SubLote de saldo inicial?                    ³
//³ mv_par11     // Documento de saldo inicial?                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("CTB220",.f.)
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80 OF oMainWnd

	DEFINE FONT oFnt1	NAME "Arial" 			Size 10,12 BOLD  	
	@ 0.3,.5 Say STR0001 FONT oFnt1 COLOR CLR_RED	  //" Consolida‡„o de Empresas / Filiais"

	@ 13,04 BUTTON STR0016 PIXEL OF oDlg SIZE 50,11; //"Inverte Selecao"
			ACTION ( aEval(oQual:aArray, {|e| 	e[1] := ! e[1] }), oQual:Refresh() )

	@ 2,.5  LISTBOX oQual VAR cVarQ Fields HEADER "",STR0010;
			  SIZE 150,100 ON DBLCLICK ;
			 (aQuais:=CT220Troca(oQual:nAt,aQuais,.F.),oQual:Refresh()) NOSCROLL	//"Arquivos a Consolidar"
	oQual:SetArray(aQuais)
	oQual:bLine := { || {if(aQuais[oQual:nAt,1],oOk,oNo),aQuais[oQual:nAt,2]}}

	@ 13,159 BUTTON STR0016 PIXEL OF oDlg SIZE 50,11; //"Inverte Selecao"
			 ACTION ( oEmp:aArray := Ct220InvSl(oEmp:aArray), oEmp:Refresh() )

	@ 2,20  LISTBOX oEmp VAR cVarE Fields HEADER "","",STR0011 ;
			 SIZE 150,100 ON DBLCLICK ;                  
			 (aEmp:=CT220Troca(oEmp:nAt,aEmp,.T.),oEmp:Refresh())  						//"Empresas a Consolidar"
	oEmp:SetArray(aEmp)
	oEmp:bLine := { || {if(aEmp[oEmp:nAt,1],oOk,oNo),aEmp[oEmp:nAt,2],aEmp[oEmp:nAt,3]}}
	If !lRpo1_1
		DEFINE SBUTTON FROM 130.5,230.8	TYPE 5 ACTION (Pergunte("CTB220",.t.)) ENABLE OF oDlg
	EndIf	
	DEFINE SBUTTON FROM 130.5,257.9	TYPE 1 ACTION (nOpca := 1,IF(ct220OK(aQuais,aEmp,aSM0,nEmpAtu),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 130.5,285	TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If	Empty (mv_par07) .OR. mv_par07 == "0"
   		Help(,,"CT2_TPSALD",,STR0049,1,0) //Saldos do tipo Orçado ou em Branco não podem ser consolidados
		Return
	EndIf
	
	If lRpo1_1                          
		aDados := { aEmp, aQuais }
		bProcess := { |oSelf| Ct220Prep(aDados[1],aDados[2],,oSelf,aSM0) }
		tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg )	
	Else  
		IF nOpca == 1
			Ct220Prep(aEmp, aQuais,.F.,,aSM0)
			DeleteObject(oOk)
			DeleteObject(oNo)			
		Endif
	EndIf	

Endif

cEmpAnt := __cEmpAnt	
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Prep ³ Autor  ³ Wagner Mobile Costa     ³ Data 09.04.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Prepara o ambiente para o processo de consolidacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctba220()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = Array contendo as empresas                         ³±±
±±³           ³ ExpA2 = Array contendo as empresas a serem consolidadas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Prep(aEmp,aQuais, lBat,oSelf, aSM0)

Local aEmpresas		:= {}		// Matriz somente com as empresas a serem consolidadas
Local lRet			:= .T.
Local lCt220Sel		:= IIf(ExistBlock("CT220Sel"),.T.,.F.)
Local lCt220Fpr 	:= IIf(ExistBlock("CT220Fpr" ),.T.,.F.)
Local nCont
Local lClVl			:=	CtbMovSaldo("CTH")
Local lItem			:=	CtbMovSaldo("CTD")
Local lCusto		:= CtbMovSaldo("CTT")
Local cOldAlias    	:= Alias()
Local nFKInUse    	:= 0
Local lRpo1_1		:= Iif(GetRpoRelease() == "R1.1",.T.,.F.)
Local iFilAux       := 0
Local iTamFil       := 0
Local iTamUni       := 0
Local iTamEmp       := 0
Local cLayOut       := FWSM0Layout()
Local lGestao       := .F.
Local iX            := 1
Local cQueryInt

ProcLogIni( {},"CTBA220" )
ProcLogAtu("INICIO",STR0055)//"PREPARAÇÃO DO AMBIENTE PARA PROCESSAMENTO DA CONSOLIDAÇÃO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a integridade referencial está ativa                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQueryInt := "SELECT count(*) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" + SM0->M0_CODIGO + "'"
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryInt), 'INTEGR', .F., .T.)
nFKInUse := INTEGR->TOTAL
INTEGR->( dbCloseArea() )
dbSelectArea(cOldAlias)

If Len(Alltrim(cLayOut)) == 0 .or. Len(CT2->CT2_FILIAL) == 2
	lGestao := .F.
	iTamFil := 2
Else
	lGestao := .T.
	For iX := 1 to Len(Alltrim(cLayOut))
		If "E" $ Substring(cLayOut,iX, 1)
			iTamEmp += 1
		EndIf
		If "U" $ Substring(cLayOut,iX, 1)
			iTamUni += 1
		EndIf
		If "F" $ Substring(cLayOut,iX, 1)
			iFilAux += 1
		EndIf
	Next
	iTamFil = iTamEmp + iTamUni + iFilAux 
Endif

DEFAULT lBat 	:= .F.

If mv_par05 == 2						// Considera Moeda Especifica
	aCtbMoeda := CtbMoeda(mv_par06)
	If Empty(aCtbMoeda[1])                       
		If !__lBlind
      		Help(" ",1,"NOMOEDA")
      	EndIf
      	lRet := .F.
   	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
//³VALIDACAO DE AMARRAÇÕES E BLOQUEIOS DE MOEDA/CALENDARIO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
MsgRun(STR0039 , STR0040, {|| lRet := !CtVlDTMoed(mv_par02,mv_par03,mv_par05,mv_par06) })//"Processando..."##"Validação moedas"
If lRet
	If mv_par08 == 1  // Gera Saldo Inicial
		If Empty(mv_par09) .or.Empty( mv_par10) .or.Empty( mv_par11)   // Limpa periodo
			MsgAlert( STR0048 )  //"Informar o Lote, Sublote e Documento Iniciais"
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet
	If mv_par08 == 1  // Gera Saldo Inicial
		If mv_par04 = 1  // Limpa periodo
			dbSelectArea("CT2")
			dbSetOrder(1)
			If dbSeek(xFilial("CT2")+DTOS(mv_par02-1),.F.)
				If !__lBlind
					MsgInfo(STR0029)   //"Ja existem dados na data de saldo inicial, saldo inicial nao sera gerado."
				EndIf
				mv_par08 := 2
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	If aQuais[2][1] .and. !aQuais[1][1] // Selecionou CT2 e nao selecionou CT1 verificar se existe CT
		If !__lBlind .And. !MsgYesNo(STR0030, STR0009) //"Se deseja continuar o processo verifique se todas as entidades dos lancamentos estao nos cadastros das tabelas destino"
			lRet:= .f.
		Else
			If (CT1->(EOF()) .and. CT1->(BOF()))
				aQuais[1][1] := .T.
				If lCusto
					aQuais[3][1] := .T.
				EndIf
				If lItem
					aQuais[4][1] := .T.
				EndIf
				If lClvl
					aQuais[5][1] := .T.
				EndIf
			EndIf
			If mv_par08 == 1  // Gera Saldo Inicial
					dbSelectArea("CT2")
					dbSetOrder(1)
					If dbSeek(xFilial("CT2")+DTOS(mv_par02-1),.F.)
						If !__lBlind
							MsgInfo(STR0029)  //"Ja existem dados na data de saldo inicial, saldo inicial nao sera gerado."
						EndIf
						mv_par08 := 2
					EndIf
			EndIf
		EndIf
	EndIf
Endif

If lRet
	//////////////////////////////////////////////////////////////////////////
	//  **** PONTO DE ENTRADA, enviando o conteudo do array aEmp e aQuais.  // 
	//  Retorna um valor logico para executar ou nao o processamento. Se    //
	//  ponto de entrada nao existir, executar o processamento normalmente  //
	//  caso contrario, verificar retorno do ponto de entrada               //
	//////////////////////////////////////////////////////////////////////////
	If !lCt220Sel .or. (lCt220Sel .And. ExecBlock("CT220SEL",.f.,.f.,{aEmp,aQuais}))
		aAreaSM0 := SM0->(GetArea())
		For nCont := 1 To Len(aEmp)
			If aEmp[nCont][1]
				SM0->(dbSeek(aEmp[nCont][2])) // Para pegar corretamente o tamanho da filial posicionada
				AADD(aEmpresas,{aEmp[nCont][2], Substr(aEmp[nCont][3],1, iTamFil )})
			EndIf	
		Next nCont
		RestArea(aAreaSM0)
		If FindFunction("CTBSERIALI")
			If !CTBSerialI("CTBPROC","OFF")
				Return
			Endif
		EndIf
	    If lBat
	    	CT220Proc(aEmpresas,aQuais, .T.,nFkInUse,,aSM0)
	    Else            
	    	If lRpo1_1
				CT220Proc(aEmpresas,aQuais,,nFkInUse,oSelf, aSM0)
	    	Else
				Processa({|lEnd| CT220Proc(aEmpresas,aQuais,,nFkInUse,, aSM0)})
			EndIf	
		Endif
		If FindFunction("CTBSERIALI")
			CTBSerialF("CTBPROC","OFF")
		EndIF
	EndIf

	If mv_par01 == 1 		// Reabro os arquivos de forma compartilhada
      	CloseCTB220()        // Caso escolha para eliminar por periodo
      	OpenFile(SubStr(cNumEmp,1,2))
 	Endif
ProcLogAtu("FIM",STR0055)//STR0055 - "PREPARAÇÃO DO AMBIENTE PARA PROCESSAMENTO DA CONSOLIDAÇÃO"			
EndIf

//Ponto de Entrada para tratamento de dados após preparação do ambiente.
If lCt220Fpr
	ExecBlock("CT220FPR",.F.,.F.)
EndIf	

If __lBlind
	// por garantia, fecho todas as tabelas do ambiente contabil
	CloseCTB220()
Endif	

Return .T.	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct220Proc³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Inicia o processamento dos arquivos de consolidacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctba220()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = Array contendo as empresas                         ³±±
±±³           ³ ExpA2 = Array contendo as empresas a serem consolidadas    ³±±
±±³           ³ lBat  = Indica se o processo esta em modo batch            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct220Proc(aEmpresas,aQuais, lBat, nFkInUse, oSelf, aSM0)

Local cChave
Local nCont
Local lRet 		:= .T.
Local dDataIni		:= mv_par02
Local dDataFim		:= mv_par03
Local lGerLanIni	:= Iif(mv_par08 == 1,.T.,.F.)
Local lMoedaEsp		:= Iif(mv_par05 == 2,.T.,.F.)
Local lClVl			:=	CtbMovSaldo("CTH")
Local lItem			:=	CtbMovSaldo("CTD")
Local lCusto		:= 	CtbMovSaldo("CTT")
Local cLote   		:= mv_par09
Local cSubLote  	:= mv_par10
Local cDoc   		:= mv_par11
Local aCTOxCTE		:= {}
Local aTpSaldos		:= {}
Local nMoeda		:= 0          
Local cMoeda		:= mv_par06
Local cModoSX2 	:= ""
Local cArquivoD  	:= ""  // Arquivo de saldo Diario
Local cArquivoM  	:= ""  // Arquivo de saldo Mensal
Local cFilBack    := ""	
Local cEmpBack	:= ""
Local lRpo1_1		:= Iif(GetRpoRelease() == "R1.1",.T.,.F.)
Local nX
Local cAuxFil		:= ""
Local cEmpAux		:= ""
Local aPrgt220	:= { mv_par02 , mv_par03 , mv_par07 , mv_par05 , mv_par06 }//Parâmetros para o schedule, chamada dos saldos, CTBA190
Local lDelFisico	:=	GetNewPar('MV_CTB220D',.T.) 
Local aAlias    := {}
Local cQuery	:= ""
Local nMax		:= 0
Local i,y
Local lRetorno := .F.
Local cCodigoSup
Local cCodigo
Local cAliasAtu
Local nRecno    := 0
Local cProc     := ""
Local cProcName := "CTB220DEL"
Local cRet      := "0"
Local aResult   :={}
Local lCriou    := .F.
Local cMaxRecno := ""
Local nMaxRecno := IIF(Alltrim(Upper(TcGetDB())) == "INFORMIX",1024,4096)
Local cChaveUnica:=""

ProclogAtu("INICIO",STR0056)//PROCESSAMENTO DOS ARQUIVOS DE CONSOLIDAÇÃO
DEFAULT lBat	:= .F.

If mv_par01 == 1
	If	!(	MA280FLock("CT1") .And.;
			MA280FLock("CT2") .And.;
			MA280FLock("CQ0") .And.;
			MA280FLock("CQ1") .And.;
			MA280FLock("CQ2") .And.;
			MA280FLock("CQ3") .And.;
			MA280FLock("CQ4") .And.;
			MA280FLock("CQ5") .And.;
			MA280FLock("CQ6") .And.;
			MA280FLock("CQ7") .And.;
			MA280FLock("CTC") .And.;
			MA280FLock("CTD") .And.;
			MA280FLock("CTF") .And.;
			MA280FLock("CTH") .And.;
			MA280FLock("CTT") .And.;
			MA280FLock("CTZ") .And.;
			MA280FLock("CTK") .And.;
			MA280FLock("CV1") .And.;
			MA280FLock("CV2") .And.;
			MA280FLock("CV3") )
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Fecha todos os arquivos e reabre-os de forma compartilhada   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CloseCTB220()
		OpenFile(SubStr(cNumEmp,1,2))
		Return .T.
	Else
		If mv_par04 == 2					// Apaga os arquivos
		                                      		
			aAlias := {}
				
			For y := 1 to Len(aQuais)
				If aQuais[y][1]
					Do Case
					Case y == 1	//Plano de contas
						Aadd(aAlias,"CT1")
					Case y == 2	//Lancamentos Contabeis
						Aadd(aAlias,"CT2")
						Aadd(aAlias,"CTZ")
						Aadd(aAlias,"CTK")
						Aadd(aAlias,"CV1")
						Aadd(aAlias,"CV3")
						Aadd(aAlias,"CV2")
						Aadd(aAlias,"CQ0")
						Aadd(aAlias,"CQ1")
						Aadd(aAlias,"CQ2")
						Aadd(aAlias,"CQ3")
						Aadd(aAlias,"CQ4")
						Aadd(aAlias,"CQ5")
						Aadd(aAlias,"CQ7")
						Aadd(aAlias,"CQ8")
						Aadd(aAlias,"CQ9")
						Aadd(aAlias,"CTC")
						Aadd(aAlias,"CTF")
					Case y == 3	//Centro de Custos
						Aadd(aAlias,"CTT")
					Case y == 4	//Item Contas
						Aadd(aAlias,"CTD")
					Case y == 5	//Cod Classe de Valor
						Aadd(aAlias,"CTH")
					EndCase
				EndIf
			Next y

			For i := 1 to Len(aAlias)

				cQuery := ""
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Integridade Ativa        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nFKinUse > 0
					If aAlias[i] $ "CTH/CTD/CTT/CT1"
						dbSelectArea(aAlias[i])
						If !lCriou
							cProc := Ctb220DEL(cEmpAnt, cFilAnt, aAlias[i])
							If TCSPExist( cProcName+"_"+cEmpAnt )
								cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
								If cRet <> 0
									If !__lBlind
										MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt,aAlias[i]+"...D1.")  //'Erro na exclusao da procedure'
									EndIf
									Return .f.
								EndIf
							EndIf
							cRet := TcSqlExec(cProc)
							If cRet < 0
								If !__lBlind
									MsgAlert(STR0021+" "+cProcName+"_"+cEmpAnt,aAlias[i]+"...D2.")  //'Erro na criacao da procedure'
								EndIf
								Return .f.
							EndIf
							lCriou := .T.  // Criou procedure
						EndIf
						aResult := TCSPExec( xProcedures(cProcName), cFilAnt, aAlias[i], If(lDelFisico, "1", "0"))
						If Empty(aResult)
							If !__lBlind
								MsgAlert(STR0017+" "+cProcName+"_"+cEmpAnt,aAlias[i]+"...D3.")  //'Erro na chamada do processo'
							EndIf
							If TCSPExist(cProcName+"_"+cEmpAnt)
								cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
								If cRet <> 0
									If !__lBlind
										MsgAlert(STR0019+" "+cProc)  //'Erro na exclusao da procedure'
									EndIf
									Return .f.
								EndIf
							EndIf
						EndIf
					Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Nao usar a funcao LastRec para buscar o mair recno da tabela, pois apos a execucao de update ou delete  ³
							//³o TOP nao atualiza os RECNO's.                                                                          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						cMaxRecno := " SELECT MAX( R_E_C_N_O_) RECNO FROM "+RetSqlName(aAlias[i])
						cMaxRecno := ChangeQuery(cMaxRecno)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cMaxRecno),"MAXRECNO")
						nMax := MAXRECNO->RECNO
						MAXRECNO->(dbCloseArea())
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						For nX := 1 To nMax STEP nMaxRecno
							If lDelFisico
								cQuery := "UPDATE "+RetSqlName(aAlias[i])+ " SET D_E_L_E_T_ = '*' WHERE "+aAlias[i]+"_FILIAL = '"+xFilial(aAlias[i])+"' AND "
								cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+(nMaxRecno-1),10,0)+""
								TcSqlExec(cQuery+cChave)
									
								cQuery := "DELETE FROM "+RetSqlName(aAlias[i])+ " WHERE D_E_L_E_T_ = '*'  AND " +aAlias[i]+"_FILIAL = '"+xFilial(aAlias[i])+"' AND "
								cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+(nMaxRecno-1),10,0)+""
								TcSqlExec(cQuery+cChave)
							else
								cQuery := "UPDATE "+RetSqlName(aAlias[i])+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE "+aAlias[i]+"_FILIAL = '"+xFilial(aAlias[i])+"' AND D_E_L_E_T_ = ' ' AND "
								cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+(nMaxRecno-1),10,0)+""
								TcSqlExec(cQuery+cChave)
							EndIf
						Next nX
					EndIf
				else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Nao usar a funcao LastRec para buscar o mair recno da tabela, pois apos a execucao de update ou delete  ³
						//³o TOP nao atualiza os RECNO's.                                                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
					cMaxRecno := " SELECT MAX( R_E_C_N_O_) RECNO FROM "+RetSqlName(aAlias[i])
					cMaxRecno := ChangeQuery(cMaxRecno)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cMaxRecno),"MAXRECNO")
					nMax := MAXRECNO->RECNO
					MAXRECNO->(dbCloseArea())
					For nX := 1 To nMax STEP nMaxRecno
						If lDelFisico
							cQuery := "DELETE FROM "+RetSqlName(aAlias[i])+ " WHERE "+aAlias[i]+"_FILIAL = '"+xFilial(aAlias[i])+"' AND "
							cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+(nMaxRecno-1),10,0)+""
							TcSqlExec(cQuery+cChave)
						else
							cChaveUnica := tcInternal(13, Alltrim(RetSqlName(aAlias[i])))
							If !Empty(cChaveUnica)
								cQuery := "UPDATE "+RetSqlName(aAlias[i])+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE "+aAlias[i]+"_FILIAL = '"+xFilial(aAlias[i])+"' AND D_E_L_E_T_ = ' ' AND "
							else
								cQuery := "UPDATE "+RetSqlName(aAlias[i])+ " SET D_E_L_E_T_ = '*' WHERE "+aAlias[i]+"_FILIAL = '"+xFilial(aAlias[i])+"' AND D_E_L_E_T_ = ' ' AND "
							End
							cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+(nMaxRecno-1),10,0)+""
							TcSqlExec(cQuery+cChave)
						Endif
					Next nX
				Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³A tabela eh fechada para restaurar o buffer da aplicacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(aAlias[i])
				dbCloseArea()
				ChkFile(aAlias[i],.F.)
			Next
			If lCriou .and. nFkInUse > 0
				If TCSPExist(cProcName+"_"+cEmpAnt)
					cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
					If cRet <> 0
						If !__lBlind
							MsgAlert(STR0019+" "+cProc)  //'Erro na exclusao da procedure'
						EndIf
						Return .f.
					EndIf
				EndIf
			EndIf
		
			CloseCTB220()
			//Seta Empresa Consolidadora (Destino) para que seja feita a inclusão
			cEmpAnt := __cEmpAnt
			cFilant := __cFilAnt
			OpenFile(SubStr(cNumEmp,1,2))
		Else						// Zera somente o periodo informado
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Zera valores de saldos no periodo a consolidar - SI1/SI7     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Ct220Apaga()
		EndIf
	EndIf
Else	/// Caso não apague os lançamentos na empresa consolidadora.

	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSeek(xFilial("CT2")+DTOS(mv_par02),.T.)
	If !Eof() .and. CT2->CT2_DATA <= mv_par03
		If !__lBlind .And. !MsgNoYes(STR0022+;//"Existem lançamentos na empresa consolidadora neste período. "
			STR0023+;//"(Recomendado processamento apagando período a ser consolidado)."
			STR0024,;//" Deseja realmente continuar ? "
			STR0025)//"Periodo já consolidado !"
			Return
		Else
			lCt2Contin := .T.
		EndIf
	EndIf

Endif

If ! lBat
	If lRpo1_1
		oSelf:SetRegua1(Len(aEmpresas)*Len(aQuais))
	Else
		ProcRegua(Len(aEmpresas)*Len(aQuais))
	EndIf
Endif

//Cria arquivo de trabalho
Ct220CrTrb()

lRetorno := Ct220conso(cEmpAnt,aEmpresas, aQuais, aSM0)
	
If lRetorno
	lRet := lRetorno
Else

	For nCont := 1 To Len(aEmpresas)
		
		// Abre SX2 das Empresas Selecionadas - Se elemento em bco -> empresa ja foi aberta
		// anteriormente                         
		If !Empty(aEmpresas[nCont][1])
			Ct220Open(aEmpresas[nCont][1])
		ElseIf 	(nCont > 1 .Or. Select("SX2TMP") = 0) .And. (!Empty(aEmpresas[nCont][1]) .Or. Select("SX2TMP") = 0 )	// Abro o SX2 da empresa atual, caso consolide
			If Empty(aEmpresas[nCont][1])
				Ct220Open(cEmpAnt) 		// filiais da empresa atual e tenha outra empresa
			Else
				Ct220Open(aEmpresas[nCont][1]) 		// filiais da empresa atual e tenha outra empresa
			EndIf
		EndIf									// antes da empresa selecionada Bops 14036
		cFilX		:= aEmpresas[nCont][2]
		cEmpX		:= aEmpresas[nCont][1]
		
		If cEmpX != cEmpAux .OR. ( cEmpX == cEmpAux .And. cAuxFil != xFilial("CT2",cFilX))
			cAuxFil := xFilial("CT2",cFilX)
			cEmpAux	:= aEmpresas[nCont][1]
		Else
			Loop
		EndIf
		
		If lGerLanIni	//Se gera lote de lançamentos de saldo inicial
			If nCont == 1
				AADD(aTpSaldos,mv_par07)
				
				If lMoedaEsp //Moeda especifica
					//O primeiro elemento da matriz sempre sera ref. a moeda 01.
					//Caso seja moeda especifica diferente da '01', o primeiro elemento sera 
					//a moeda '01' com conteudo vazio.
					If cMoeda <> '01'
						aAdd(aCTOxCTE,{'01',"",CTOD("  /  /  ")})
					EndIf
					aAdd(aCTOxCTE,{cMoeda,"",dDataIni})
				Else
					For nMoeda := 1 to __nQuantas
						aAdd(aCTOxCTE,{StrZero(nMoeda,2),"",dDataIni})
					Next
				EndIf
			EndIf
			
			dbSelectArea("TRB")
			dbGoTop()
			While !Eof()
				RecLock("TRB",.F.)
				DbDelete()
				MsUnlock()
				dbSkip()
			EndDo
					
			cFilBack	:= cFilAnt
			cFilAnt		:= cFilX
			cEmpBack	:= cEmpAnt
			cEmpAnt		:= cEmpX
		
			If lClvl .And. Ct220Alias("CQ6",@cModoSX2,@cArquivoM,cEmpX) .And. Ct220Alias("CQ7",@cModoSX2,@cArquivoD,cEmpX)
				dbSelectArea("CQ6")
				dbCloseArea()
				ChkFile("CQ6", .F., "CQ6",,,,, "SX2TMP")
				CTB220GTRB("CQ6",aCTOxCTE,aTpSaldos,,lCusto,lItem,lClvl,lMoedaEsp,cMoeda,cModoSX2,lBat,oSelf,cArquivoM,cArquivoD)
				dbCloseArea()
				ChkFile("CQ6", .F.)
			EndIf
	
			/// VERIFICO OS SALDOS DO ITEM CONTABIL (CT4) GRAVANDO NO TRB.		
			If lItem .And. Ct220Alias("CQ4",@cModoSX2,@cArquivoM,cEmpX) .And. Ct220Alias("CQ5",@cModoSX2,@cArquivoD,cEmpX)
				dbSelectArea("CQ4")
				dbCloseArea()
				ChkFile("CQ4", .F., "CQ4",,,,, "SX2TMP")
				CTB220GTRB("CQ4",aCTOxCTE,aTpSaldos,,lCusto,lItem,lClvl,lMoedaEsp,cMoeda,cModoSX2,lBat,oSelf,cArquivoM,cArquivoD)
				dbCloseArea()
				ChkFile("CQ4", .F.)
			EndIf
			
			/// VERIFICO OS SALDOS DO CENTRO DE CUSTO(CQ3) GRAVANDO NO TRB.
			If lCusto .And. Ct220Alias("CQ2",@cModoSX2,@cArquivoM,cEmpX) .And. Ct220Alias("CQ3",@cModoSX2,@cArquivoD,cEmpX)
				dbSelectArea("CQ2")
				dbCloseArea()
				ChkFile("CQ2", .F., "CQ2",,,,, "SX2TMP")
				CTB220GTRB("CQ2",aCTOxCTE,aTpSaldos,,lCusto,lItem,lClvl,lMoedaEsp,cMoeda,cModoSX2,lBat,oSelf,cArquivoM,cArquivoD)
				dbCloseArea()
				ChkFile("CQ2", .F.)
			EndIf
	
			/// VERIFICO OS SALDOS DA CONTA.(CT7) GRAVANDO NO TRB.		
			If Ct220Alias("CQ0",@cModoSX2,@cArquivoM,cEmpX) .and. Ct220Alias("CQ1",@cModoSX2,@cArquivoD,cEmpX)
				dbSelectArea("CQ0")
				dbCloseArea()
				ChkFile("CQ0", .F., "CQ0",,,,, "SX2TMP")
				CTB220GTRB("CQ0",aCTOxCTE,aTpSaldos,,lCusto,lItem,lClvl,lMoedaEsp,cMoeda,cModoSX2,lBat,oSelf,cArquivoM,cArquivoD)
				dbCloseArea()
				ChkFile("CQ0", .F.)
			EndIf
			
			cFilAnt		:= cFilBack
			cEmpAnt		:= cEmpBack
			
			//GRAVA OS LANCAMENTOS DE SALDO INICIAL na empresa CONSOLIDANTE        
			Ct220GrLan(aCTOxCTE,cLote,cSubLote,@cDoc,lMoedaEsp)
			
		EndIf
			
		
		// Cadastro Plano de Contas
		ProcLogAtu("INICIO",STR0057 )//"VERIFICAÇÃO DOS CADASTROS"
		If aQuais[1][1]
			cChave	:= "Aglutina->CT1_CONTA"
			If lRet
				lRet := Ct220Cad("CT1",1,cChave,cFilX,,cEmpX)
			EndIf
		EndIf
	
		// Cadastro Centro de Custo
		If aQuais[3][1]
			cChave	:= "Aglutina->CTT_CUSTO"
			If lRet
				lRet := Ct220Cad("CTT",1,cChave,cFilX,,cEmpX)
			EndIf
		EndIf
		
		// Cadastro Itens Contabeis
		If aQuais[4][1]
			cChave	:= "Aglutina->CTD_ITEM"
			If lRet
				lRet := Ct220Cad("CTD",1,cChave,cFilX,,cEmpX)
			EndIf
		EndIf
	
		// Cadastro Classe de Valor
		If aQuais[5][1]
			cChave	:= "Aglutina->CTH_CLVL"
			If lRet
				lRet := Ct220Cad("CTH",1,cChave,cFilX,,cEmpX)
			EndIf
		EndIf
		ProcLogAtu("FIM",STR0057)//Fim "VERIFICAÇÃO DOS CADASTROS"
		// Lancamentos Contabeis
		If aQuais[2][1]
			ProcLogAtu("INICIO",STR0058 )//"VERIFICAÇÃO DE LANÇAMENTO CONTÁBEIS"
			// Utiliza a mesma rotina dos saldos, pois a chave de busca usa a data
			
			// Numeracao de Documento
			cChave 	:= "DTOS(Aglutina->CTF_DATA)+Aglutina->CTF_LOTE+Aglutina->CTF_SBLOTE+Aglutina->CTF_DOC"
			If lRet
				lRet := Ct220Saldo("CTF",1,cChave,cFilX,cEmpX)
			EndIf
			//COLOCADO TODA CHAVE DO INDICE 1 DA TABELA CT2
			cChave	:= "DTOS(Aglutina->CT2_DATA)+Aglutina->CT2_LOTE+Aglutina->CT2_SBLOTE+"
			cChave	+="Aglutina->CT2_DOC+Aglutina->CT2_LINHA+Aglutina->CT2_TPSALD+"
			cChave	+="Aglutina->CT2_EMPORI+Aglutina->CT2_FILORI+Aglutina->CT2_MOEDLC"
			 						
			If lRet
				lRet := Ct220Saldo("CT2",1,cChave,cFilX,cEmpX)
			EndIf
			
			cChave	:= "DTOS(Aglutina->CTZ_DATA)+Aglutina->CTZ_LOTE+Aglutina->CTZ_SBLOTE+Aglutina->CTZ_DOC+Aglutina->CTZ_TPSALD+Aglutina->CTZ_EMPORI+Aglutina->CTZ_FILORI+Aglutina->CTZ_MOEDLC+Aglutina->CTZ_LINHA+Aglutin->CTZ_SEQLIN)"
			
			If lRet
				lRet := Ct220Saldo("CTZ",1,cChave,cFilX,cEmpX)
			EndIf
			ProcLogAtu("FIM",STR0058)//"VERIFICAÇÃO DE LANÇAMENTO CONTÁBEIS"
		EndIf
	   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Novas Entidades³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If !Empty(aRegCT0)
			For nX:=5 To Len(aRegCT0)
				If aQuais[nX+1][1]
					If aRegCT0[nX][1] == "CV0"
						cChave	:= "Aglutina->(CV0_PLANO+"+aRegCT0[nX][4]+")"
					Else
						cChave	:= "Aglutina->"+aRegCT0[nX][4]
					EndIf
					If lRet 
						lRet := Ct220Cad(aRegCT0[nX][1],1,cChave,cFilX,aRegCT0[nX][2],cEmpX)
					EndIf
					If !lRet
						nX := Len(aRegCT0)+1
					EndIf
				EndIf
			Next nX
		EndIf
		If !lRet
			Exit
		EndIf
	
	Next nCont
	           
	//CHAMA O REPROCESSAMENTO PARA ATUALIZAR OS SALDOS.
	/// ATUALIZA OS SALDOS AO FINAL DO PROCESSAMENTO
	ProcLogAtu("INICIO",STR0059)//"REPROCESSAMENTO PARA ATUALIZAR OS SALDOS"
	If !__lBlind
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,mv_par02-1,mv_par03,cFilAnt,cFilAnt,mv_par07,mv_par05 == 2,mv_par06)		},"","",.F.)
		oProcess:Activate()
	Else
		Pergunte( "CTB190" , .F. )
		BatchProcess("","","CTB190",{||CTBA190(.F.,aPrgt220[1]-1,aPrgt220[2],cFilAnt,cFilAnt,aPrgt220[3],aPrgt220[4] == 2,aPrgt220[5])},{||.F.})
		Pergunte( "CTB220" , .F. )
	EndIf
	ProcLogAtu("FIM",STR0059)
	///	APAGA O ARQUIVO DE TRABALHO
	dbSelectArea("TRB")
	dbCloseArea()
	//Deleta tabela temporaria criada no banco de dados
	If _oCTBA2201 <> Nil
		_oCTBA2201:Delete()
		_oCTBA2201 := Nil
	Endif
	

EndIf

If lRet .and. ExistBlock("CT220REL")
	ExecBlock("CT220REL",.F.,.F.)
Endif

DbSelectArea("CT1")
ProclogAtu("FIM",STR0056)//PROCESSAMENTO DOS ARQUIVOS DE CONSOLIDAÇÃO

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct220Cad ³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera Registros de Cadastro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Cad(cAlias,nOrder,cChave,cFilx)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = Alias do arquivo                                   ³±±
±±³           ³ ExpN1 = Ordem                                              ³±±
±±³           ³ ExpC2 = Chave                                              ³±±
±±³           ³ ExpC3 = Conteudo do campo filial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Cad(cAlias,nOrder,cChave,cFilX,cEntidade,cEmpAlias)

Local nPos
Local nCont
Local lRet	:= .F.
Local cModoSX2 := ""
Local cCond := ""
Local cArquivo  := ""
Local Aglutina := ""               
Local aStru		:= {}	
Local nI

Default cEntidade := ""
                 
If Ct220Alias(cAlias,@cModoSX2,@cArquivo,cEmpAlias)
	lRet	:= .T.
	If cModoSX2 == "C"
		cFilX := ""
		cCond := "ARQ.D_E_L_E_T_ <> '*'"
	Else
		cCond :="ARQ.D_E_L_E_T_ <> '*' AND ARQ." +cAlias+"_FILIAL = '"+  xFilial(cAlias,cFilX) + "'"
	Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Novas Entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	If cAlias == "CV0"
		cCond += " AND ARQ.CV0_PLANO = '"+cEntidade+"' "
	EndIf
			                
	cCampoFilial := cAlias+"_FILIAL"
	Aglutina := "Aglutina"
	cQuery := "SELECT * "
	cQuery += "FROM "+ cArquivo +" ARQ "
	cQuery += "WHERE " + cCond
	cQuery := ChangeQuery(cQuery)

	If ( Select ( "Aglutina" ) <> 0 )
		dbSelectArea ( "Aglutina" )
		dbCloseArea ()
	Endif
					
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),Aglutina,.T.,.F.)
			
	aStru := (cAlias)->(dbStruct())
			 
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField(Aglutina, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next ni
	dbSelectArea(Aglutina)
	dbGotop()
	While !Eof()
		dbSelectArea(cAlias)
		If !dbSeek(xFilial(cAlias)+&(cChave))
			RecLock(cAlias,.T.)
			For nCont := 1 to Fcount()
				If Trim(FieldName(nCont)) == cCampoFilial
					&(cCampoFilial) := xFilial(cAlias)
				Else
					dbSelectArea(Aglutina)
					cCampo := FieldName(nCont)
					
					dbSelectArea(cAlias)
					nPos := FieldPos(cCampo)
					      
					If (nPos != 0 )
						FieldPut(nPos,Aglutina->(FieldGet(Aglutina->(FieldPos(cCampo)))))
					EndIf
		      
				EndIf
			Next nCont
			MsUnlock()
		EndIf
		dbSelectArea(Aglutina)
		dbSkip()
	End
	dbSelectArea(Aglutina)
	dbCloseArea ()
	    Endif   		 

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Saldo³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera Registro de arquivo de Saldo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Saldo(cAlias,nOrder,cChave,cFilx)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = Alias do arquivo                                   ³±±
±±³           ³ ExpN1 = Ordem                                              ³±±
±±³           ³ ExpC2 = Chave                                              ³±±
±±³           ³ ExpC3 = Conteudo do campo filial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Saldo(cAlias,nOrder,cChave,cFilX,cEmpAlias)

Local nPos
Local nCont
Local lRet	:= .F.           
Local cModoSX2 := ""
Local cCond := ""
Local cArquivo := ""
Local lCt220Doc	:= IIf(ExistBlock("CT220DOC" ),.T.,.F.)
Local lCt220Skip:= IIf(ExistBlock("CT220SKIP"),.T.,.F.)
Local lCt220Flag:= IIf(ExistBlock("CT220FLAG"),.T.,.F.)
Local lOrigemOK := .F.
Local aStru		:= {}
Local ni

	If Ct220Alias(cAlias,@cModoSX2,@cArquivo,cEmpAlias)
                                                        
		// Abrindo o CT2 origem com o alias "CT2Origem", para que antes de processar o ponto de entrada CT220Flag,
		// possamos posicioná-lo corretamente
		If lCt220Flag .And. ( Upper(cAlias) == "CT2" )
			If Select("CT2Origem") > 0
				CT2Origem->( DbCloseArea() )
			EndIf
            lOrigemOK := ChkFile(cAlias, .F., "CT2Origem",,,,, "SX2TMP")
			If lOrigemOK
				CT2Origem->( DbSetOrder(1) )
			EndIf
		EndIf

		lRet	:= .T.
		If cModoSX2 == "C"
			cFilX := ""      
			cCond := "ARQ.D_E_L_E_T_ <> '*'" + " AND ARQ." +cAlias+"_DATA >= '" +  DTOS(mv_par02)+ "' AND ARQ." +cAlias+"_DATA <= '" +  DTOS(mv_par03)+"'"						
		Else
			cCond :="ARQ.D_E_L_E_T_ <> '*'AND ARQ." +cAlias+"_FILIAL = '"+ xFilial(cAlias,cFilX) + "' AND ARQ." +cAlias+"_DATA >= '" + DTOS(mv_par02)+"' AND ARQ." +cAlias+ "_DATA <= '" + DTOS(mv_par03)+"'"
		Endif                 
		cCampoFilial 	:= cAlias+"_FILIAL"              
		cCampoData		:= cAlias+"_DATA"
		cCampoMoeda		:= cAlias+"_MOEDA"
		cCampoTPSald	:= cAlias+"_TPSALD"

		Aglutina := "Aglutina"   		
		cQuery := "SELECT * "
		cQuery += "FROM "+ cArquivo +" ARQ "
		cQuery += "WHERE " + cCond
		cQuery := ChangeQuery(cQuery)
		If ( Select ( "Aglutina" ) <> 0 )
			dbSelectArea ( "Aglutina" )
			dbCloseArea ()
		Endif
				
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),Aglutina,.T.,.F.)
		aStru := (cAlias)->(dbStruct())
		 
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(Aglutina, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next ni											
		
		dbSelectArea(Aglutina)				
		
		While !Eof() 
			If mv_par05 == 2					// Considera moeda especifica
				If cAlias != "CTF"
					If cAlias == "CT2"
						If CT2_MOEDLC != mv_par06
							dbSkip()
							Loop
						EndIf 
					ElseIf cAlias == "CTZ"
						If CTZ_MOEDLC != mv_par06
							dbSkip()
							Loop
						EndIf 						
					ElseIf &(cCampoMoeda) != mv_par06
						dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf	

			If mv_par07 != "*"					// mv_par07 == 1 -> Todos os saldos
				If cAlias != "CTF"
					If	&(cCampoTpSald) != mv_par07
						dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf				
			
			If lCt220Skip
				lRet := ExecBlock("CT220SKIP",.F.,.F.,{cAlias})
				If !lRet
					dbSkip()
					Loop
				EndIf
			Endif

			dbSelectArea(cAlias)
			dbSetOrder(nOrder)
     
			// O arquivo de lancamento contabil sempre devera ter os lancamentos contabeis
			// separados (por causa do razao)!!		
			If !(cAlias $ "CT2/CTZ") .OR. ( mv_par01 == 2 .And. lCt2Contin)
				If !dbSeek(xFilial(cAlias)+&(cChave))
					RecLock(cAlias,.T.)
				Else
					RecLock(cAlias)
				EndIf		
			Else
				RecLock(cAlias,.T.)				
			EndIf	

			For nCont := 1 to Fcount()     
				If Trim(FieldName(nCont)) == cCampoFilial
					&(cCampoFilial) := xFilial(cAlias)
				Else	                                          
					dbSelectArea("Aglutina")
					cCampo := FieldName(nCont)
					
					If Alltrim(cCampo) == cCampoFilial
						Loop
					EndIf
		
					dbSelectArea(cAlias)
			   	   	nPos 	:= FieldPos(cCampo)
			   	   	If nPos != 0
   						If ValType(&(cCampo)) == "N"					// Campo Numerico
					      	 nValor := FieldGet(nPos)
			    	    	 FieldPut(nPos,;
		    	    	     nValor + Aglutina->(FieldGet(Aglutina->(FieldPos(cCampo)))))
						Else	      
				    	     FieldPut(nPos,Aglutina->(FieldGet(Aglutina->(FieldPos(cCampo)))))
				      	EndIf
					EndIf	  
				EndIf
			Next nCont	
			If lCt220Doc
				lRet := ExecBlock("CT220DOC",.F.,.F.,{cAlias})
			Endif	
			MsUnlock()
			If lCt220Flag .And. ( Upper(cAlias) == "CT2" ) .And. lOrigemOK
				// Posicionando no registro do CT2 de origem para receber gravacao a partir do Ponto de Entrada
		   		dbSelectArea("CT2Origem")
				If DbSeek( Aglutina->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+;
   				                      CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC) )
					lRet := ExecBlock("CT220FLAG",.F.,.F.,{"CT2Origem"})
				EndIf
			EndIf
		   	dbSelectArea(Aglutina)		   	
			dbSkip()
		End
		dbSelectArea(Aglutina)
		dbCloseArea ()				
	Else
	If Ct220Alias(cAlias,@cModoSX2,@cArquivo,cEmpAlias)				// Abre a area "Aglutina" -> dados origem
		lRet := .T.
		dbSelectArea("Aglutina")
		dbSetOrder(nOrder)
		If cModoSX2 == "E"
			dbSeek(xFilial(cAlias,cFilX)+Dtos(mv_par02),.t.)
			cCond :="!Eof()	.And. &(cCampoFilial) == cFilX .And.DTOS(&(cCampoData)) <= DTOS(mv_par03)" 
		Else                                  
			dbSeek("  "+Dtos(mv_par02),.t.)
			cCond := "!Eof().And. DTOS(&(cCampoData)) <= DTOS(mv_par03)"
		Endif	

		cCampoFilial 	:= cAlias+"_FILIAL"              
		cCampoData		:= cAlias+"_DATA"
		cCampoMoeda		:= cAlias+"_MOEDA"
		cCampoTPSald	:= cAlias+"_TPSALD"

   		While &(cCond)		
			If mv_par05 == 2					// Considera moeda especifica
				If cAlias != "CTF"
					If cAlias =="CT2"
						If CT2_MOEDLC != mv_par06
							dbSkip()
							Loop
						EndIf
					ElseIf cAlias == "CTZ"
						If CTZ_MOEDLC != mv_par06
							dbSkip()
							Loop
						EndIf					
					ElseIf &(cCampoMoeda) != mv_par06
						dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf	
		
			If mv_par07 != "*"					// mv_par07 == 1 -> Todos os saldos
				If cAlias != "CTF"
					If	&(cCampoTpSald) != mv_par07
						dbSkip()
						Loop
					EndIf	
				EndIf	
			EndIf				
			
			If lCt220Skip
				lRet := ExecBlock("CT220SKIP",.F.,.F.,{cAlias})
				If !lRet
					dbSkip()
					Loop
				EndIf
			Endif

			dbSelectArea(cAlias)
			dbSetOrder(nOrder)
		     
			// O arquivo de lancamento contabil sempre devera ter os lancamentos contabeis
			// separados (por causa do razao)!!		
			If !(cAlias $ "CT2/CTZ")
				If !dbSeek(xFilial(cAlias)+&(cChave))
					RecLock(cAlias,.T.)
				Else
					RecLock(cAlias)
				EndIf		
			Else
				RecLock(cAlias,.T.)				
			EndIf	
		
			For nCont := 1 to Fcount()     
				If Trim(FieldName(nCont)) == cCampoFilial
					&(cCampoFilial) := xFilial(cAlias)
				Else	                                          
					dbSelectArea("Aglutina")
					cCampo := FieldName(nCont)
					
					If Alltrim(cCampo) == cCampoFilial
						Loop
					EndIf
				
					dbSelectArea(cAlias)
			   	   nPos 	:= FieldPos(cCampo)
			   	   If nPos != 0
     					If ValType(&(cCampo)) == "N"					// Campo Numerico
						      nValor := FieldGet(nPos)
					         FieldPut(nPos,;
				    	     nValor + Aglutina->(FieldGet(Aglutina->(FieldPos(cCampo)))))
						Else	      
							If cCampo == "CT2_ROTINA"
							    &(cCampo)	:= 'CTBA220'
							Else
					    	    FieldPut(nPos,Aglutina->(FieldGet(Aglutina->(FieldPos(cCampo)))))
					  		EndIf
				      	EndIf
					EndIf	  
				EndIf
			Next nCont	
			If lCt220Doc
				lRet := ExecBlock("CT220DOC",.F.,.F.,{cAlias})
			Endif
			MsUnlock()
			dbSelectArea("Aglutina")
			If lCt220Flag .And. ( Upper(cAlias) == "CT2" )
				lRet := ExecBlock("CT220FLAG",.F.,.F.,{"Aglutina"})
			EndIf
			dbSkip()
		EndDo
		dbSelectArea("Aglutina")
		dbCloseArea ()
    Endif
    
EndIf	

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Ok   ³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                    
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Confirma processamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Ok(aQuais,aEmp)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = Array   contendo as empresas                       ³±±
±±³           ³ ExpA2 = Array contendo as empresas a serem consolidadas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ct220OK(aQuais,aEmp,aSM0,nEmpAtu)

Local cMensagem 
Local lQuais	:= .F.
Local lEmpresa	:= .F.
Local nCont

If mv_par01 == 1
	cMensagem := STR0012+chr(13)		// Os dados da empresa abaixo serao apagados
	cMensagem += STR0041 +aSM0[nEmpAtu][SM0_GRPEMP]+"-"+aSM0[nEmpAtu][SM0_NOME]+chr(13)//"Empresa : "
	cMensagem += STR0042 +aSM0[nEmpAtu][SM0_CODFIL]+"-"+aSM0[nEmpAtu][SM0_NOMRED]+chr(13)//"Filial  : "
	cMensagem += STR0013				//"Confirma Consolidacao nesta empresa?"
Else
	cMensagem := STR0013+chr(13)  //"Confirma Consolidacao nesta empresa?"
	cMensagem += STR0041 +aSM0[nEmpAtu][SM0_GRPEMP]+"-"+aSM0[nEmpAtu][SM0_NOME]+chr(13)//"Empresa : "
	cMensagem += STR0042 +aSM0[nEmpAtu][SM0_CODFIL]+"-"+aSM0[nEmpAtu][SM0_NOMRED]+chr(13)//"Filial  : "
EndIf
	
For nCont := 1 to Len(aQuais)
	IF aQuais[nCont][1]
		lQuais := .t.
		Exit
	Endif
Next
For nCont := 1 to Len(aEmp)
	IF aEmp[nCont][1]
		lEmpresa := .t.
		Exit
	Endif
Next
If !lQuais
	If !__lBlind
		HELP (" ",1,"C210S/ARQ")				// Nao selecionou nenhum arquivo
	EndIf
	Return .F.
Endif
If !lEmpresa									// Nao selecionou nenhuma empresa
	If !__lBlind
		HELP (" ",1,"C210S/EMP")
	EndIf
	Return .F.
Endif

Return MsgYesNo(cMensagem,STR0009)  //"Aten‡„o"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220troca³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Troca(nIt,aArray)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ aArray                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpN1 = Numero da posicao                                  ³±±
±±³           ³ ExpA1 = Array contendo as empresas a serem consolidadas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct220Troca(nIt,aArray,lEmp,lShowMsg)

Local nCont	:= 1
Local cEmpAtu	:= ""
Local cFilAtu	:= ""
Local cModo		:= ""   
Local cMensagem	:= ""

Default lShowMsg := .T.

If lEmp
	cEmpAtu	:= aArray[nIt][2]
	cFilAtu	:= Subs(aArray[nIt][3],1, IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) )
	cModo	:= aArray[nIt][4]
	If len(cFilAtu )<>IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
		If !__lBlind .And. lShowMsg
			MsgAlert(STR0031) //"Nao e permitido selecionar uma filial com tamanho da filial diferente do tamanho da filial da consolidadora"
		EndIf
		aArray[nIt,1] := .F.
		Return(aArray)
	EndIf

	If cModo == "C"	//Se o CT2 for compartilhado, verificar se esta marcando mais de uma filial 
		cMensagem	:= STR0027 + chr(10) //"Nao é permitido marcar duas filiais da mesma empresa com lançamentos "
		cMensagem	+= STR0028			 //"contábeis compartilhados."
		For nCont	:= 1 to Len(aArray)
			If nCont <> nIt //Nao verificar o que esta sendo marcado/desmarcado
				If aArray[nCont][1] .And. cEmpAtu == aArray[nCont][2] .And. cFilAtu <> Subs(aArray[nCont][3],1, IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) )
			
					If !__lBlind .And. lShowMsg
						MsgAlert(cMensagem)
					EndIf
					
					Return(aArray)
				EndIf
			EndIf
		Next	
	EndIf
EndIf
aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Ajust³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Ajusta Descricao das Empresas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Ajust(aEmp)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ aNovoEmp                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = Array contendo as empresas a serem consolidadas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Ajust(aEmp)

Local aNovoEmp := {}     
Local nTam
Local nCont
Local nMaior := 0

For nCont := 1 to Len(aEmp)
	aEmp[nCont,3] := Alltrim(aEmp[nCont,3])+"  "
	nTam := GetTextWidth(0,aEmp[nCont,3])
	If nTam > nMaior
		nMaior := nTam
	Endif
Next
For nCont := 1 to Len(aEmp)
	If Len( aEmp[nCont] ) > 4
		AADD( aNovoEmp,{aEmp[nCont,1],aEmp[nCont,2]," ",aEmp[nCont,5]} )
	Else
		AADD( aNovoEmp,{aEmp[nCont,1],aEmp[nCont,2]," "} )
	EndIf
	While .t.
		nTam := GetTExtWidth(0,aEmp[nCont,3])
		IF nTam < nMaior
			aEmp[nCont,3]+=" "
		Else
			exit
		Endif
	End
	aNovoEmp[nCont,3] := aEmp[nCont,3]+aEmp[nCont,4]
Next
Return aNovoEmp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Open ³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Abre arquivo do SX2                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220pen(cEmpresa)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = Codigo da Empresa                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Open(cEmpresa)

Local cArquivo
Local cIndice
Local lInDB := FindFunction("MPDicInDB") .And. MPDicInDB() //Verifica se o dicionário esta no banco

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Seleciona o arquivo SX2 da empresa ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArquivo := "SX2" + cEmpresa + "0"
cIndice  := "SX2" + cEmpresa + "01"

If ! lInDB
	If(! File(Trim(cArquivo)+ GetDBExtension()))
		Final(cArquivo + STR0014)  //" n†o encontrado"
	EndIf	
EndIf

If Select("SX2TMP") <> 0
	dbSelectArea("SX2TMP")
	dbCloseArea()
EndIf	

cArqIx2 := cIndice

OpenSxs(,,,,cEmpresa,"SX2TMP","SX2",,.F.)

If Select("SX2TMP") <= 0
	Final(cArquivo + STR0014)  //" n†o encontrado"
EndIf

dbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Alias³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Abre arquivo origem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Alias(cAlias,cModoSX2,cArquivo)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = Alias                                              ³±±
±±³           ³ ExpC2 = Modo do SX2                                        ³±±
±±³           ³ ExpC3 = Nome do arquivo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Alias(cAlias,cModoSX2,cArquivo,cEmpAlias)

Local lRet := .T.      
Local cCompEmp	:= ''
Local cCompUni	:= ''
Local cCompFil	:= ''

//Verificar através das funções de Frame o compartilhamento das tabelas
cCompEmp := FWModeAccess(cAlias,1,cEmpAlias)//X2_MODOEMP
cCompUni := FWModeAccess(cAlias,2,cEmpAlias)//X2_MODOUN
cCompFil := FWModeAccess(cAlias,3,cEmpAlias)//X2_MOD

If Alltrim(cCompFil) == "C" .And. Alltrim(cCompUni) == "C" .And. Alltrim(cCompEmp) == "C"
	cModoSX2 := "C"         
Else
	cModoSX2 := "E"
EndIf

//--------------------------------------
// Seleciona o arquivo a ser processado
//--------------------------------------
dbSelectArea("SX2")

	cArquivo := RetFullName(cAlias, cEmpAlias)

	If !TCCanOpen(cArquivo)
		lRet := .F.
		Help(" ",1,"CT220ERR")					// Erro na abertura do arquivo
	EndIf
	
	Ct220Open(cEmpAlias)


Return lRet	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Apaga³ Autor  ³ Pilar S. Albaladejo     ³ Data 09.04.01³±±                                   
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Apaga periodo desejado                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Apaga()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ct220Apaga()

Local dDataIni	:= mv_par02
Local dDataFim	:= mv_par03
Local lCtb220Cdx:= Iif(ExistBlock("CTB220CDX"),.T.,.F.)
Local aAlias	:= {}  
Local cChave	:= ""		
Local cQuery	:= "" 	
Local Ct220Del	:= ""	
Local nCountReg	:= 0	
Local nMax		:= 0	
Local i
Local lCtb220Top:= IIf(ExistBlock("CTB220TOP"),.T.,.F.)	
                                         		
aAlias := {"CT2","CQ0", "CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CTC","CTF","CTZ"}

For i := 1 to Len(aAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual eh o maior e o menor Recno que satisfaca a selecao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ct220Del	:= "Ct220Del"
			
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName(aAlias[i])
	cQuery += " WHERE " +aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
	cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
	cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
	cQuery += " D_E_L_E_T_<>'*'"
	CQuery += " ORDER BY RECNO"
			
	cQuery := ChangeQuery(cQuery)
			
	If ( Select ( "Ct220Del" ) <> 0 )
		dbSelectArea ( "Ct220Del" )
		dbCloseArea ()
	Endif
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),Ct220Del)

	dbSelectArea(aAlias[i])
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a string de execucao no banco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
	cQuery += " WHERE " + aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
	cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
	cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
			
	While Ct220Del->(!Eof())
		
		nMin := (Ct220Del)->RECNO
			
		nCountReg := 0
					
		While Ct220Del->(!Eof()) .and. nCountReg <= 4096
				
			nMax := (CT220DEL)->RECNO
			nCountReg++
			Ct220Del->(DbSkip())

		End
				
		cChave := "R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
				
		If lCtb220Top
			cCondEsp	:= ExecBlock("CTB220TOP",.f.,.f.,{aAlias[i]})
					
			TcSqlExec(cQuery+cChave+cCondEsp)
		Else
			TcSqlExec(cQuery+cChave)
		EndIf
			
	End
			
	If ( Select ( "Ct220Del" ) <> 0 )
		dbSelectArea ( "Ct220Del" )
		dbCloseArea ()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A tabela eh fechada para restaurar o buffer da aplicacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(aAlias[i])
	dbCloseArea()
	ChkFile(aAlias[i],.F.)
	Next

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Conso³ Autor  ³ Alice Y. Yamamoto       ³ Data 14.10.03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Copia as tabelas para empresa destino                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Conso(cEmpAtu,aEmpresas,aQuais)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmpAtu                                            ³±±
±±³           ³ ExpC2 = aEmpresas                                          ³±±
±±³           ³ ExpC3 = aQuais                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Conso(cEmpAtu,aEmpresas,aQuais, aSM0)
Local lRet   	:= .F.
Local lClVl  	:= CtbMovSaldo("CTH")
Local lItem  	:= CtbMovSaldo("CTD")
Local lCusto 	:= CtbMovSaldo("CTT")
Local cLote  	:= Trim(mv_par09)
Local cDoc   	:= Trim(mv_par11)
Local cOldAlias := Alias()
Local cQuery   	:= ""
Local nFKinUse	:= 0
Local lDelFisico:= GetNewPar('MV_CTB220D',.T.) 
Local cCTB020   := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local aTpSaldo  := {}
Local iX        := 0
ProcLogAtu("INICIO",STR0060)//"COPIA DAS TABELAS PARA A EMPRESA DESTINO"
If TcGetDb() != "DB2/400" .and. TcGetDb() != "INFORMIX" .and. ExistProc( cCTB020, VerIDProc() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a integridade referencial está ativa                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT count(*) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" + SM0->M0_CODIGO + "'"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'INTEGR', .F., .T.)
	nFKInUse := INTEGR->TOTAL
	INTEGR->( dbCloseArea() )
	dbSelectArea(cOldAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerar cTpSldAux - usado no Reprocessamento                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 = "*"  // tipo de saldo
		aTpSaldo := ct220TpSaldo()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CT1 - Plano de Contas                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aQuais[1][1]
		lRet := ct220ExecP(cEmpAtu,aEmpresas,aQuais,"CT1", aSM0)
		If !lRet
			Return(.f.)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CTT - Centro de Custo                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aQuais[3][1]
		lRet := ct220ExecP(cEmpAtu,aEmpresas,aQuais,"CTT", aSM0)
		If !lRet
			Return(.f.)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CTD - Item Contabil                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aQuais[4][1]
		lRet := ct220ExecP(cEmpAtu,aEmpresas,aQuais,"CTD", aSM0)
		If !lRet
			Return(.f.)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CTH - Classe de Valor                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aQuais[5][1]
		lRet := ct220ExecP(cEmpAtu,aEmpresas,aQuais,"CTH", aSM0)
		If !lRet
			Return(.f.)
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CT2 - Lanctos Contabeis                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aQuais[2][1]
		lRet := ct220ExecP(cEmpAtu,aEmpresas,aQuais,"CT2", aSM0)
		If !lRet
			Return(.f.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CTZ - Tabela de Apuracao de Resultados com conta Ponte       ³
		//³ Qdo solicitado a consolidacao do CT2 consolidar tambem a ta- ³
		//³     bela CTZ ( tabela com os valores das apuracoes de L e P  ³
		//³     com com Ponte)                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		lRet := ct220ExecP(cEmpAtu,aEmpresas,aQuais,"CTZ", aSM0)
		If !lRet
			Return(.f.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ mv_par08 = '1' -> Gera Saldos iniciais                       ³
		//³ Gera os saldos iniciais para todas a entidades que estiverem ³
		//³ em uso .                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 1
			If lClvl
				lRet := Ctb220SalIni(aEmpresas, "CQ7", @cLote, @cDoc)  //CQ7
			Endif
			If lItem
				lRet := Ctb220SalIni(aEmpresas, "CQ5", @cLote, @cDoc) //CQ5
			Endif
			If lCusto
				lRet := Ctb220SalIni(aEmpresas, "CQ3", @cLote, @cDoc) //CQ3
			Endif
			lRet := Ctb220SalIni(aEmpresas , "CQ1", @cLote, @cDoc) //CQ1
			dbSelectArea("CT2")
		    TCRefresh(RetFullName("CT2"))		
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reprocessameto contabil Tipo de Saldo diferente de '0'/'9' e ³
	//³ somente se os lanctos forem importados                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aQuais[2][1] .and. lRet
		cTpSald := Trim(mv_par07)		
		lRet := .T.
		lCusto  := aQuais[3][1]
		lItem   := aQuais[4][1]
		lCLVL   := aQuais[5][1]
		lReproc := '1'
		If mv_par05 = 2    //moeda especifica
			lMoedaEsp := '1'
			cMoeda := Trim(mv_par06)
		Else
			lMoedaEsp := '0'
			cMoeda := '00'
		EndIf
		If mv_par07 = '*' .and. Len(aTpSaldo) > 0
			For ix := 1 to Len(aTpSaldo)
				cTpSald := aTpSaldo[iX]
				aResult := TCSPEXEC( xProcedures(cCTB020),;
							Iif(lCusto,'1','0'),;
							Iif(lItem,'1','0'), Iif(lClVl,'1','0'),;
							cFilAnt,              cFilAnt,;
							If(mv_par08==1,Dtos(mv_par02-1),Dtos(mv_par02)),Dtos(mv_par03),;
							lMoedaEsp,           cMoeda,;
							cTpSald,             StrZero(Getmv("MV_SOMA"),1),;
							lReproc,             If(nFKInUse > 0, '1' , '0' ),;
							If(lDelFisico, '1', '0' ),;
							cEmpAnt,;
							cFilAnt)
				if Empty(aResult)
		      		If !__lBlind
		      			MsgAlert(STR0017)  //'Erro na chamada do processo'
		      		EndIf
			      	lRet := .F.
			  	endif
			 Next
		Else
			aResult := TCSPEXEC( xProcedures(cCTB020),;
						Iif(lCusto,'1','0'),;
						Iif(lItem,'1','0'), Iif(lClVl,'1','0'),;
						cFilAnt,              cFilAnt,;
						If(mv_par08==1,Dtos(mv_par02-1),Dtos(mv_par02)),Dtos(mv_par03),;
						lMoedaEsp,           cMoeda,;
						cTpSald,             StrZero(Getmv("MV_SOMA"),1),;
						lReproc,             If(nFKInUse > 0, '1' , '0' ),;
						If(lDelFisico, '1', '0' ),;
						cEmpAnt,;
						cFilAnt)
			if Empty(aResult)
	      		If !__lBlind
	      			MsgAlert(STR0017)  //'Erro na chamada do processo'
	      		EndIf
		      	lRet := .F.
		  	endif		
	  	EndIf
	EndIf
	DbSelectArea("CT1")
	
EndIf
ProcLogAtu("FIM",STR0060)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220ExecP³ Autor  ³ Alice Y. Yamamoto       ³ Data 14.10.03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Copia as tabelas para empresa destino                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220ExecP(cEmpAtu,aEmpresas,aQuais,cTabela)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmpAtu                                            ³±±
±±³           ³ ExpC2 = aEmpresas                                          ³±±
±±³           ³ ExpC3 = aQuais                                             ³±±
±±³           ³ ExpC4 = cTabela                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220ExecP(cEmpAtu,aEmpresas,aQuais, cTabela, aSM0)
Local cQuery     :=""
Local cQueryExec :=""
Local cSelect    :=""
Local cWhere     :=""
Local cArray     :=""
Local aCampos    := {}
Local aResult    := {}
Local cDeclare   :=""
Local cFetch     :=""
Local cCorpo     :=""
Local cProc      := ""
Local cCamposVar := ""
Local ix, ixx, nCont, nCont1, iNum
Local cTipo, cCampos := ""
Local lRet := .T.
Local cEmp  := "  "
Local aEmpAux := {}
Local cRet := 1
Local aArq := {}
Local nPos, nPos1
Local aEmpFilAux := {}
Local cTabDest, cCTFDest    // tabela consolidante
Local cCt220Skip := ""
Local lCt220Skip := IIf(ExistBlock("CT220SKIP"),.T.,.F.)
Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local cCT220DOC :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "CT220DOC_03", "CT220DOC"))
Local cXFILIAL  :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "XFILIAL_03", "XFILIAL" ))
Local cCT220ALT := ""
Local lRetPE    := .T.
Local lFirst	:= .T.
Local cTipoMemo := ""
Local lSkipCpo  := Iif(Alltrim(Upper(TCGetDB())) $ "DB2/INFORMIX", .T., .F.)   // Se for DB2 ou Informix não copia campos Memo
local iAuxMemo  := 0

If "MSSQL" $ Alltrim(Upper(TCGetDB()))
	cTipoMemo := " VarBinary(max)"
ElseIf "ORACLE" $ Alltrim(Upper(TCGetDB()))
	cTipoMemo := " Blob"
ElseIf "POSTGRES" $ Alltrim(Upper(TCGetDB()))
	cTipoMemo := " ByteA"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CT220SKIP - Permite filtrar entidades a consolidar.          ³
//³ Qdo executa via procedure o usuario pode filtrar as Contas,  ³
//³ os CCustos, os Itens e/ou Clvls no momento da leitura do CT2 ³
//³ via pto de entrada.                                          ³
//³ O pto de entrada deve retornar uma expressao do tipo:        ³
//³ 'AND CT2_DEBITO != 'CCCC' AND CT2_CREDIT !=  'CCCCC'         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Buscar a Tabela da empresa consolidante                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")
DbSetOrder(1)
If DbSeek(cTabela)
	cTabDest := RetFullName(cTabela, cEmpAtu)
EndIf
If cTabela = "CT2"
	If DbSeek("CTF")
		cCTFDest := RetFullName("CTF", cEmpAtu)
	EndIf
	/* -----------------------------------------------------------------------------------------
		Criar PE, CTB220ALT_## para alteração de valor e histórico na gravação do CT2 ,
		se não existir no banco
	   ----------------------------------------------------------------------------------------- */
	cCT220ALT := "CTB220ALT_"+cEmpAnt
	If !TCSPExist( cCT220ALT )
		lRetPE := CTB220Alt()
	    If !lRetPE
    		IF !MsgYesNo(STR0068,STR0069)//"Erro na criação do ponto de entrada CTB220ALT, Continua o processo mesmo assim?"#"Atenção!!"
				Return(.F.)
			Endif
		Endif
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ cArray ->#E1F1F2F3Fn#E2F1F2F3Fn#EnF1Fn, onde E - Empresas, F - Filiais  ³
//³          Ex: #0101020304#02  #03010204                                  ³
//³                                                                         ³
//³ aEmpAux->Todas as empresas e a tabela a ser consolidada                 ³
//³ aEmpAux-> [n][1]-Empresa a ser consolidada                              ³
//³           [n][2]-tabela da empresa a ser consolidada                    ³
//³          Ex: aEmpAux[1][1]- '01'                                        ³
//³          Ex: aEmpAux[1][2]- CT1010                                      ³
//³          Ex: aEmpAux[2][1]- '02'                                        ³
//³          Ex: aEmpAux[2][2]- CT1020                                      ³
//³                                                                         ³
//³ cIN    ->Filiais da Empresa a cosolidar                                 ³
//³          Exs: ( '01','02',05'); ('  ')                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cSelect:= ""
cWhere := "" 
cQueryExec := ""
cEmp  := "  "
aEmpAux := {}	
cArray:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerar aEmpAux                                                ³
//³ Gerar cArray                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEmpAux   := Ctb220aEmp(aEmpresas, cTabela)
cArray    := Ctb220Array(aEmpresas, cTabela)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CT1/CTT/CTD/CTH - Contas, CCustos, Item, ClVl                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If cTabela != "CT2"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Select do Cursor                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cSelect := Ct220Select(cEmpAtu,cTabela,aEmpAux,cArray)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ cSelect e cWhere                                             ³
	//³ cCampos - campos do select sem o min                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	aCampos := (cTabela)->(DbStruct())
   	cCampos := ""   
	lFirst := .T.
	For ix := 1 to Len(aCampos)		
		if Mod(ix,5) = 0
			cCampos+=  CRLF+"                  "
		EndIf
		
		If Trim(aCampos[ix][1]) == cTabela+"_FILIAL" .Or. (aCampos[ix][2] == "M"  .and. lSkipCpo )  // Se for DB2 ou Informix não copia campos Memo
			loop
		EndIf
		
		If !lFirst
			cCampos +=", "	
		EndIf
		lFirst := .F.

		cCampos += Trim(aCampos[ix][1])
		
	Next ix
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta declaracao de variaveis                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	cDeclare := ""
   	cDeclare += "Declare @iRecno     Integer "+CRLF
   	cDeclare += "Declare @cFilial    Char(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + ") "+CRLF
   	cDeclare += "Declare @cAux       Char(03) "+CRLF
	
	For ix := 1 to Len(aCampos)
		//                      variavel               
		If Trim(aCampos[ix][1]) == cTabela+"_FILIAL" .or. (aCampos[ix][2] == "M" .and. lSkipCpo ) 
			loop
		EndIf
		If aCampos[ix][2] = "C"
			cTipo := " Char("+StrZero(aCampos[ix][3],3)+")"
			cDeclare += "Declare  @c"
		ElseIf aCampos[ix][2] = "N"
			If aCampos[ix][4] = 0
				cTipo := " Integer"
				cDeclare += "Declare  @i"
			Else
				cTipo := " Float "
				cDeclare += "Declare  @n"
			EndIf
		ElseIf aCampos[ix][2] = "D"
			cTipo := " Char(08)"
			cDeclare += "Declare  @c"
		ElseIf aCampos[ix][2] = "M"  
			cTipo := cTipoMemo          //somente Oracle/Sqlserver/ Postgres
			cDeclare += "Declare  @c"
		EndIf
		cDeclare += Trim(aCampos[ix][1])+cTipo+ CRLF
	Next ix
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as vars do fetch                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cFetch := "   Fetch CUR_CTB220A into "
	
	lFirst := .T.
	For ix := 1 to len(aCampos)
		If Trim(aCampos[ix][1]) == cTabela+"_FILIAL" .or. (aCampos[ix][2] == "M"  .and. lSkipCpo ) 
			loop
		EndIf
		
		If !lFirst
			cCamposVar+= ", "
		EndIf
		lFirst := .F.

		If aCampos[ix][2] = "C" .or. aCampos[ix][2] = "D"
				cCamposVar += " @c"+Trim(aCampos[ix][1])
		ElseIf aCampos[ix][2] = "N"
			If aCampos[ix][4] = 0
				cCamposVar += " @i"+Trim(aCampos[ix][1])
			Else
				cCamposVar += " @n"+Trim(aCampos[ix][1])
			EndIf
		ElseIf aCampos[ix][2] = "M"  
			cCamposVar += " @c"+Trim(aCampos[ix][1])
		EndIf

	Next ix
	cFetch += cCamposVar+CRLF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ cWhere                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
   If cTabela = "CTZ"
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ cWhere                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		cWhere += " "+cTabela+"_FILIAL = @cFilial"+CRLF
		cWhere += "         And D_E_L_E_T_ = ' '"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta corpo da procedure                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		cCorpo := ""
		cCorpo+="begin"+CRLF
		cCorpo+="   Select @OUT_RESULTADO = '0'" +CRLF  
		cCorpo+="   Select @cAux     = '"+cTabela+"'"+CRLF
		cCorpo+="   exec "+cXFILIAL+" @cAux, @IN_FILIALCOR, @cFilial OutPut" +CRLF
		cCorpo+= CRLF
		cCorpo+="   declare CUR_CTB220A insensitive cursor for"+CRLF
		cCorpo+= cSelect    //cursor
		cCorpo+="   for read only "+CRLF
		cCorpo+="   open CUR_CTB220A "+CRLF
		cCorpo+= cFetch     // Fetch
		cCorpo+= CRLF
		cCorpo+="   While (@@fetch_status = 0) begin"+CRLF
		cCorpo+="      select @nCTZ_VLRDEB = Round(@nCTZ_VLRDEB, 2)"+CRLF
		cCorpo+="      select @nCTZ_VLRCRD = Round(@nCTZ_VLRCRD, 2)"+CRLF
		cCorpo+=CRLF
	 	cCorpo+="		select @iRecno = IsNull(max(R_E_C_N_O_), 0) from " + cTabDest+CRLF
	   	cCorpo+="      select @iRecno = @iRecno + 1"+CRLF
		cCorpo+= CRLF
		cCorpo+="      insert into "+cTabDest+ "( "
		cCorpo+= cCampos+","+cTabela+"_FILIAL, R_E_C_N_O_ )"+CRLF
		cCorpo+="            values ( "
		cCorpo+=cCamposVar+", @cFilial, @iRecno)"+CRLF
		cCorpo+="   "+cFetch
		cCorpo+="   End"+CRLF
		cCorpo+="   close CUR_CTB220A"+CRLF
		cCorpo+="   deallocate CUR_CTB220A"+CRLF
		cCorpo+=CRLF
		cCorpo+="   select @OUT_RESULTADO = '1'"+CRLF
		cCorpo+="end"+CRLF
	Else
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ cWhere                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If cTabela == "CT1"
			cWhere += "CT1_CONTA = @cCT1_CONTA" +CRLF
		ElseIf cTabela == "CTD"
			cWhere += "CTD_ITEM = @cCTD_ITEM" 	+CRLF
		ElseIf cTabela == "CTH"
			cWhere += "CTH_CLVL = @cCTH_CLVL" 	+CRLF 
		ElseIf cTabela == "CTT"
			cWhere += "CTT_CUSTO = @cCTT_CUSTO" + CRLF
		EndIf	
		cWhere += "         And "+cTabela+"_FILIAL = @cFilial"+CRLF
		cWhere += "         And D_E_L_E_T_ = ' '"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta corpo da procedure                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		cCorpo := ""
		cCorpo+="begin"+CRLF
		cCorpo+="   Select @OUT_RESULTADO = '0'" +CRLF  
		cCorpo+="   Select @cAux     = '"+cTabela+"'"+CRLF
		cCorpo+="   exec "+cXFILIAL+" @cAux, @IN_FILIALCOR, @cFilial OutPut" +CRLF
		cCorpo+= CRLF
		cCorpo+="   declare CUR_CTB220A insensitive cursor for"+CRLF
		cCorpo+= cSelect    //cursor
		cCorpo+="   for read only "+CRLF
		cCorpo+="   open CUR_CTB220A "+CRLF
		cCorpo+= cFetch     // Fetch
		cCorpo+= CRLF
		cCorpo+="   While (@@fetch_status = 0) begin"+CRLF
		cCorpo+="      Select @iRecno = Min(R_E_C_N_O_)"+CRLF
		cCorpo+="        From "+cTabDest+CRLF
		cCorpo+="       Where "+cWhere+CRLF
		cCorpo+=CRLF
		cCorpo+= CRLF
		cCorpo+="      If @iRecno is null begin "+CRLF
	 	cCorpo+="         select @iRecno = Isnull(max(R_E_C_N_O_), 0)  from " + cTabDest+CRLF
	   	cCorpo+="         select @iRecno = @iRecno + 1"+CRLF
		cCorpo+="         If ( @iRecno = 0 or @iRecno is null ) select @iRecno = 1"+CRLF  
		cCorpo+= CRLF
		cCorpo+="            insert into "+cTabDest+ "( "
		cCorpo+= cCampos+","+cTabela+"_FILIAL, R_E_C_N_O_ )"+CRLF
		cCorpo+="            values ( "
		cCorpo+=cCamposVar+", @cFilial, @iRecno)"+CRLF
		cCorpo+="      end"+CRLF
		cCorpo+="      "+cFetch
		cCorpo+="   End"+CRLF
		cCorpo+="   close CUR_CTB220A"+CRLF
		cCorpo+="   deallocate CUR_CTB220A"+CRLF
		cCorpo+=CRLF
		cCorpo+="   select @OUT_RESULTADO = '1'"+CRLF
		cCorpo+="end"+CRLF
	End		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Create Procedure(@IN_FILIALCOR char(02),                                ³
	//³                  @OUT_RESULTADO char(01) OutPut )                       ³
	//³                                                                         ³
	//³ as                                                                      ³
	//³                                                                         ³
	//³DeclEaracao de Variaveis ->cDeclare                                       ³
	//³                                                                         ³
	//³begin            ¿                                                       ³
	//³   instrucoes    |->cCorpo                                               ³	
	//³end              Ù                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cQueryExec += "CREATE PROCEDURE CTB220C_"+cEmpAtu+" (" +CRLF
	cQueryExec += " @IN_FILIALCOR  CHAR(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + "), "+CRLF
	cQueryExec += " @OUT_RESULTADO CHAR(01) OutPut " +CRLF
	cQueryExec += " )"+CRLF
	cQueryExec += "AS "+CRLF
	cQueryExec += CRLF+cDeclare +CRLF
	cQueryExec += cCorpo
    cQueryExec := MsParse(cQueryExec,Alltrim(TcGetDB()))
	
	/* MsParse alterou a instrução VarBinary(max) para Varbinary, então RECOLOCO
	   no script após passar pelo MsParse */
	If "MSSQL" $ AllTrim(Upper(TCGetDb()))
		iAuxMemo := At("VARBINARY(", Upper(cQueryExec))
		If iAuxMemo == 0
		   cQueryExec := Strtran(Upper(cQueryExec),"VARBINARY" ,"VarBinary(max)" )
		EndIf		
	Endif

	cProc := 'CTB220C_'+cEmpAtu
	If TCSPExist( cProc )
		cRet := TcSqlExec('DROP PROCEDURE '+cProc)
		If cRet <> 0 
			If !__lBlind
				MsgAlert(STR0019+" "+cProc+": "+cTabela)  //'Erro na exclusao da procedure'
			EndIf
			Return .f.
		EndIf
	EndIf
    cRet := TcSqlExec(cQueryExec)
    If cRet = 0 
	   aResult := TCSPExec( xProcedures('CTB220C'), cFilAnt )
	   DbSelectArea(cTabela)
	   TCRefresh(RetFullName(cTabela))
		If Empty(aResult)
			If !__lBlind
				MsgAlert(STR0017+" "+cProc+": "+cTabela )  //'Erro na chamada do processo'
			EndIf
			lRet := .f.
		Elseif aResult[1] != "1"
			If !__lBlind
				MsgAlert(STR0020+" "+cProc+": "+cTabela)  //'Atualizacao com Erro'
			EndIf
			lRet := .f.
		EndIf
	   cRet := TcSqlExec('DROP PROCEDURE '+cProc)
	   If cRet <> 0
	   	If !__lBlind
		  		MsgAlert(STR0019+" "+cProc+": "+cTabela)  //'Erro na exclusao da procedure'
	  		EndIf
			lRet := .f.
	   EndIf
	Else       
		If !__lBlind
			MsgAlert(STR0021+" "+cProc+": "+cTabela)  //'Erro na criacao da procedure'
		EndIf
		lRet := .f.	
    EndIf
Else
	If lCt220Skip
		cCt220Skip := ExecBlock("CT220SKIP", .f.,.f.)
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CT2 - Lanctos Contabeis                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmp := "  "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aCampos - Campos do SX# padrao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	aCampos := CT2->(DbStruct())
	   
	For nCont := 1 to Len(aEmpAux)
		lFirst := .T.		
		cSelect := "   SELECT "
		For ix := 1 to Len(aCampos)
			If Trim(aCampos[ix][1]) == "CT2_FILIAL" .or. aCampos[ix][2] == "M" 
				loop
			EndIf
			If !lFirst
				cSelect +=","	
			EndIf
			lFirst := .F.
 			cSelect += Trim(aCampos[ix][1])	 		
		Next ix	
		cEmp := aEmpAux[nCont][1]
		cSelect += CRLF
		cSelect+= "     FROM "+aEmpAux[nCont][2]+CRLF
		cWhere += "    WHERE D_E_L_E_T_ = ' ' "+ CRLF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta as filiais do empresa - ( '01','02',..)                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cINAux := "#"+cEmp
		cIN    := CTB220FilIn(cInAux, cArray)
		cWhere += "      AND CT2_FILIAL IN "+ cIN+ CRLF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o periodo a consolidar                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere += "      AND CT2_DATA >= '"+Dtos(mv_par02)+"' AND CT2_DATA <= '"+Dtos(mv_par03)+"'"+ CRLF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona Moeda                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par05 = 2  // moeda especifica
			cWhere+= "      AND CT2_MOEDLC = '"+Trim(mv_par06)+"'"+ CRLF
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tipo de Saldo                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par07 !="*"  // tipo de saldo
			cWhere+= "      AND CT2_TPSALD = '"+Trim(mv_par07)+"'"+ CRLF
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada CT220SKIP                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCt220Skip  // filtrar as entidades.
			cWhere+= cCt220Skip
		EndIf 
		If nCont < Len(aEmpAux)
			cWhere += "   UNION"+CRLF
		EndIf
		cQuery += cSelect+cWhere
		cSelect:= ""
		cWhere := ""
	Next nCont
   cQuery += CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta declaracao de variaveis                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cDeclare := ""
   cDeclare += "Declare @iRecno      Integer "+CRLF
   cDeclare += "Declare @iRecnoCTF   Integer "+CRLF
   cDeclare += "Declare @cFilial_CT2 Char(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + ") "+CRLF
   cDeclare += "Declare @cFilial_CTF Char(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + ") "+CRLF
   cDeclare += "Declare @cAux        VarChar(05) "+CRLF
   cDeclare += "Declare @cCT2_FILIAL Char(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + ")"+CRLF
   cDeclare += "Declare @iAux        Integer"+CRLF
   cDeclare += "Declare @cDataAnt    Char( 08 )"+CRLF
	
   For ix := 1 to Len(aCampos)
      //                      variavel               
      If Trim(aCampos[ix][1]) == "CT2_FILIAL" .or. aCampos[ix][2] == "M" 
      	loop
      EndIf
      If aCampos[ix][2] = "C"
         cTipo := " Char("+StrZero(aCampos[ix][3],3)+")"
	 		cDeclare += "DECLARE  @c"
      ElseIf aCampos[ix][2] = "N"
         If aCampos[ix][4] = 0
	         cTipo := " Integer"
  		 		cDeclare += "DECLARE  @i"
         Else
	         cTipo := " Float "
  		 		cDeclare += "DECLARE  @n"
  	 		EndIf
      ElseIf aCampos[ix][2] = "D"
         cTipo := " Char(08)"
	 		cDeclare += "DECLARE  @c"
      EndIf
 	  cDeclare += Trim(aCampos[ix][1])+cTipo+ CRLF
   Next ix
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Crio com tamanho de CT2_LOTE, CT2_SBLOTE,CT2_DOC, respect.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos1 := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
   cTipo := " Char("+StrZero(aCampos[nPos1][3],3)+")"
   cDeclare += "Declare @cCT2_LOTES "+ cTipo+CRLF    
   cDeclare += "Declare @cLoteAnt "+ cTipo+CRLF
   
	nPos1 := Ascan(aCampos,{|x|Alltrim(x[1]) == "CT2_SBLOTE" })
   cTipo := " Char("+StrZero(aCampos[nPos1][3],3)+")" 
   cDeclare += "Declare @cCT2_SBLOTES "+cTipo+CRLF
   cDeclare += "Declare @cSbLoteAnt "+cTipo+CRLF
      
	nPos1 := Ascan(aCampos,{|x|Alltrim(x[1]) == "CT2_DOC" })
   cTipo := " Char("+StrZero(aCampos[nPos1][3],3)+")" 
   cDeclare += "Declare @cCT2_DOCS "+cTipo+CRLF
   cDeclare += "Declare @cDocAnt "+cTipo+CRLF

	nPos1 := Ascan(aCampos,{|x|Alltrim(x[1]) == "CT2_LINHA" })
   cTipo := " Char("+StrZero(aCampos[nPos1][3],3)+")" 
   cDeclare += "Declare @cLinhaAnt "+cTipo+CRLF
   
	nPos1 := Ascan(aCampos,{|x|Alltrim(x[1]) == "CT2_SEQIDX" })
   	cTipo := " Char("+StrZero(aCampos[nPos1][3],3)+")" 
   	cDeclare += "Declare @lPrim Char( 01 ) "+CRLF 
	cDeclare += "Declare @cCT2_HISTDEST Char( "+Str(TamSx3("CT2_HIST")[1])+" ) "+CRLF
	cDeclare += "Declare @nCT2_VALORDEST float "+CRLF

   cDeclare += CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta corpo da procedure                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	cCorpo := ""
   cCorpo+="begin"+CRLF
   cCorpo+="   Select @OUT_RESULTADO = '0'" +CRLF
   cCorpo+="   select @iRecnoCTF = 0" +CRLF
   cCorpo+="   select @iAux      = 5" +CRLF
   cCorpo+="   Select @cAux = 'CT2'"+CRLF
   cCorpo+="   exec "+cXFILIAL+" @cAux, @IN_FILIALCOR, @cFilial_CT2 OutPut" +CRLF
   cCorpo+="   Select @cAux = 'CTF'"+CRLF
   cCorpo+="   exec "+cXFILIAL+" @cAux, @IN_FILIALCOR, @cFilial_CTF OutPut" +CRLF

   cCorpo+= CRLF
   cCorpo+="   declare CUR_CTB220A insensitive cursor for" +CRLF
   cCorpo+= cQuery    //cSelect e cWhere
   cCorpo+="   for read only "+CRLF
   cCorpo+="   open CUR_CTB220A "+CRLF
   cCorpo+="   fetch CUR_CTB220A into "
   lFirst := .T.
   For ix := 1 to len(aCampos)
      If Trim(aCampos[ix][1]) == "CT2_FILIAL" .or. aCampos[ix][2] == "M" 
      	loop
      EndIf

	  If !lFirst
	  	cCorpo+= ", "
	  EndIf
	  lFirst := .F.

      If aCampos[ix][2] = "C" .or. aCampos[ix][2] = "D"
	 		cCorpo += " @c"+Trim(aCampos[ix][1])
      ElseIf aCampos[ix][2] = "N"
         If aCampos[ix][4] = 0  
	         cCorpo += " @i"+Trim(aCampos[ix][1])
         Else
	         cCorpo += " @n"+Trim(aCampos[ix][1])
  	 	 EndIf
      EndIf      
	Next ix
	cCorpo += CRLF
	cCorpo += CRLF
	cCorpo+= "   while (@@fetch_status = 0) begin "+CRLF
	cCorpo+= "      Select @cCT2_LOTES = ' ' "+CRLF
	cCorpo+= "      Select @cCT2_SBLOTES = ' ' "+CRLF
	cCorpo+= "      Select @cCT2_DOCS = ' ' "+CRLF
    cCorpo+= "	    Select @nCT2_VALOR = Round(@nCT2_VALOR, 2)"+CRLF
	cCorpo+= CRLF
    cCorpo+= "      EXEC "+cCT220DOC+"    @cFilial_CT2, @cCT2_DATA,   @cCT2_LINHA, @cCT2_TPSALD,"+CRLF
    cCorpo+= "                    @cCT2_EMPORI,  @cCT2_FILORI, @cCT2_MOEDLC, @cCT2_LOTE,  @cCT2_SBLOTE,"+CRLF
    cCorpo+= "                    @cCT2_DOC,     @cCT2_LOTES OutPut,  @cCT2_SBLOTES OutPut, @cCT2_DOCS OutPut"+CRLF
   cCorpo+= CRLF
	cCorpo+= "      Select @cCT2_LOTE   = @cCT2_LOTES "+CRLF
	cCorpo+= "      Select @cCT2_SBLOTE = @cCT2_SBLOTES "+CRLF
	cCorpo+= "      Select @cCT2_DOC    = @cCT2_DOCS " +CRLF
   cCorpo+= "       Select @iRecnoCTF = Min(R_E_C_N_O_)"+CRLF
   cCorpo+= "        From "+cCTFDest+CRLF
   cCorpo+= "       Where CTF_FILIAL = @cFilial_CTF"+CRLF
   cCorpo+= "         and CTF_DATA   = @cCT2_DATA"+CRLF
   cCorpo+= "         and CTF_LOTE   = @cCT2_LOTE"+CRLF
   cCorpo+= "         and CTF_SBLOTE = @cCT2_SBLOTE"+CRLF
   cCorpo+= "         and CTF_DOC    = @cCT2_DOC"+CRLF
   cCorpo+= "         and D_E_L_E_T_ = ' '"+CRLF 
   cCorpo+= "      If @iRecnoCTF is null begin "+CRLF
   cCorpo+= "         Select @iRecnoCTF = IsNull(Max( R_E_C_N_O_), 0) From "+cCTFDest+CRLF
   cCorpo+= "         Select @iRecnoCTF = @iRecnoCTF + 1"+CRLF
   cCorpo+= "         Insert into "+cCTFDest+" ( CTF_FILIAL,   CTF_DATA,   CTF_LOTE,   CTF_SBLOTE,   CTF_DOC,   CTF_LINHA,   R_E_C_N_O_ )"+CRLF
   cCorpo+= "                Values ( @cFilial_CTF, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_LINHA, @iRecnoCTF ) "+CRLF
   cCorpo+= "      "+CRLF
   cCorpo+= "      end else begin"+CRLF
   cCorpo+= "         Update "+cCTFDest+CRLF
   cCorpo+= "          Set CTF_LINHA = @cCT2_LINHA"+CRLF
   cCorpo+= "         Where R_E_C_N_O_ = @iRecnoCTF"+CRLF
   cCorpo+= "      End"+CRLF
	/* -----------------------------------------------------------------------------
	   Ponto de Entrada antes da gravação do CT2 para alteração de valor e histórico
	   Passar valor do lancto e histórico que poderão ser alterados                      
	   ----------------------------------------------------------------------------- */
	cCorpo+= CRLF
	If lRetPE   /* Se conseguiu criar pto de entrada, cria a chamada na procedure */
		cCorpo+= " 		select @cCT2_HISTDEST  = ' '"+CRLF
		cCorpo+= "     	select @nCT2_VALORDEST = 0 "+CRLF
	    cCorpo+= "      EXEC "+cCT220ALT+" @cFilial_CT2, @cCT2_DATA,   @cCT2_LINHA, @cCT2_TPSALD,"+CRLF
	    cCorpo+= "      @cCT2_EMPORI, @cCT2_FILORI, @cCT2_MOEDLC, @cCT2_LOTE, @cCT2_SBLOTE,@cCT2_DOC,"+CRLF
	    cCorpo+= "      @cCT2_HIST,   @nCT2_VALOR,  @cCT2_HISTDEST OutPut,  @nCT2_VALORDEST OutPut  " +CRLF
	    /* Recebe o valor alterado pelo Ponto de Entrada para gravação */
		cCorpo+= " 		select @cCT2_HIST = @cCT2_HISTDEST"+CRLF
		cCorpo+= "     	select @nCT2_VALOR = @nCT2_VALORDEST "+CRLF	    
	EndIf
    cCorpo+= CRLF      
	cCorpo+= "      select @iRecno = 0"+CRLF
	cCorpo+= "      select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM "+cTabDest+CRLF
	cCorpo+= "      select @iRecno = @iRecno + 1" +CRLF
	cCorpo+= "      If ( @iRecno = 0 or @iRecno is null ) select @iRecno = 1"+CRLF 
	cCorpo+= "         insert into "+cTabDest+ "("+CRLF+"          "
	iNum := 5
	
	For ix:= 1 to Len(aCampos)
		cCorpo+= Trim(aCampos[ix][1])+","
		if Mod(ix,5) = 0
			cCorpo+= CRLF+ "          "
		EndIf
	Next ix
	cCorpo+= " R_E_C_N_O_) "+CRLF
	cCorpo+="      values("+CRLF+"          "
	
	lFirst := .T.
	For ix:= 1 to Len(aCampos)		
		if Mod(ix,5) = 0
			cCorpo+= CRLF+ "          "
		EndIf

		If aCampos[ix][2] == "M" 
			Loop
		EndIf

		If !lFirst
			cCorpo+= ", "
		EndIf
		lFirst := .F.

		If aCampos[ix][2] = "C" .or. aCampos[ix][2] = "D"
			If Trim(aCampos[ix][1]) == "CT2_FILIAL"
				cCorpo+= " @cFilial_CT2"
			Else
				cCorpo += " @c"+Trim(aCampos[ix][1])
			EndIf
		ElseIf aCampos[ix][2] = "N"
			If aCampos[ix][4] = 0
				cCorpo += " @i"+Trim(aCampos[ix][1])
			Else
				cCorpo += " @n"+Trim(aCampos[ix][1])
			EndIf
		EndIf
     	
	Next ix	
    cCorpo+= ", @iRecno )"+CRLF     
    cCorpo+="      fetch CUR_CTB220A into "
	
	lFirst := .T.
    For ix := 1 to len(aCampos)
		If Trim(aCampos[ix][1]) == "CT2_FILIAL" .or. aCampos[ix][2] == "M" 
      		loop
      	EndIf

		If !lFirst
			cCorpo+= ", "
		EndIf
		lFirst := .F.
		
		If aCampos[ix][2] = "C" .or. aCampos[ix][2] = "D"
			cCorpo += " @c"+Trim(aCampos[ix][1])
		ElseIf aCampos[ix][2] = "N"
			If aCampos[ix][4] = 0
				cCorpo += " @i"+Trim(aCampos[ix][1])
			Else
				cCorpo += " @n"+Trim(aCampos[ix][1])
			EndIf
		EndIf      
	Next ix
	cCorpo += CRLF
	cCorpo+="   End"+CRLF
	cCorpo+="   close CUR_CTB220A"+CRLF
	cCorpo+="   deallocate CUR_CTB220A"+CRLF
	cCorpo+= CRLF
	cCorpo+= CRLF                  
	cCorpo+="   select @OUT_RESULTADO = '1'"+CRLF   
	cCorpo+="End"+CRLF
	cCorpo+=CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Create Procedure(@IN_FILIALCOR char(02),                                ³
	//³                  @OUT_RESULTADO char(01) OutPut )                       ³
	//³                                                                         ³
	//³ as                                                                      ³
	//³                                                                         ³
	//³Declaracao de Variaveis ->cDeclare                                       ³
	//³                                                                         ³
	//³begin            ¿                                                       ³
	//³   instrucoes    |->cCorpo                                               ³	
	//³end              Ù                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cQueryExec += " CREATE PROCEDURE CTB220C_"+cEmpAtu+" ("
	cQueryExec += " @IN_FILIALCOR  Char(" + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) )+ "), "+CRLF
	cQueryExec += " @OUT_RESULTADO Char(01) OutPut "
	cQueryExec += " )"+CRLF
	cQueryExec += "AS "+CRLF
	cQueryExec += cDeclare +CRLF
	cQueryExec += cCorpo
	cQueryExec := MsParse(cQueryExec,Alltrim(TcGetDB()))

	cProc := 'CTB220C_'+cEmpAtu
	If TCSPExist( cProc )
		cRet := TcSqlExec('DROP PROCEDURE '+cProc)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0019+" "+cProc+": "+cTabela)  //'Erro na exclusao da procedure'
			EndIf
			Return .f.
		EndIf
	EndIf
    cRet := TcSqlExec(cQueryExec)
    If cRet = 0
	   aResult := TCSPExec( xProcedures('CTB220C'), cFilAnt )
	   DbSelectArea(cTabela)
	   TCRefresh(RetFullName(cTabela))
		If Empty(aResult)
			If !__lBlind
				If mv_par01 == 2 .And. lCt2Contin
					MsgAlert(STR0017+" "+cProc+": "+cTabela+CRLF+;  //'Erro na chamada do processo'
					STR0050+CRLF+;  //"Provaveis causas: "
					STR0051+CRLF+;  //"-Chave Duplicada nos movimentos contabeis (rotina executada anteriormente com mesmos parametros)."
					STR0052+CRLF+;  //"-Campos com tamanhos diferentes entre as empresas consolidar/consolidadora"
					STR0053+CRLF+;  //"Para maior detalhamento consulte Mensagens no Monitor do TOTVSDBAccess"
					STR0054)        //"*** Abortando operação de consolidação *** "
					Final("")
				Else
					MsgAlert(STR0017+" "+cProc+": "+cTabela )  //'Erro na chamada do processo'
				EndIf
			EndIf
			lRet := .f.
		Elseif aResult[1] != "1"
			If !__lBlind
				MsgAlert(STR0020+" "+cProc+": "+cTabela)   //'Atualizacao com Erro'
			EndIf
			lRet := .f.
		EndIf
	   cRet := TcSqlExec('DROP PROCEDURE '+cProc)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0019+" "+cProc+": "+cTabela)   //'Erro na exclusao da procedure'
			EndIf
			Return .f.
		EndIf
	Else       
		If !__lBlind
			MsgAlert(STR0021+" "+cProc+": "+cTabela)  //'Erro na criacao da procedure'
		EndIf
		lRet := .f.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220Select³ Autor  ³ Alice Y. Yamamoto       ³ Data 14.10.03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Query das tabelas CT1-Conta,CTD-Item, CTH-Clvl,CTT-Custo,CTZ ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220Select(cEmpAtu,cTabela,aEmpAux,cArray)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Query                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmpAtu                                             ³±±
±±³           ³ ExpC2 = cTabela origem                                      ³±±
±±³           ³ ExpC3 = aEmpAux[n][1] - Array c/as empresas a consolidar    ³±±
±±³           ³         aEmpAux[n][2] - Tabela a ser consilidada            ³±±
±±³           ³ ExpC4 = cArray  - Emp+Filiais a consolidar                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220Select(cEmpAtu,cTabela,aEmpAux,cArray)
Local cQuery     :=""
Local cQueryExec :=""
Local cSelect    :=""
Local cWhere     :=""
Local aCampos    := {}
Local cCampos    := ""
Local cEmp       := ""
Local cINAux     := ""
Local ix, nCont
Local lSkipCpo  := Iif(Alltrim(Upper(TCGetDB())) $ "DB2/INFORMIX", .T., .F.)   // Se for DB2 ou Informix não copia campos Memo

cQuery := ""
cSelect:= ""
cWhere := "" 
cQueryExec := ""

cEmp := "  "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ cSelect e cWhere                                             ³
//³ cCampos - campos do select                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := (cTabela)->(DbStruct())
cCampos := ""
lFirst  := .T.
For ix := 1 to Len(aCampos)
	if Mod(ix,5) = 0
		cCampos+=  CRLF+"                  "
	EndIf
	If Trim(aCampos[ix][1]) == cTabela+"_FILIAL" .Or. (aCampos[ix][2] == "M"  .and. lSkipCpo )
     	loop
   	EndIf
	
	If !lFirst
		cCampos +=", "
	EndIf
	lFirst := .F.

	cCampos += Trim(aCampos[ix][1])	
Next ix
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monto o select da tabela de acordo com as empresas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
For nCont := 1 to Len(aEmpAux)
	cEmp := aEmpAux[nCont][1]
	cSelect += "    Select "+cCampos+CRLF
	cSelect += "      FROM "+aEmpAux[nCont][2]+ CRLF
	cWhere  += "     WHERE D_E_L_E_T_ = ' ' "+CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as filiais do empresa - ( '01','02',..)                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cINAux := "#"+cEmp
	cIN    := CTB220FilIn(cInAux, cArray)
	cWhere += "        AND "+cTabela+"_FILIAL IN "+ cIN +CRLF
	If cTabela = "CTZ"
		cWhere += "        AND CTZ_DATA between '"+Dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"+CRLF
		cWhere += "        AND CTZ_TPSALD = '"+rtrim(mv_par07)+"'"+CRLF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona Moeda                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par05 = 2  // moeda especifica
			cWhere+= "      AND CTZ_MOEDLC = '"+Trim(mv_par06)+"'"+ CRLF
		EndIf
	EndIf
	If nCont < Len(aEmpAux)
		cWhere += "    UNION"+CRLF
	EndIf
	cQuery += cSelect+cWhere
	cSelect:= ""
	cWhere := ""
Next nCont
cQueryExec += cQuery

Return(cQueryExec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTB220Share³ Autor ³ Alice Y Yamamoto      ³ Data ³ 15.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o Arquivo e compartilhado                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB220Share                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB220Share(cEmp, cTabela, aEmpresas, nCont)
Local aArea := GetArea()
LOCAL cIndSx2
LOCAL cArqSx2
Local aArq  :={} 
Local iTamFil := 0
Local iTamUni := 0
Local iTamEmp := 0
Local cEmpTab := ''
Local cUniTab := ''
Local cFilTab := ''
Local cFilAux := ''
Local cModo   := ''
Local cModoUni:= ''
Local cModoEmp:= ''
Local lCompartilhado := .t.
Local cLayOut := FWSM0Layout()
Local lGestao := .F.
Local iX      := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aEmpAux-> [n][1]-Empresas a serem consolidadas                          ³
//³           [n][2]-tabelas a serem consilidadas                           ³
//³           [n][3]-Filial da tabela consolidada qdo existe Gestao Corpor. ³
//³          Ex: aEmpAux[1][1]- '01'                                        ³
//³          Ex: aEmpAux[1][2]- CT1010                                      ³
//³          Ex: aEmpAux[1][3]- 'D MG    '                                  ³
//³          Ex: aEmpAux[2][1]- '02'                                        ³
//³          Ex: aEmpAux[2][2]- CT1020                                      ³
//³          Ex: aEmpAux[2][3]- 'M SP 01 '                                  ³
//³          Ex: aEmpAux[3][1]- '04'                                        ³
//³          Ex: aEmpAux[3][2]- CT1030                                      ³
//³          Ex: aEmpAux[3][3]- 'M       '                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(Alltrim(cLayOut)) == 0 .or. Len(CT2->CT2_FILIAL) == 2
	lGestao := .F.
	iTamFil := 2
Else
	lGestao := .T.
	For iX := 1 to Len(Alltrim(cLayOut))
		If "E" $ Substring(cLayOut,iX, 1)
			iTamEmp += 1
		EndIf
		If "U" $ Substring(cLayOut,iX, 1)
			iTamUni += 1
		EndIf
		If "F" $ Substring(cLayOut,iX, 1)
			iTamFil += 1
		EndIf
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GESTAO CORPORATIVA - combinacoes possiveis ³
//³       E  U  F                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Verificar através das funções de Frame o compartilhamento das tabelas
cModoEmp	:= FWModeAccess(cTabela,1,cEmp)
cModoUni	:= FWModeAccess(cTabela,2,cEmp)
cModo   	:= FWModeAccess(cTabela,3,cEmp)
		
cArqSx2 := "SX2" + cEmp + "0"
cIndSx2	:= cArqSx2+"1"
cArqIx2 := cIndSx2

OpenSxs(,,,,cEmp,"SX2Tabela","SX2",,.F.)

If Select("SX2Tabela") <= 0 		//Se não conseguiu abrir o SX2 com o índice padrao
	Final(cTabela+cEmp + STR0014)  //" n†o encontrado"
Endif

dbSetOrder(1)
If SX2Tabela->(dbSeek(cTabela))  
	If lGestao 
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tamanhos de emp, Unidade de Neg. e Filial  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If iTamEmp > 0
		   cEmpTab := Substring(aEmpresas[nCont][2], 1, iTamEmp)
		EndIf
		If iTamUni > 0
		   cUniTab := Substring(aEmpresas[nCont][2], iTamEmp + 1, iTamUni)
		EndIf
 		cFilAux := Substring(aEmpresas[nCont][2], iTamEmp + iTamUni+ 1, iTamFil)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ gestao SOMENTE com filial e MAIOR que 2    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		
		If (iTamEmp == 0 .and. iTamUni == 0) .and. iTamFil > 2
			If cModo = 'C'
				lCompartilhado := .T.
				cFilTab := Space( iTamFil )
			Else
				lCompartilhado := .F.
				cFilTab := cFilAux
			EndIf
			aArq := AADD(aArq, {lCompartilhado, RetFullName(cTabela, cEmp), cFilTab} )
		else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gestao com Emp - Uni - Filial              ³
			//³ cFilTab := cEmpTab+cUniTab+cfilAux         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If iTamEmp > 0 .and. iTamUni > 0 .and. iTamFil > 0
				If cModoEmp == 'C' .and. cModoUni == 'C' .and. cModo == 'C'
					cFilTab := Space(iTamEmp)+Space(iTamUni)+Space(iTamFil)
					lCompartilhado := .T.
				EndIf
				If cModoEmp == 'E' .and. cModoUni == 'C' .and. cModo == 'C'
					cFilTab := cEmpTab+Space(iTamUni)+Space(iTamFil)
					lCompartilhado := .F.
				EndIf
				If cModoEmp == 'E' .and. cModoUni == 'E' .and. cModo == 'C'
					cFilTab := cEmpTab+cUniTab+Space(iTamFil)
					lCompartilhado := .F.
				EndIf
				If cModoEmp == 'E' .and. cModoUni == 'E' .and. cModo == 'E'
					cFilTab := cEmpTab+cUniTab+cFilAux
					lCompartilhado := .F.
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gestao com Emp - Filial                    ³
			//³ cFilTab := cEmpTab+cFilAux                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If iTamEmp > 0 .and. iTamUni == 0 .and. iTamFil > 0
				If cModoEmp == 'C' .and. cModo == 'C'
					cFilTab := Space(iTamEmp)+Space(iTamFil)
					lCompartilhado := .T.
				EndIf
				If cModoEmp == 'E' .and. cModo == 'C'
					cFilTab := cEmpTab+Space(iTamFil)
					lCompartilhado := .F.
				EndIf
				If cModoEmp == 'E' .and. cModo == 'E'
					cFilTab := cEmpTab+cFilAux
					lCompartilhado := .F.
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gestao com Uni - Filial                    ³
			//³ cFilTab := cUniTab+cfilAux                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If iTamEmp == 0 .and. iTamUni > 0 .and. iTamFil > 0
				If cModoUni == 'C' .and. cModo == 'C'
					cFilTab := Space(iTamUni)+Space(iTamFil)
					lCompartilhado := .T.
				EndIf
				If cModoUni == 'E' .and. cModo == 'C'
					cFilTab := cUniTab+Space(iTamFil)
					lCompartilhado := .F.
				EndIf
				If cModoUni == 'E' .and. cModo == 'E'
					cFilTab := cUniTab+cFilAux
					lCompartilhado := .F.
				EndIf
			EndIf
		EndIf
		aArq := AADD(aArq, {lCompartilhado, RetFullName(cTabela, cEmp), cFilTab} )
	Else
		if cModo = "C"
			aArq := AADD(aArq, {.T., RetFullName(cTabela, cEmp), ' ' } )
		Else
			aArq := AADD(aArq, {.F., RetFullName(cTabela, cEmp), ' ' } )
		EndIf
	EndIf
Endif

SX2Tabela->(dbCloseArea())

RestArea(aArea)

Return(aArq)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTB220FilIn³ Autor ³ Alice Y Yamamoto      ³ Data ³ 09.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Identifica as as filiais da empresa corrente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct220FinIn(cINAux,cArray)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ String com as filiais da empresa atual - ( '01','02')        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaCTB                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = '#'+ Empresa                                         ³±±
±±³          ³ ExpC2 = String com Empresa e suas filiais                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB220FilIn(cInAux, cArray)
Local cIN := ""
Local nIn
Local iX
Local cLayOut := FWSM0Layout()
Local lGestao := .F.
Local nX      := 0
Local iTamEmp := 0
Local iTamUni := 0
Local iTamFil := 0
Local iFilAux := 0

If Len(Alltrim(cLayOut)) == 0 .or. Len(CT2->CT2_FILIAL) == 2
	lGestao := .F.
	iTamFil := 2
Else
	lGestao := .T.
	For nX := 1 to Len(Alltrim(cLayOut))
		If "E" $ Substring(cLayOut,nX, 1)
			iTamEmp += 1
		EndIf
		If "U" $ Substring(cLayOut,nX, 1)
			iTamUni += 1
		EndIf
		If "F" $ Substring(cLayOut,nX, 1)
			iFilAux += 1
		EndIf
	Next
	iTamFil := iTamEmp+iTamUni+iFilAux
Endif

nIn    := At(cInAux, cArray) + Len(cInAux)
For iX := nIn to Len(Rtrim(cArray))
	If Substr(cArray,iX,1) = "#" 
		cIN := Substr(cIN,1,(Len(Rtrim(cIN)))-1)
		Exit
   Else
		cIN += "'" +Substr(cArray,iX, IIf( lGestao, iTamFil, 2 ) )+"', "
		iX +=  IIf( lGestao, iTamFil, 2 ) - 1
	EndIf
Next iX
cIN := "("+cIN+")"
Return(cIN)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct220CrTrb³ Autor ³ Simone Mie Sato       ³ Data ³ 12.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria arquivo de trabalho									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct220CrTrb()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct220CrTrb()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220CrTrb(cNomeArq,lJaProc,lCriaTRB,lNovoTRB)

Local aCampos	:= {}
Local aCampos1	:= {}
Local aTamVlr	:= {}
procLogAtu("INICIO",STR0061)
aTamVlr := TamSX3("CQ1_DEBITO")

aCampos := {{"IDENT"	,"C",3			,0},;
 		    {"CONTA" 	,"C",nTamCta	,0},;
 		    {"CUSTO" 	,"C",nTamCC		,0},;
 			{"ITEM"  	,"C",nTamItem	,0},;
 			{"CLVL" 	,"C",nTamClvl	,0},;
   			{"SALDOD"	,"N",aTamVlr[1]+2,aTamVlr[2]},;
   			{"SALDOC"	,"N",aTamVlr[1]+2,aTamVlr[2]},;
   			{"TPSALDO"	,"C",1			,0},;
			{"MOEDA"	,"C",2			,0},;
			{"JAPROC"	,"C",1			,0},;
			{"DATAM"	,"D",8          }}
			
AADD(aCampos1,{"IDENT"	,"C",3,0})
AADD(aCampos1,{"CONTA" 	,"C",nTamCta	,0})
AADD(aCampos1,{"CUSTO" 	,"C",nTamCC		,0})
AADD(aCampos1,{"ITEM" 	,"C",nTamItem	,0})
AADD(aCampos1,{"CLVL" 	,"C",nTamClvl	,0})
AADD(aCampos1,{"SALDOD" ,"N",aTamVlr[1]+2,aTamVlr[2]	,0})
AADD(aCampos1,{"SALDOC" ,"N",aTamVlr[1]+2,aTamVlr[2]	,0})
AADD(aCampos1,{"TPSALDO","C",1			,0})
AADD(aCampos1,{"MOEDA" 	,"C",2			,0})
AADD(aCampos1,{"JAPROC" ,"C",1			,0})
AADD(aCampos1,{"DATAM" 	,"D",8	,0})

		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Crio arq. de trab. p/ gravar os lancamentos				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If _oCTBA2201 <> Nil
	_oCTBA2201:Delete()
	_oCTBA2201 := Nil
Endif


_oCTBA2201 := FWTemporaryTable():New( "TRB" )  
_oCTBA2201:SetFields(aCampos1) 
_oCTBA2201:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT","DATAM"})
_oCTBA2201:AddIndex("2", {"TPSALDO","MOEDA","IDENT","DATAM","CONTA","CUSTO","ITEM","CLVL"})

//------------------
//Criação da tabela temporaria
//------------------
_oCTBA2201:Create()  

cArqTrab		:= _oCTBA2201:GetRealName()

procLogAtu("FIM",STR0061)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct220GrLan³ Autor ³ Simone Mie Sato       ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava lancamentos de saldo inicial						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct220GrLan()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct220GrLan()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct220GrLan(aCTOxCTE,cLote,cSubLote,cDoc,lMoedaEsp)

Local aSaveArea	:= GetArea()
Local aCols		:= {}

Local nSaldo	:= 0
Local nLinha	:= 0 
Local CTF_LOCK	:= 0
Local nMoedAtu	:= 0
Local nForaCols	:= 0

Local lFirst	:= .T.

Local cTpSldAnt	:= ""
Local cMoedAnt	:= ""
Local cLinha	:= "001"
Local cSeqLan	:= "001"
Local cTipo		:= ""	
Local cDebito	:= ""
Local cCustoDeb	:= ""
Local cItemDeb	:= ""
Local cClVlDeb	:= ""
Local cCredito	:= ""
Local cCustoCrd	:= ""
Local cItemCrd	:= ""
Local cClVlCrd	:= ""
Local cHP		:= ""
Local cDescHP	:= STR0026	//"Saldo Inicial"


dbSelectArea("TRB")
dbSetOrder(1)
dbGoTop()

lMesmaLin := .F.
nExecLin  := 1

While TRB->(!Eof())
    
   	nSaldo := TRB->SALDOC - TRB->SALDOD
   	
	lMesmaLin := .F.
	
	If TRB->SALDOC == TRB->SALDOD .AND. (TRB->SALDOC <> 0 .OR. TRB->SALDOD <> 0)
		//Se houver LANÇAMENTO a DEB ou CRED e resulta em saldo zerado, desmembra em 2 lançamentos
		If nExecLin == 1
			nSaldo := TRB->SALDOC
		ElseIf nExecLin == 2
			nSaldo := ( 0 - TRB->SALDOD )
		Else
		 	nExecLin  := 1
		 	TRB->(dbSkip())
		 	Loop
		EndIf		

		lMesmaLin := .T.	
	Else	
		If nSaldo == 0
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
    	
	If nSaldo > 0	
		cTipo		:= "2"		/// LANCAMENTO A CREDITO
		cDebito		:= ""
		cCustoDeb	:= ""
		cItemDeb	:= ""
		cClVlDeb	:= ""

		cCredito	:= TRB->CONTA
		cCustoCrd	:= TRB->CUSTO
		cItemCrd	:= TRB->ITEM
		cClVlCrd	:= TRB->CLVL			
	Else
		cTipo := "1"		/// LANCAMENTO A DEBITO
		cDebito		:= TRB->CONTA
		cCustoDeb	:= TRB->CUSTO
		cItemDeb	:= TRB->ITEM	
		cClVlDeb	:= TRB->CLVL
		
		cCredito	:= ""
		cCustoCrd	:= ""
		cItemCrd	:= ""
		cClVlCrd	:= ""
	EndIf 
                     
	nSaldo 		:= ABS(nSaldo)	
	nMoedAtu	:= VAL(TRB->MOEDA)

	BEGIN TRANSACTION
	//Grava lancamento na moeda 01
	If lFirst .or. nLinha > nMAX_LINHA .or. TRB->TPSALDO <> cTpSldAnt .or. TRB->MOEDA <> cMoedAnt
		cMoedAnt	:= TRB->MOEDA
		cTpSldAnt	:= TRB->TPSALDO
	
		Do While !ProxDoc(aCTOxCTE[nMoedAtu][3]-1,cLote,cSubLote,@cDoc,@CTF_LOCK)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o N§ do Doc estourou, incrementa o lote         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLote := CtbInc_Lot(cLote, "CTB", .T.) // True para forcar chave pelo modulo CTB
		Enddo
		lFirst := .F.
		cLinha := "001"
		nLinha := 0
		cSeqLan:= "001"
	Else
		cSeqLan	:= Soma1(cSeqLan)
	EndIf
	
	If TRB->MOEDA == "01"
		aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }
		
		GravaLanc(aCTOxCTE[nMoedAtu][3]-1,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
			  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
		  	TRB->TPSALDO,@cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,,,,,,,.F.)
		  	
	Else	/// Grava Lancamento na moeda 02 com valor zerado na moeda 01
		aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
		If val(TRB->MOEDA) > 2
			nForaCols	:= VAL(TRB->MOEDA)-2
		Else                
			nForaCols	:= 0
		EndIf
			
		GravaLanc(aCTOxCTE[nMoedAtu][3]-1,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
			  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
			  TRB->TPSALDO,cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,,.F.)
				  
		GravaLanc(aCTOxCTE[nMoedAtu][3]-1,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
			  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
			  TRB->TPSALDO,cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,,.F.)						  				
	EndIf
		 
	END TRANSACTION

	nLinha := Val(cLinha)

	If !lMesmaLin .or. nExecLin >= 3
	 	nExecLin  := 1
		TRB->(dbSkip())
	Else
		nExecLin++
	EndIf
EndDo

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB220GTRB³ Autor ³ Simone Mie Sato       ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifico os Saldos e Grava no Arquivo de Trabalho			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB220GTRB()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ cArquivoM - Arquivo de saldo MES                          ³±±
±±³             cArquivoD - Arquivo de saldo Dia                          ³±±
±±³             cModoSX2  - Deve ser o mesmo para os 2 aquivos acima     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ CTBA220                                                    ³±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTB220GTRB(cAlias,aCTOxCTE,aTpSaldos,oObj,lCusto,lItem,lClvl,lMoedaEsp,cMoeda,cModoSX2,lBat,oSelf,cArquivoM,cArquivoD )

Local lObj := ValType(oObj) == "O"

Local nRecno	:=	0
Local nTotRegua	:= ((cAlias)->(Reccount()))
Local cConta 	:= SPACE(nTamCta)
Local cCusto 	:= SPACE(nTamCC)
Local cItem  	:= SPACE(nTamItem)
Local cClVl		:= SPACE(nTamClVl)
Local nMoedAtu	:= 1
Local cMoedAtu	:= "01"
Local nTpSldAtu	:= 1
Local cTpSldAtu	:= "1"
Local aSldAtu	:= {}
Local nDebTrb	:= 0 
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local cKeyAtu	:= ""
Local cData   := ctod("  /  /  ")
Local lRpo1_1	:= Iif(GetRpoRelease() == "R1.1",.T.,.F.)              
                    
dbSelectArea(cAlias)
dbSetOrder(1)
If cModoSX2 == "C"
	cFilAlias :=  "  "
Else
	cFilAlias := xFilial(cAlias)
EndIf

//// FAZ O PROCESSAMENTO PARA TODAS AS MOEDAS
For nMoedAtu := 1 to Len(aCTOxCTE)

	If lMoedaEsp .And. cMoeda <> '01' .And. nMoedAtu == 1
		Loop
	EndIf

	cMoedAtu := aCTOxCTE[nMoedAtu][1]

	//// FAZ O PROCESSAMENTO PARA TODOS OS TIPOS DE SALDOS
	For nTpSldAtu := 1 to Len(aTpSaldos)
		cTpSldAtu := STRZERO(nTpSldAtu,1)

		If lObj
			oObj:SetRegua2(nTotRegua)			 								
		EndIf
		
		MsSeek(cFilAlias,.T.) //Procuro pela primeira conta a ser zerada
		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFilAlias .and. (cAlias)->&(cAlias+"_DATA") < (MV_PAR02)
			If (cAlias)->&(cAlias+"_MOEDA") != cMoedAtu .or. (cAlias)->&(cAlias+"_TPSALD") != cTpSldAtu
				(cAlias)->(dbSkip())
				Loop
			Endif
 	 			cData :=(cAlias)->&(cAlias+"_DATA") 			
			If cAlias == 'CQ6'
				If Empty((cAlias)->CQ6_CONTA) .or.  Empty((cAlias)->(CQ6_CLVL))
					Loop
				EndIf
			ElseIf cAlias == 'CQ4'
				If Empty((cAlias)->(CQ4_CONTA)) .or. Empty((cAlias)->(CQ4_ITEM))
					Loop
				EndIf
			ElseIf cAlias == 'CQ2'
				If Empty((cAlias)->(CQ2_CONTA)) .or. Empty((cAlias)->(CQ2_CCUSTO))
					Loop
				EndIf
			ElseIf cAlias == 'CQ0'
				If Empty((cAlias)->(CQ0_CONTA))
					Loop
				EndIf
			EndIf
		
			If !lBat   
				If lRpo1_1
					oSelf:IncRegua1()
				Else
					IncProc()
				EndIf	
			EndIf
			
			If cAlias == 'CQ6'
				cChave := (cAlias)->(CQ6_CONTA+CQ6_CCUSTO+CQ6_ITEM+CQ6_CLVL)
				cConta := (cAlias)->CQ6_CONTA
				cCusto := (cAlias)->CQ6_CCUSTO
				cItem  := (cAlias)->CQ6_ITEM
				cClVl  := (cAlias)->CQ6_CLVL
			ElseIf cAlias == 'CQ4'
				cChave := (cAlias)->(CQ4_CONTA+CQ4_CCUSTO+CQ4_ITEM)
				cConta := (cAlias)->CQ4_CONTA
				cCusto := (cAlias)->CQ4_CCUSTO
				cItem  := (cAlias)->CQ4_ITEM
			ElseIf cAlias == 'CQ2'       
				cChave := (cAlias)->(CQ2_CONTA+CQ2_CCUSTO)
				cConta := (cAlias)->CQ2_CONTA
				cCusto := (cAlias)->CQ2_CCUSTO
			ElseIf cAlias == 'CQ0'
				cChave := (cAlias)->CQ0_CONTA
				cConta := (cAlias)->CQ0_CONTA
			EndIf
				 
			If cAlias == 'CQ6'
				aSldAtu	:= SaldoCQPer("CTH",cConta,cCusto,cItem,cClVL,"CTH",FirstDay(cData),cData,cMoedAtu,cTpSldAtu,,,{cFilAlias},cArquivoM,cArquivoD)			
			ElseIf cAlias == 'CQ4'
				aSldAtu	:= SaldoCQPer("CTD",cConta,cCusto,cItem,,"CTD",FirstDay(cData),cData,cMoedAtu,cTpSldAtu,,,{cFilAlias},cArquivoM,cArquivoD)
			ElseIf cAlias == 'CQ2'
				aSldAtu	:= SaldoCQPer("CTT",cConta,cCusto,,,"CTT",FirstDay(cData),cData,cMoedAtu,cTpSldAtu,,,{cFilAlias},cArquivoM,cArquivoD)
			ElseIf cAlias == 'CQ0'
				aSldAtu	:= SaldoCQPer("CT1",cConta,,,,"CT1",FirstDay(cData),cData,cMoedAtu,cTpSldAtu,,,{cFilAlias},cArquivoM,cArquivoD)
			EndIf
			
			nTrbSlD := 0
			nTrbSlC := 0
			dbSelectArea("TRB")
			dbSetOrder(2)

			If (aSldAtu[2] <> 0 .or. aSldAtu[3] <> 0) //aSldAtu[1] <> 0						/// SE HOUVER SALDO
				If cAlias == "CQ4" //.or. (cAlias == "CT3" .and. !lItem)
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ6"+Dtos(cData)+cConta+cCusto+cItem
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+Dtos(DATAM)+CONTA+CUSTO+ITEM)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf					
					EndIf
				ElseIf cAlias == "CQ2" //.or. (cAlias == "CT7" .and. !lCusto)
					If lItem
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ4"+Dtos(cData)+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+Dtos(DATAM)+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf
					EndIf

					/// SE NÃO LOCALIZOU CHAVE NO CT4 VERIFICA SE HÁ NO CTI
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ6"+Dtos(cData)+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+Dtos(DATAM)+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf										
					EndIf
				ElseIf cAlias == "CQ0"				
					If lCusto
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ2"+Dtos(cData)+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+Dtos(DATAM)+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf
					EndIf
					/// SE NÃO LOCALIZOU CHAVE NO CT3 VERIFICA SE HÁ NO CT4
					If lItem
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ4"+Dtos(cData)+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+Dtos(DATAM)+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf
					EndIf
					
					/// SE NÃO LOCALIZOU CHAVE NO CT4 VERIFICA SE HÁ NO CTI
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ6"+Dtos(cData)+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+Dtos(DATAM)+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf					
					EndIf
				EndIf

			EndIf
			
			nDebTrb := aSldAtu[2] - nTrbSlD
			nCrdTrb := aSldAtu[3] - nTrbSlC

			dbSelectArea("TRB")
			dbSetOrder(1)
			If (nDebTrb <> 0 .or. nCrdTrb <> 0) 
				If !dbSeek(cTpSldAtu+cMoedAtu+cConta+cCusto+cItem+cClvl+cAlias+Dtos(cData),.F.)
					dbSetOrder(2)
					RecLock("TRB",.T.)
					Field->TPSALDO	:= cTpSldAtu
					Field->MOEDA	:= cMoedAtu
					Field->CONTA	:= cConta
					Field->CUSTO	:= cCusto
					Field->ITEM		:= cItem
					Field->CLVL		:= cClVL
					Field->IDENT	:= cAlias
					Field->SALDOD	:= nDebTrb
					Field->SALDOC	:= nCrdTrb
					Field->DATAM   := cData
					TRB->(MsUnlock())
				Else
					RecLock("TRB",.F.)					
					Field->SALDOD	+= nDebTrb
					Field->SALDOC	+= nCrdTrb
					TRB->(MsUnlock())					
				EndIf
			EndIf
			
			dbSelectArea(cAlias)
			(cAlias)->(dbSkip())
		EndDo
	Next nTpSldAtu
Next nMoedAtu

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220aEmp³ Autor  ³ Alice Y. Yamamoto       ³ Data 22.02.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Retorna as Empresas e as Tabelas a serem utilizadas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220aEmp(aEmpresas, cTabela)                            )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³aEmpAux                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = aEmpresas                                          ³±±
±±³           ³ ExpC1 = cTabela                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220aEmp(aEmpresas, cTabela)
Local nCont
Local cEmp     := "  "
Local aEmpAux  := {}
Local cEmpAnt  := " "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aEmpAux-> [n][1]-Empresas a serem consolidadas                          ³
//³           [n][2]-tabelas a serem consilidadas                           ³

//³          Ex: aEmpAux[1][1]- '01'                                        ³
//³          Ex: aEmpAux[1][2]- CT1010                                      ³
//³          Ex: aEmpAux[2][1]- '02'                                        ³
//³          Ex: aEmpAux[2][2]- CT1020                                      ³
//³          Ex: aEmpAux[3][1]- '04'                                        ³
//³          Ex: aEmpAux[3][2]- CT1030                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont :=1 to Len(aEmpresas)
	cEmp := If( !Empty(aEmpresas[nCont][1]) .and. aEmpresas[nCont][1] != cEmpAnt, aEmpresas[nCont][1], cEmpAnt )
	//Se a empresa for diferente ou se a Filial for Exclusiva
	aArq  := CTB220Share(cEmp, cTabela, aEmpresas, nCont)
    If cEmp != cEmpAnt
	    nPos  := 0
	    nPos  := Ascan(aEmpAux, {|x|Alltrim (Upper(x[2])) == Alltrim(Upper(aArq[2]))})
		// se a tabela não existir em empresas anteriores ou se a empresas for exclusiva e nao achou em ampresas anteriores
		If nPos = 0 .or. ( !aArq[1] .and. nPos <> 0 )
			Aadd( aEmpAux, {cEmp, aArq[2]} )
		EndIf
	EndIf
	cEmpAnt := cEmp
Next nCont

Return (aEmpAux)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220Array³ Autor  ³ Alice Y. Yamamoto       ³ Data 22.02.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Retorna as Empresas e as filiais utilizadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220Array(aEmpresas, cTabela)                            )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³cArray                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = aEmpresas                                           ³±±
±±³           ³ ExpC1 = cTabela                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220Array(aEmpresas, cTabela)
Local nCont, nCont1
Local cEmp     := "  "
Local cArray   := ""
Local cEmpAtu  := " "
Local aArq     := {}
Local cFilAux  := ''
Local cLayOut  := FWSM0Layout()
Local lGestao  := .F.

If Len(Alltrim(cLayOut)) == 0 .or. Len(CT2->CT2_FILIAL) == 2
	lGestao := .F.
Else
	lGestao := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ cArray ->#E1F1F2F3Fn#E2F1F2F3Fn#EnF1Fn, onde E - Empresas, F - Filiais  ³
//³          Ex: #0101020304#02  #03010204                                  ³
//³ aArq [1]-> .T. - Compatilhado -                                         ³
//³            .F. - Exclusivo    -                                         ³
//³ aArq [2]-> Tabela gravada no SX2                                        ³
//³ aArq [3]-> Filial da tabela aArq[2]  -- SOMENTE com GESTAO              ³
//³ Obs: o conteudo de aArq[3] eh utilizado somente com GEstao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEmpAtu := ""
cArray  := ""
For nCont := 1 to Len(aEmpresas)
	cEmp := If( !Empty(aEmpresas[nCont][1]), aEmpresas[nCont][1], cEmpAtu)
	If cEmp != cEmpAtu
		cArray += "#"+cEmp //Acrescenta Empresa
		cFilAux  := ''
	EndIf
	aArq  := CTB220Share(cEmp, cTabela, aEmpresas, nCont)
	If lGestao
		If cFilAux != aArq[3]
			cArray += IIf(aArq[1], Space(len(aEmpresas[nCont][2])), aArq[3])  // acrescenta a Filial
		EndIf
	  	cFilAux := aArq[3]
	Else
		cArray += IIf(aArq[1], Space(len(aEmpresas[nCont][2])), aEmpresas[nCont][2]) //acrecenta filial
	EndIf
	//Se filial compartilhado vou pra proxima empresa
	If aArq[1]
		nCont1 := nCont+1
		For nCont1 := nCont1 to Len( aEmpresas)
		    nCont := nCont1
			If !Empty(aEmpresas[nCont1][1]) .and. aEmpresas[ncont1][1] != cEmp // proxima empresa
				nCont := nCont - 1
				Exit
			Endif
		Next
	EndIf
  	cEmpAtu := cEmp
Next nCont
cArray+= "#"
Return(cArray)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220SalIni³ Autor  ³ Alice Y. Yamamoto       ³ Data 22.02.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera lanctos de slds iniciais para o CTI                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220SalIni(aEmpresas, cTabAlias)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = aEmpresas                                            ³±±
±±³           ³ ExpC1 = cTabAlias                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220SalIni(aEmpresas, cTabAlias, cLote, cDoc)
Local aArea := GetArea()
Local nCont
Local cEmp     := ""
Local aEmpAux  := {}
Local cArray   := ""
Local lRet     := .t.
Local aResult
Local cTpSaldo := Trim(mv_par07)
Local cData    := Dtos(mv_par02-1)
Local lMoedaEsp:= Iif(mv_par05 == 2,"1","0")
Local cMoeda   := IIf(lMoedaEsp == "1", Alltrim(mv_par06), "00")
Local cSubLote := Trim(mv_par10)
Local cProc
Local cProcName
Local cTabela    // Tabela que tera o saldo inicial gerado ( CTI/CT4/CT3/CT7 )
Local cCT2Dest
Local cCTFDest

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Buscar a Tabela CT2 onde os saldos iniciais serao gerados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")
DbSetOrder(1)
If DbSeek("CT2")
	cCT2Dest := RetFullName("CT2", cEmpAnt)
EndIf
dbSelectArea("SX2")
DbSetOrder(1)
If DbSeek("CTF")
	cCTFDest := RetFullName("CTF", cEmpAnt)
EndIf

If cTabAlias = "CQ7"  //CQ7
	cProcName := "CTB220CQ7"
EndIf
If cTabAlias = "CQ5"  //CQ5
	cProcName := "CTB220CQ5"
EndIf
If cTabAlias = "CQ3"  //CQ3
	cProcName := "CTB220CQ3"
EndIf
If cTabAlias = "CQ1"   //CQ1
	cProcName := "CTB220CQ1"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aEmpAux-> [n][1]-Empresas a serem consolidadas                          ³
//³           [n][2]-tabelas a serem consilidadas                           ³
//³          Ex: aEmpAux[1][1]- '01'                                        ³
//³          Ex: aEmpAux[1][2]- CTI010                                      ³
//³          Ex: aEmpAux[2][1]- '02'                                        ³
//³          Ex: aEmpAux[2][2]- CTI020                                      ³
//³          Ex: aEmpAux[3][1]- '04'                                        ³
//³          Ex: aEmpAux[3][2]- CTI030                                      ³
//³ cArray ->#E1F1F2F3Fn#E2F1F2F3Fn#EnF1Fn, onde E - Empresas, F - Filiais  ³
//³          Ex: #0101020304#02  #03010204                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEmpAux  := Ctb220aEmp(aEmpresas, cTabAlias)
cArray   := Ctb220Array(aEmpresas, cTabAlias)
For nCont := 1 to Len(aEmpAux)
	cEmp   := Trim(aEmpAux[nCont][1])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criar procedure a cada vez que mudar a empresa                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTabAlias = "CQ7" //CQ6/CQ7
		cTabela := aEmpAux[nCont][2]
		cProc := Ctb220CQ7(cEmp, cCT2Dest, cCTFDest, cTabela, cArray )
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				Return .f.
			EndIf
		EndIf
	    cRet := TcSqlExec(cProc)
		If cRet < 0
			If !__lBlind
	   			MsgAlert(STR0021+" "+cProcName+"_"+cEmpAnt)  //'Erro na criacao da procedure'
	   		EndIf
			Return .f.
		EndIf
		aResult := TCSPExec( xProcedures(cProcName), cEmp, cFilAnt, cTpSaldo, cData, lMoedaEsp,;
	   															cMoeda,  cLote, cSubLote, cDoc, nMAX_LINHA)															   
		If Empty(aResult)
			If !__lBlind
				MsgAlert(STR0017+" "+cProcName+"_"+cEmpAnt)  //'Erro na chamada do processo'
			EndIf
			Return .f.
		EndIf
		If aResult[3] = 1
		   cLote := Substr(aResult[1],1,6)
			cDoc  := Soma1(aResult[2])
		EndIf
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0 
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				Return .f.
			EndIf
		EndIf
	Endif
	If cTabAlias = "CQ5"
		cTabela := aEmpAux[nCont][2]
		cProc := Ctb220CQ5(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpAux, cArray )
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0 
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				Return .f.
			EndIf
		EndIf
	   cRet := TcSqlExec(cProc)
	   If cRet < 0
	   	If !__lBlind
	   		MsgAlert(STR0021+" "+cProcName+"_"+cEmpAnt)  //'Erro na criacao da procedure'
	   	EndIf
			Return .f.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamo a procedure para cada filial da empresa                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	   aResult := TCSPExec( xProcedures(cProcName), cEmp, cFilAnt, cTpSaldo, cData, lMoedaEsp,;
	   															cMoeda,  cLote, cSubLote, cDoc, nMAX_LINHA)
		If Empty(aResult)
			If !__lBlind
				MsgAlert(STR0017+" "+cProcName+"_"+cEmpAnt)  //'Erro na chamada do processo'
			EndIf
			Return .f.
		EndIf
		If aResult[3] = 1
		   cLote := Substr(aResult[1],1,6)
			cDoc  := Soma1(aResult[2])
		EndIf
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				Return .f.
			EndIf
		EndIf
	Endif
	If cTabAlias = "CQ3"
		cTabela := aEmpAux[nCont][2]
		cProc := Ctb220CQ3(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpAux, cArray  )
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0 
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				lRet := .f.
			EndIf
		EndIf
	    cRet := TcSqlExec(cProc)
	    If cRet < 0
	   		If !__lBlind
	   			MsgAlert(STR0021+" "+cProcName+"_"+cEmpAnt)  //'Erro na criacao da procedure'
	   		EndIf
			lRet := .f.
		EndIf
	    aResult := TCSPExec( xProcedures(cProcName), cEmp, cFilAnt, cTpSaldo, cData, lMoedaEsp,;
	   															cMoeda,  cLote, cSubLote, cDoc, nMAX_LINHA)	
		If Empty(aResult)
			If !__lBlind
				MsgAlert(STR0017+" "+cProcName+"_"+cEmpAnt)  //'Erro na chamada do processo'
			EndIf
			lRet := .f.
		EndIf
		If aResult[3] = 1
		   cLote := Substr(aResult[1],1,6)
			cDoc  := Soma1(aResult[2])
		EndIf
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				Return .f.
			EndIf
		EndIf
	Endif
	If cTabAlias = "CQ1"
		cTabela := aEmpAux[nCont][2]
		cProc := Ctb220CQ1(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpAux, cArray )
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0 
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				lRet := .f.
			EndIf
		EndIf
	    cRet := TcSqlExec(cProc)
	    If cRet < 0
	   		If !__lBlind
		   		MsgAlert(STR0021+" "+cProcName+"_"+cEmpAnt)  //'Erro na criacao da procedure'
		    EndIf
			lRet := .f.
		EndIf
	    aResult := TCSPExec( xProcedures(cProcName), cEmp, cFilAnt, cTpSaldo, cData, lMoedaEsp,;
	   															cMoeda,  cLote, cSubLote, cDoc, nMAX_LINHA)
		If Empty(aResult) .or. ( aResult == nil )
			If !__lBlind
				MsgAlert(STR0017+" "+cProcName+"_"+cEmpAnt)  //'Erro na chamada do processo'
			EndIf
			lRet := .f.
		EndIf
		If aResult[3] = 1
		    cLote := Substr(aResult[1],1,6)
			cDoc  := Soma1(aResult[2])
		EndIf
		If TCSPExist( cProcName+"_"+cEmpAnt )
			cRet := TcSqlExec("DROP PROCEDURE "+cProcName+"_"+cEmpAnt)
			If cRet <> 0 
				If !__lBlind
					MsgAlert(STR0019+" "+cProcName+"_"+cEmpAnt)  //'Erro na exclusao da procedure'
				EndIf
				Return .f.
			EndIf
		EndIf
	Endif
Next nCont

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220CQ7  ³ Autor  ³ Alice Y. Yamamoto       ³ Data 23.02.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria procedure p geracao de lactos de saldos inciais do CQ7 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220CQ7(cEmp, cCT2Dest, cCTFDest, cTabela )               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³cQuery -> procedure de geracao de lactos de slds iniciais CQ7³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmp    - empresa que tera os dados consolidados    ³±±
±±³           ³ ExpC2 = cCT2Dest- CT2Destino. Onde os dados consolidados    ³±±
±±³           ³ ExpC3 = cCTFDest- CTF destino.                              ³±±
±±³           ³ ExpC4 = cTabela - Tabela (CQ7) q terao os dados consolidados³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220CQ7(cEmp, cCT2Dest, cCTFDest, cTabela, cArray)
Local cParam   :=""
Local cDeclare :=""
Local cCorpo   :=""
Local cQuery   :=""
Local aCampos  :=CT2->(DbStruct())
Local nPos
Local cINAux
Local cFiliais
Local iTamLinha := 0
Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local cXFILIAL  :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "XFILIAL_03", "XFILIAL" ))
Local cMSSTRZERO:=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSTRZERO_03"+"_"+cEmpAnt, "MSSTRZERO")
Local cMSSOMA1  :=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSOMA1_03"+"_"+cEmpAnt, "MSSOMA1")

cINAux   := "#"+cEmp
cFiliais := CTB220FilIn(cInAux, cArray)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procedure =>cQuery = cParam+cDeclare+cCorpo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada - cParam                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cParam := " Create Procedure CTB220CQ7_"+cEmpAnt+CRLF
cParam += "(" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_EMPORI" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_EMPORI       "+cTipo+CRLF  // empresa ORIGEM DOS LANCAMENTOS
cParam += "  @IN_FILIALDEST   Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )," +CRLF  // filial destino sm0->m0_codfil
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_TPSALDO      "+cTipo+CRLF
cParam += "  @IN_DATA         Char( 08 )," +CRLF
cParam += "  @IN_LMOEDAESP    Char( 01 )," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_MOEDA        "+cTipo +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_LOTE         "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_SUBLOTE      "+cTipo +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_DOC          "+cTipo+CRLF
cParam += "  @IN_MAXLINHA     Integer," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_LOTE       "+cTipo+" OutPut," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_DOC         "+cTipo+" OutPut, " +CRLF
cParam += "  @OUT_CONT        Integer OutPut " +CRLF
cParam += ")"+CRLF
cParam += "as "+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis da Procedure - cDeclare                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDeclare := "Declare @cFilial_CT2 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CTF Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ7 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilAnt     Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cData       Char( 08 )" +CRLF
cDeclare += "Declare @cDataAnt    Char( 08 )" +CRLF
cDeclare += "Declare @cAux1       Char( 01 )" +CRLF
cDeclare += "Declare @cAux        Char( 03 )" +CRLF
cDeclare += "Declare @lPrim       Char( 01 )" +CRLF
cDeclare += "Declare @cDc         Char( 01 )" +CRLF
cDeclare += "Declare @cManual     Char( 01 )" +CRLF
cDeclare += "Declare @cRotina     VarChar( 10 )" +CRLF
cDeclare += "Declare @cAglut      Char( 01 )" +CRLF
cDeclare += "Declare @cCrConv     Char( 01 )" +CRLF
cDeclare += "Declare @iRecno      integer" +CRLF
cDeclare += "Declare @iRecnoCTF   integer" +CRLF
cDeclare += "Declare @iMaxLinha   integer" +CRLF
cDeclare += "Declare @iLinha      integer" +CRLF
cDeclare += "Declare @iAux        integer" +CRLF
cDeclare += "Declare @iContador   integer" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSubLote    "+cTipo+CRLF
/* Crio com tamanho das variaveis de acordo com a estrutura do CT2*/
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_HIST" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cHist      "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQHIS" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqHis    "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQLAN" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqLan    "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cDoc       "+ cTipo+CRLF
cDeclare += "Declare @cDocAux    "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLote      "+ cTipo+CRLF
cDeclare += "Declare @cLoteAux   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DEBITO" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cConta     "+ cTipo+CRLF
cDeclare += "Declare @cContaDeb  "+ cTipo+CRLF
cDeclare += "Declare @cContaCrd  "+ cTipo+CRLF
cDeclare += "Declare @cContaAnt  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CCD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cCusto     "+ cTipo+CRLF
cDeclare += "Declare @cCustoDeb  "+ cTipo+CRLF
cDeclare += "Declare @cCustoCrd  "+ cTipo+CRLF
cDeclare += "Declare @cCustoAnt  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ITEMD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cItem      "+ cTipo+CRLF
cDeclare += "Declare @cItemDeb   "+ cTipo+CRLF
cDeclare += "Declare @cItemCrd   "+ cTipo+CRLF
cDeclare += "Declare @cItemAnt   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CLVLDB" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cClvl      "+ cTipo+CRLF
cDeclare += "Declare @cClvlDeb   "+ cTipo+CRLF
cDeclare += "Declare @cClvlCrd   "+ cTipo+CRLF
cDeclare += "Declare @cClvlAnt   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cMoeda     "+ cTipo+CRLF
cDeclare += "Declare @cMoeda1    "+ cTipo+CRLF
cDeclare += "Declare @cMoedaAnt  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
iTamLinha := aCampos[nPos][3]
cDeclare += "Declare @cLinha     "+ cTipo+CRLF
cDeclare += "Declare @cLinhaAux  "+ cTipo+CRLF
cDeclare += "Declare @nValor     Float"+CRLF
cDeclare += "Declare @nValor1    Float"+CRLF
cDeclare += "Declare @nDebito    Float"+CRLF
cDeclare += "Declare @nCredit    Float"+CRLF
cDeclare += "Declare @iLinha1    Integer"+CRLF
cDeclare += "Declare @lCriaLinha Char(01)"+CRLF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corpo da Procedure                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpo := "begin"+CRLF
cCorpo += "   Select @cLote     = @IN_LOTE"+CRLF
cCorpo += "   Select @cSubLote  = @IN_SUBLOTE"+CRLF
cCorpo += "   Select @cDoc      = @IN_DOC"+CRLF
cCorpo += "   Select @iRecno    = 0"+CRLF
cCorpo += "   Select @iRecnoCTF = 0"+CRLF
cCorpo += "   Select @iLinha    = 1"+CRLF
cCorpo += "   Select @iContador = 0"+CRLF
cCorpo += "   Select @cLinha    = '"+StrZero(0, iTamLinha)+"'"+CRLF
cCorpo += "   Select @cLinhaAux = '"+StrZero(0, iTamLinha)+"'"+CRLF
cCorpo += "   Select @cAux1     = '0'"+CRLF
cCorpo += "   select @cMoedaAnt = ' '"+CRLF
cCorpo += "   select @cDataAnt  = ' '"+CRLF
cCorpo += "   select @cContaAnt = ' '"+CRLF
cCorpo += "   select @cCustoAnt = ' '"+CRLF
cCorpo += "   select @cItemAnt  = ' '"+CRLF
cCorpo += "   select @cClvlAnt  = ' '"+CRLF
cCorpo += "   select @lPrim     = '1'"+CRLF
cCorpo += "   Select @cHist     = 'Saldo Inicial'"+CRLF
cCorpo += "   Select @cManual   = '1'"+CRLF
cCorpo += "   Select @cRotina   = 'CTBA101'"+CRLF
cCorpo += "   Select @cAglut    = '2'"+CRLF
cCorpo += "   Select @cSeqHis   = '001'"+CRLF
cCorpo += "   Select @cSeqLan   = ''"+CRLF
cCorpo += "   Select @cCrConv   = '4'"+CRLF
cCorpo += "   Select @iMaxLinha = @IN_MAXLINHA"+CRLF
cCorpo += "   select @nValor    = 0"+CRLF
cCorpo += "   Select @iAux      = 0"+CRLF
cCorpo += "   Select @OUT_LOTE  = ''"+CRLF
cCorpo += "   select @OUT_DOC   = ''"+CRLF
cCorpo += "   select @OUT_CONT  = @iContador"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   select @cAux      = 'CT2'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CT2 OutPut"+CRLF
cCorpo += "   select @cAux      = 'CTF'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CTF OutPut"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   Declare CUR_Ctb220CQ7 insensitive cursor  for"+CRLF
cCorpo += "   Select CQ7_FILIAL, CQ7_MOEDA, CQ7_DATA, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, Sum(CQ7_DEBITO),Sum(CQ7_CREDIT)"+CRLF
cCorpo += "     From "+cTabela+" A"+CRLF
cCorpo += "    Where D_E_L_E_T_ = ' '"+CRLF
If Substr(cFiliais,3,1) = " " 
	cCorpo += "        and CQ7_FILIAL = '  '"+CRLF 
Else
	cCorpo += "        and CQ7_FILIAL IN "+cFiliais+CRLF
EndIf
// PASSO1
cCorpo += "      and CQ7_DATA  <= @IN_DATA"+CRLF
cCorpo += "      and CQ7_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "      and CQ7_LP    != 'S'"+CRLF
cCorpo += "      and ( (CQ7_MOEDA  = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )"+CRLF
cCorpo += "   Group By CQ7_FILIAL, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_DATA, CQ7_MOEDA"+CRLF
cCorpo += "   Order By 1, 4, 5, 6, 7, 3, 2"+CRLF
cCorpo += "   For read only"+CRLF
cCorpo += "   Open CUR_Ctb220CQ7"+CRLF
cCorpo += "   Fetch CUR_Ctb220CQ7 into @cFilial_CQ7, @cMoeda, @cData, @cConta, @cCusto, @cItem, @cClvl, @nDebito, @nCredit"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   While ( @@fetch_status = 0 ) begin"+CRLF
/* ---------------------------------------------------------------------------------------
   Valor, ct2_dc, cta débito e credito  a Gravar
   --------------------------------------------------------------------------------------- */
cCorpo += "      Select @nValor = @nCredit - @nDebito"+CRLF
cCorpo += "      select @iLinha1 = 1"+CRLF
      /*   @lCrialinha = '1' gerar CT2 */
cCorpo += "      select @lCriaLinha = '1'"+CRLF
cCorpo += "      While @iLinha1 < 3 begin"+CRLF
cCorpo += "         If ( Round(@nCredit, 2)  = Round(@nDebito, 2) ) and ( Round(@nCredit, 2) != 0 or Round(@nDebito, 2) != 0 ) begin"+CRLF
cCorpo += "            If @iLinha1 = 1 begin"+CRLF
cCorpo += "               Select @nValor = @nCredit"+CRLF
cCorpo += "               select @iLinha1 = 2"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               If @iLinha1 = 2 begin"+CRLF
cCorpo += "                  Select @nValor = ( 0 - @nDebito )"+CRLF
cCorpo += "                  select @iLinha1 = 3"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
  /*  gerar PROXIMA linha  */
cCorpo += "            select @lPrim = '1'"+CRLF
cCorpo += "            select @lCriaLinha = '1'"+CRLF
cCorpo += "         end else begin"+CRLF
cCorpo += "            If Round(@nValor, 2) != 0 begin"+CRLF
cCorpo += "               select @lCriaLinha = '1'"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               select @lCriaLinha = '0'"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            select @iLinha1 = 3"+CRLF
cCorpo += "         end"+CRLF
cCorpo += "         If @lCriaLinha = '1' begin"+CRLF
cCorpo += "            select @iContador = 1"+CRLF   
cCorpo += "            If ( @cFilial_CQ7 != @cFilAnt and (@cFilAnt is not null) ) begin"+CRLF   
cCorpo += "               If @cDoc = '999999' begin"+CRLF   
cCorpo += "                  select @cAux1     = '0'"+CRLF   
cCorpo += "                  select @cLoteAux  = @cLote"+CRLF   
cCorpo += "                  Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF   
cCorpo += "                  select @cDoc = '000000'"+CRLF   
cCorpo += "               End"+CRLF   
cCorpo += "               select @iLinha = 1"+CRLF   
cCorpo += "               select @iAux   = Len( @cLinha )"+CRLF   
cCorpo += "               exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF   
cCorpo += "               select @cAux1     = '0'"+CRLF   
cCorpo += "               select @cDocAux   = @cDoc"+CRLF   
cCorpo += "               Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF   
cCorpo += "            End else begin"+CRLF   
cCorpo += "               If @IN_LMOEDAESP = '1' begin"+CRLF
cCorpo += "                  If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                     If @cDoc = '999999' begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLoteAux  = @cLote"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                        select @cDoc = '000000'"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                     select @iLinha = 1"+CRLF
cCorpo += "                     select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                     exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                     select @cDocAux   = @cDoc"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                  end else begin"+CRLF
cCorpo += "                     select @cAux1     = '0'"+CRLF
cCorpo += "                     select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                     select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End else begin"+CRLF
/* ---------------------------------------------------------------------------------------
   Qdo a moeda nao e'especifica gero a proxima linha somente qdo a moeda for diferente
   --------------------------------------------------------------------------------------- */
cCorpo += "                  If ( @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or"+CRLF
cCorpo += "                     @cItemAnt != @cItem or @cClvlAnt  != @cClvl ) or @lPrim  = '1' begin"+CRLF
cCorpo += "                     select @lPrim = '0'"+CRLF
cCorpo += "                     If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                        If @cDoc = '999999' begin"+CRLF
cCorpo += "                           select @cAux1     = '0'"+CRLF
cCorpo += "                           select @cLoteAux  = @cLote"+CRLF
cCorpo += "                           Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                           select @cDoc = '000000'"+CRLF
cCorpo += "                        End"+CRLF
cCorpo += "                        select @iLinha = 1"+CRLF
cCorpo += "                        select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                        exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                        select @cDocAux   = @cDoc"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                     end else begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                        select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Select @cSeqLan = @cLinha"+CRLF
cCorpo += "            If @nValor < 0 begin"+CRLF
/* ---------------------------------------------
   Lanca a Débito
   --------------------------------------------- */
cCorpo += "               Select @cDc = '1'"+CRLF
cCorpo += "               Select @cContaDeb = @cConta"+CRLF
cCorpo += "               Select @cContaCrd = ' '"+CRLF
cCorpo += "               Select @cCustoDeb = @cCusto"+CRLF
cCorpo += "               Select @cCustoCrd = ' '"+CRLF
cCorpo += "               Select @cItemDeb  = @cItem"+CRLF
cCorpo += "               Select @cItemCrd  = ' '"+CRLF
cCorpo += "               Select @cClvlDeb  = @cClvl"+CRLF
cCorpo += "               Select @cClvlCrd  = ' '"+CRLF
cCorpo += "               Select @nValor    = @nValor * ( -1 )"+CRLF
cCorpo += "            end else begin"+CRLF
/* ---------------------------------------------
   Lanca a Credito
   --------------------------------------------- */
cCorpo += "               Select @cDc = '2'"+CRLF
cCorpo += "               Select @cContaDeb = ' '"+CRLF
cCorpo += "               Select @cContaCrd = @cConta"+CRLF
cCorpo += "               Select @cCustoDeb = ' '"+CRLF
cCorpo += "               Select @cCustoCrd = @cCusto"+CRLF
cCorpo += "               Select @cItemDeb  = ' '"+CRLF
cCorpo += "               Select @cItemCrd  = @cItem"+CRLF
cCorpo += "               Select @cClvlDeb  = ' '"+CRLF
cCorpo += "               Select @cClvlCrd  = @cClvl"+CRLF
cCorpo += "            end"+CRLF
/* insercao na tabela destino CT2  */
/* ----------------------------------------------------------------------------
         Atualizao CTF
   ---------------------------------------------------------------------------- */
cCorpo += "            Select @iRecnoCTF = R_E_C_N_O_"+CRLF
cCorpo += "              From "+cCTFDest+CRLF
cCorpo += "             Where CTF_FILIAL = @cFilial_CTF"+CRLF
cCorpo += "               and CTF_DATA   = @IN_DATA"+CRLF
cCorpo += "               and CTF_LOTE   = @cLote"+CRLF
cCorpo += "               and CTF_SBLOTE = @cSubLote"+CRLF
cCorpo += "               and CTF_DOC    = @cDoc"+CRLF
cCorpo += "               and D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            If @iRecnoCTF is Null begin "+CRLF
cCorpo += "               Select @iRecnoCTF = IsNull(Max( R_E_C_N_O_), 0) From "+cCTFDest+CRLF
cCorpo += "               Select @iRecnoCTF = @iRecnoCTF + 1"+CRLF
cCorpo += "               Insert into "+cCTFDest+" ( CTF_FILIAL,   CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values ( @cFilial_CTF, @IN_DATA, @cLote,   @cSubLote,  @cDoc,   @cLinha,   @iRecnoCTF )"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update "+cCTFDest+CRLF
cCorpo += "               Set CTF_LINHA = @cLinha"+CRLF
cCorpo += "               Where R_E_C_N_O_ = @iRecnoCTF"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            If @IN_LMOEDAESP = '1' and @IN_MOEDA != '01' begin"+CRLF
cCorpo += "               Select @cMoeda1 = '01'"+CRLF
cCorpo += "               Select @nValor1 = 0"+CRLF
cCorpo += "               Select @cCrConv   = '5'"+CRLF
cCorpo += "               Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "               Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "               insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE,   CT2_DOC,     CT2_LINHA,  CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                   CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,     CT2_CCD,     CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,"+CRLF
cCorpo += "                                   CT2_CLVLDB,   CT2_CLVLCR, CT2_EMPORI,  CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,"+CRLF
cCorpo += "                                   CT2_SEQHIS,   CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,    @cDoc,       @cLinha,    @cMoeda1,   @cDc,"+CRLF
cCorpo += "                                   @cContaDeb,   @cContaCrd, @nValor1,    @cHist,       @cCustoDeb,  @cCustoCrd, @cItemDeb,  @cItemCrd,"+CRLF
cCorpo += "                                   @cClvlDeb,    @cClvlCrd,  @IN_EMPORI,  @cFilial_CQ7, @IN_TPSALDO, @cManual,   @cRotina,   @cAglut,"+CRLF
cCorpo += "                                   @cSeqHis,     @cSeqLan,   @cCrConv,    @iRecno )"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Select @nValor = Round( @nValor, 2)"+CRLF
cCorpo += "            Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "            Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "            Select @cCrConv   = '4'"+CRLF
cCorpo += "            Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE,   CT2_DOC,     CT2_LINHA,  CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,     CT2_CCD,     CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,"+CRLF
cCorpo += "                                CT2_CLVLDB,   CT2_CLVLCR, CT2_EMPORI,  CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,"+CRLF
cCorpo += "                                CT2_SEQHIS,   CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                        Values (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,    @cDoc,       @cLinha,    @cMoeda,    @cDc,"+CRLF
cCorpo += "                                @cContaDeb,   @cContaCrd, @nValor,     @cHist,       @cCustoDeb,  @cCustoCrd, @cItemDeb,  @cItemCrd,"+CRLF
cCorpo += "                                @cClvlDeb,    @cClvlCrd,  @IN_EMPORI,  @cFilial_CQ7, @IN_TPSALDO, @cManual,   @cRotina,   @cAglut,"+CRLF
cCorpo += "                                @cSeqHis,     @cSeqLan,   @cCrConv,    @iRecno )"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "      select @cMoedaAnt = @cMoeda"+CRLF
cCorpo += "      select @cDataAnt  = @cData"+CRLF
cCorpo += "      select @cContaAnt = @cConta"+CRLF
cCorpo += "      select @cCustoAnt = @cCusto"+CRLF
cCorpo += "      select @cItemAnt  = @cItem"+CRLF
cCorpo += "      select @cClvlAnt  = @cClvl"+CRLF
cCorpo += "      select @cFilAnt   = @cFilial_CQ7"+CRLF
/* ------------------------------------------------------------------------------------------------------
   Tratamento para o DB2
   ------------------------------------------------------------------------------------------------------ */
If Trim(TcGetDb()) = 'DB2'
	cCorpo += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cCorpo += "      Fetch CUR_Ctb220CQ7 into @cFilial_CQ7, @cMoeda, @cData, @cConta, @cCusto, @cItem, @cClvl, @nDebito, @nCredit"+CRLF
      /*   saldo na moeda 1 zerado e na 2 nao zerado */
cCorpo += "      If ( @cFilial_CQ7  != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt  != @cCusto or @cItemAnt != @cItem or @cClvlAnt != @cClvl ) begin"+CRLF
cCorpo += "         select @lPrim = '1'"+CRLF
cCorpo += "      end"+CRLF
cCorpo += "   End"+CRLF
cCorpo += "   Close CUR_Ctb220CQ7"+CRLF
cCorpo += "   Deallocate CUR_Ctb220CQ7"+CRLF
cCorpo += "   Select @OUT_LOTE = @cLote"+CRLF
cCorpo += "   Select @OUT_DOC = @cDoc"+CRLF
cCorpo += "   select @OUT_CONT = @iContador"+CRLF
cCorpo += "End "+CRLF

cQuery := cParam+cDeclare+cCorpo
cQuery := MsParse(cQuery,Alltrim(TcGetDB()))
cQuery := CtbAjustaP(.F., cQuery)
Return (cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220CQ5  ³ Autor  ³ Alice Y. Yamamoto       ³ Data 08.03.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria procedure p geracao de lactos de saldos inciais do CQ5 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220CQ5(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpresas )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³cQuery -> procedure de geracao de lactos de slds iniciais CQ5³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmp     - empresa que tera os dados consolidados   ³±±
±±³           ³ ExpC2 = cCT2Dest - CT2 destino. Os dados serao consolidados ³±±
±±³           ³ ExpC3 = cCTFDest - CTF destino. Os dados serao consolidados ³±±
±±³           ³ ExpC4 = cTabela  - Tabela(CQ5)que sera os consolidada       ³±±
±±³           ³ ExpA1 = aEmpresas- Array com as empresas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220CQ5(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpresas, cArray )
Local cParam   := ""
Local cDeclare := ""
Local cCorpo   := ""
Local cQuery   := ""
Local aCampos  := CT2->(DbStruct())
Local cTabCQ7
Local nPos
Local cTipo
Local cINAux
Local cFiliais
Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local cXFILIAL  :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "XFILIAL_03", "XFILIAL" ))
Local cMSSTRZERO:=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSTRZERO_03"+"_"+cEmpAnt, "MSSTRZERO")
Local cMSSOMA1  :=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSOMA1_03"+"_"+cEmpAnt, "MSSOMA1")

cINAux   := "#"+cEmp
cFiliais := CTB220FilIn(cInAux, cArray)

aEmpCQ7 := Ctb220aEmp(aEmpresas, "CQ7")
nPos    := Ascan( aEmpCQ7, {|x| Alltrim(x[1]) == cEmp } )
cTabCQ7 := aEmpCQ7[nPos][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procedure =>cQuery = cParam+cDeclare+cCorpo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada - cParam                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cParam := " Create Procedure CTB220CQ5_"+cEmpAnt+CRLF
cParam += "(" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_EMPORI" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_EMPORI       "+cTipo+CRLF  // empresa ORIGEM DOS LANCTOS
cParam += "  @IN_FILIALDEST   Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )," +CRLF  // filial destino sm0->m0_codfil
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_TPSALDO      "+cTipo+CRLF
cParam += "  @IN_DATA         Char( 08 )," +CRLF
cParam += "  @IN_LMOEDAESP    Char( 01 )," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_MOEDA        "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_LOTE         "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_SUBLOTE      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_DOC          "+cTipo+CRLF
cParam += "  @IN_MAXLINHA     Integer," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_LOTE        "+cTipo+" OutPut," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_DOC         "+cTipo+" OutPut, " +CRLF
cParam += "  @OUT_CONT        Integer    OutPut " +CRLF
cParam += ")"+CRLF
cParam += "as "+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis da Procedure - cDeclare                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDeclare := "Declare @cFilial_CT2 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CTF Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ7 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ5 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilAnt     Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cData       Char( 08 )" +CRLF
cDeclare += "Declare @cDataAnt    Char( 08 )" +CRLF
cDeclare += "Declare @cAux1       Char( 01 )" +CRLF
cDeclare += "Declare @cAux        Char( 03 )" +CRLF
cDeclare += "Declare @lPrim       Char( 01 )" +CRLF
cDeclare += "Declare @cDc         Char( 01 )" +CRLF
cDeclare += "Declare @cManual     Char( 01 )" +CRLF
cDeclare += "Declare @cRotina     VarChar( 10 )" +CRLF
cDeclare += "Declare @cAglut      Char( 01 )" +CRLF
cDeclare += "Declare @cCrConv     Char( 01 )" +CRLF
cDeclare += "Declare @iRecno      integer" +CRLF
cDeclare += "Declare @iRecnoCTF   integer" +CRLF
cDeclare += "Declare @iMaxLinha   integer" +CRLF
cDeclare += "Declare @iLinha      integer" +CRLF
cDeclare += "Declare @iAux        integer" +CRLF
cDeclare += "Declare @iContador   integer" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSubLote    "+cTipo+CRLF
/* Crio com tamanho das variaveis de acordo com a estrutura do CT2*/
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_HIST" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cHist     "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQHIS" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqHis   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQLAN" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqLan   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cDoc      "+ cTipo+CRLF
cDeclare += "Declare @cDocAux   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLote     "+ cTipo+CRLF
cDeclare += "Declare @cLoteAux  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DEBITO" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cConta    "+ cTipo+CRLF
cDeclare += "Declare @cContaDeb "+ cTipo+CRLF
cDeclare += "Declare @cContaCrd "+ cTipo+CRLF
cDeclare += "Declare @cContaAnt "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CCD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cCusto    "+ cTipo+CRLF
cDeclare += "Declare @cCustoDeb "+ cTipo+CRLF
cDeclare += "Declare @cCustoCrd "+ cTipo+CRLF
cDeclare += "Declare @cCustoAnt "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ITEMD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cItem     "+ cTipo+CRLF
cDeclare += "Declare @cItemDeb  "+ cTipo+CRLF
cDeclare += "Declare @cItemCrd  "+ cTipo+CRLF
cDeclare += "Declare @cItemAnt  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cMoeda    "+ cTipo+CRLF
cDeclare += "Declare @cMoeda1   "+ cTipo+CRLF
cDeclare += "Declare @cMoedaAnt "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLinha    "+ cTipo+CRLF
cDeclare += "Declare @cLinhaAux "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_VALOR" } )
cTipo := " Float"
cDeclare += "Declare @nValor     "+cTipo+CRLF
cDeclare += "Declare @nValor1    "+cTipo+CRLF
cDeclare += "Declare @nDebito    "+cTipo+CRLF
cDeclare += "Declare @nCredit    "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ7 "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ7 "+cTipo+CRLF
cDeclare += "Declare @nTotDeb    "+cTipo+CRLF
cDeclare += "Declare @nTotCrd    "+cTipo+CRLF
cDeclare += "Declare @iLinha1 Integer"+CRLF
cDeclare += "Declare @lCriaLinha Char(01)"+CRLF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corpo da Procedure                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpo := "begin"+CRLF 
cCorpo += "   Select @cLote     = @IN_LOTE"+CRLF
cCorpo += "   Select @cSubLote  = @IN_SUBLOTE"+CRLF
cCorpo += "   Select @cDoc      = @IN_DOC"+CRLF
cCorpo += "   Select @iRecno    = 0"+CRLF
cCorpo += "   Select @iRecnoCTF = 0"+CRLF
cCorpo += "   Select @iLinha    = 1"+CRLF
cCorpo += "   Select @iContador = 0"+CRLF
cCorpo += "   Select @cLinha    = '000'"+CRLF
cCorpo += "   Select @cLinhaAux = '000'"+CRLF
cCorpo += "   Select @cAux1     = '0'"+CRLF
cCorpo += "   select @cMoedaAnt = ' '"+CRLF
cCorpo += "   select @cDataAnt  = ' '"+CRLF
cCorpo += "   select @cContaAnt = ' '"+CRLF
cCorpo += "   select @cCustoAnt = ' '"+CRLF
cCorpo += "   select @cItemAnt  = ' '"+CRLF
cCorpo += "   select @lPrim     = '1'"+CRLF
cCorpo += "   Select @cHist     = 'Saldo Inicial'"+CRLF
cCorpo += "   Select @cManual   = '1'"+CRLF
cCorpo += "   Select @cRotina   = 'CTBA101'"+CRLF
cCorpo += "   Select @cAglut    = '2'"+CRLF
cCorpo += "   Select @cSeqHis   = '001'"+CRLF
cCorpo += "   Select @cSeqLan   = ''"+CRLF
cCorpo += "   Select @cCrConv   = '4'"+CRLF
cCorpo += "   Select @iMaxLinha = @IN_MAXLINHA"+CRLF
cCorpo += "   select @nValor    = 0"+CRLF
cCorpo += "   Select @iAux      = 0"+CRLF
cCorpo += "   Select @OUT_LOTE  = ''"+CRLF
cCorpo += "   select @OUT_DOC   = ''"+CRLF
cCorpo += "   select @OUT_CONT  = @iContador"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   select @cAux      = 'CT2'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CT2 OutPut"+CRLF
cCorpo += "   select @cAux      = 'CTF'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CTF OutPut"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   Declare CUR_CTB220CQ5 insensitive cursor  for"+CRLF
cCorpo += "   Select CQ5_FILIAL, CQ5_MOEDA, CQ5_DATA, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, Sum(CQ5_DEBITO), Sum(CQ5_CREDIT)"+CRLF
cCorpo += "       From "+cTabela+" A"+CRLF
cCorpo += "      Where D_E_L_E_T_ = ' '"+CRLF
If Substr(cFiliais,3,1) = " "
	cCorpo += "        and CQ5_FILIAL = '  '"+CRLF
Else
	cCorpo += "        and CQ5_FILIAL IN "+cFiliais+CRLF
EndIf
// PASSO2
cCorpo += "        and CQ5_DATA  <= @IN_DATA"+CRLF
cCorpo += "        and CQ5_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "        and CQ5_LP    != 'S'"+CRLF 
cCorpo += "        and ( (CQ5_MOEDA  = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )"+CRLF
cCorpo += "   Group By CQ5_FILIAL, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_DATA, CQ5_MOEDA"+CRLF
cCorpo += "   Order By 1, 4, 5, 6, 3, 2"+CRLF
cCorpo += "   For read only"+CRLF

cCorpo += "   Open CUR_CTB220CQ5"+CRLF
cCorpo += "   Fetch CUR_CTB220CQ5 into @cFilial_CQ5, @cMoeda, @cData, @cConta, @cCusto, @cItem, @nDebito, @nCredit"+CRLF
cCorpo += CRLF
cCorpo += "   While ( @@fetch_status = 0 ) begin"+CRLF
cCorpo += "      select @cAux      = 'CQ7'"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @cFilial_CQ5, @cFilial_CQ7 OutPut"+CRLF
/* ---------------------------------------------------------------------------------------
	Verifico qto foi lancado no CQ7 na CONTA+CCUSTO+ITEM . Nao importa o item
   --------------------------------------------------------------------------------------- */
// PASSO3
cCorpo += "      select @nDebitoCQ7 = 0"+CRLF
cCorpo += "      select @nCreditCQ7 = 0"+CRLF
cCorpo += "      select @nTotDeb = 0"+CRLF
cCorpo += "      select @nTotCrd = 0"+CRLF
cCorpo += "      Select @nDebitoCQ7 = IsNull( Sum(CQ7_DEBITO), 0 ), @nCreditCQ7 = IsNull( Sum(CQ7_CREDIT), 0 )"+CRLF
cCorpo += "        From "+cTabCQ7+ " B"+CRLF
cCorpo += "       Where CQ7_FILIAL = @cFilial_CQ7"+CRLF
cCorpo += "         and CQ7_CONTA  = @cConta"+CRLF
cCorpo += "         and CQ7_CCUSTO = @cCusto"+CRLF
cCorpo += "         and CQ7_ITEM   = @cItem"+CRLF
cCorpo += "         and CQ7_MOEDA  = @cMoeda"+CRLF
cCorpo += "         and CQ7_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "         and CQ7_LP    != 'S'"+CRLF
cCorpo += "         and CQ7_DATA   = @cData"+CRLF
cCorpo += "         and D_E_L_E_T_ = ' '"+CRLF
// --                       VLRS DO CQ5           -     VLRS DO CQ7       
cCorpo += "      select @nTotDeb = @nTotDeb + ( @nDebito - @nDebitoCQ7 )"+CRLF
cCorpo += "      select @nTotCrd = @nTotCrd + ( @nCredit - @nCreditCQ7 )"+CRLF
cCorpo += "      Select @nValor  = ( @nTotCrd - @nTotDeb )"+CRLF
cCorpo += "      select @iLinha1 = 1"+CRLF
      /*   @lCrialinha = '1' gerar CT2 */
cCorpo += "      select @lCriaLinha = '1'"+CRLF
cCorpo += "      While @iLinha1 < 3 begin"+CRLF
cCorpo += "         If ( Round(@nTotCrd, 2)  = Round(@nTotDeb, 2) ) and ( Round(@nTotCrd, 2) != 0 or Round(@nTotDeb, 2) != 0 ) begin"+CRLF
cCorpo += "            If @iLinha1 = 1 begin"+CRLF
cCorpo += "               Select @nValor = @nTotCrd"+CRLF
cCorpo += "               select @iLinha1 = 2"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               If @iLinha1 = 2 begin"+CRLF
cCorpo += "                  Select @nValor = ( 0 - @nTotDeb )"+CRLF
cCorpo += "                  select @iLinha1 = 3"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            select @lPrim = '1' "+CRLF
cCorpo += "            select @lCriaLinha = '1'"+CRLF
cCorpo += "         end else begin"+CRLF
cCorpo += "            If Round(@nValor, 2) != 0 begin"+CRLF
cCorpo += "               select @lCriaLinha = '1'"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               select @lCriaLinha = '0'"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            select @iLinha1 = 3"+CRLF
cCorpo += "         end"+CRLF
cCorpo += "         If @lCriaLinha = '1' begin"+CRLF
cCorpo += "            select @iContador = 1 "+CRLF
/* ---------------------------------------------------------------------------------------
   Somo um no Documento Qdo mudar de filial e qdo a Linha for maxlinha
   --------------------------------------------------------------------------------------- */
cCorpo += "            If ( @cFilial_CQ5 != @cFilAnt and (@cFilAnt is not null) ) begin"+CRLF
cCorpo += "               If @cDoc = '999999' begin"+CRLF
cCorpo += "                  select @cAux1     = '0'"+CRLF
cCorpo += "                  select @cLoteAux  = @cLote"+CRLF
cCorpo += "                  Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                  select @cDoc = '000000'"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "               select @iLinha = 1"+CRLF
cCorpo += "               select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "               exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "               select @cAux1     = '0'"+CRLF
cCorpo += "               select @cDocAux   = @cDoc"+CRLF
cCorpo += "               Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               If @IN_LMOEDAESP = '1' begin"+CRLF
cCorpo += "                  If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                     If @cDoc = '999999' begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLoteAux  = @cLote"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                        select @cDoc = '000000'"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                     select @iLinha = 1"+CRLF
cCorpo += "                     select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                     exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                     select @cDocAux   = @cDoc"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                  end else begin"+CRLF
cCorpo += "                     select @cAux1     = '0'"+CRLF
cCorpo += "                     select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                     select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End else begin"+CRLF
/* ---------------------------------------------------------------------------------------
   Qdo a moeda nao e'especifica gero a proxima linha somente qdo a moeda for diferente
   --------------------------------------------------------------------------------------- */
cCorpo += "                  If ( @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cItemAnt != @cItem) or @lPrim  = '1' begin"+CRLF
cCorpo += "                     select @lPrim = '0'"+CRLF
cCorpo += "                     If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                        If @cDoc = '999999' begin"+CRLF
cCorpo += "                           select @cAux1     = '0'"+CRLF
cCorpo += "                           select @cLoteAux  = @cLote"+CRLF
cCorpo += "                           Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                           select @cDoc = '000000'"+CRLF
cCorpo += "                        End"+CRLF
cCorpo += "                        select @iLinha = 1"+CRLF
cCorpo += "                        select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                        exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                        select @cDocAux   = @cDoc"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                     end else begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                        select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
/* ---------------------------------------------------------------------------------------
   Valor, ct2_dc, cta débito e credito  a Gravar
   --------------------------------------------------------------------------------------- */
cCorpo += "            Select @cSeqLan = @cLinha"+CRLF
cCorpo += "            If @nValor < 0 begin"+CRLF
/* ---------------------------------------------
   Lanca a Débito
   --------------------------------------------- */
cCorpo += "               Select @cDc = '1'"+CRLF
cCorpo += "               Select @cContaDeb = @cConta"+CRLF
cCorpo += "               Select @cContaCrd = ' '"+CRLF
cCorpo += "               Select @cCustoDeb = @cCusto"+CRLF
cCorpo += "               Select @cCustoCrd = ' '"+CRLF
cCorpo += "               Select @cItemDeb  = @cItem"+CRLF
cCorpo += "               Select @cItemCrd  = ' '"+CRLF
cCorpo += "               Select @nValor    = @nValor * ( -1 )"+CRLF
cCorpo += "            end else begin"+CRLF
/* ---------------------------------------------
   Lanca a Credito
   --------------------------------------------- */
cCorpo += "               Select @cDc = '2'"+CRLF
cCorpo += "               Select @cContaDeb = ' '"+CRLF
cCorpo += "               Select @cContaCrd = @cConta"+CRLF
cCorpo += "               Select @cCustoDeb = ' '"+CRLF
cCorpo += "               Select @cCustoCrd = @cCusto"+CRLF
cCorpo += "               Select @cItemDeb  = ' '"+CRLF
cCorpo += "               Select @cItemCrd  = @cItem"+CRLF
cCorpo += "            end"+CRLF
/* insercao na tabela destino CT2  */
/* ----------------------------------------------------------------------------
   Atualizao CTF
   ---------------------------------------------------------------------------- */
cCorpo += "            Select @iRecnoCTF = R_E_C_N_O_"+CRLF
cCorpo += "              From "+cCTFDest+CRLF
cCorpo += "             Where CTF_FILIAL = @cFilial_CTF"+CRLF
cCorpo += "               and CTF_DATA   = @IN_DATA"+CRLF
cCorpo += "               and CTF_LOTE   = @cLote"+CRLF
cCorpo += "               and CTF_SBLOTE = @cSubLote"+CRLF
cCorpo += "               and CTF_DOC    = @cDoc"+CRLF
cCorpo += "               and D_E_L_E_T_ = ' '"+CRLF
cCorpo += CRLF
cCorpo += "            If @iRecnoCTF is null begin "+CRLF
cCorpo += "               Select @iRecnoCTF = IsNull(Max( R_E_C_N_O_), 0) From "+cCTFDest+CRLF
cCorpo += "               Select @iRecnoCTF = @iRecnoCTF + 1"+CRLF
cCorpo += "               Insert into "+cCTFDest+" ( CTF_FILIAL,   CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values ( @cFilial_CTF, @IN_DATA, @cLote,   @cSubLote,  @cDoc,   @cLinha,   @iRecnoCTF )"+CRLF
cCorpo += CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update "+cCTFDest+CRLF
cCorpo += "               Set CTF_LINHA = @cLinha"+CRLF
cCorpo += "               Where R_E_C_N_O_ = @iRecnoCTF"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            If @IN_LMOEDAESP = '1' and @IN_MOEDA != '01' begin"+CRLF
cCorpo += "               Select @cMoeda1 = '01'"+CRLF
cCorpo += "               Select @nValor1 = 0"+CRLF
cCorpo += "               Select @cCrConv   = '5'"+CRLF
cCorpo += "               Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "               Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "               Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,     CT2_LOTE,    CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                   CT2_DEBITO,   CT2_CREDIT,   CT2_VALOR,   CT2_HIST,   CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,"+CRLF
cCorpo += "                                   CT2_EMPORI,   CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,"+CRLF
cCorpo += "                                   CT2_SEQHIS,   CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values (@cFilial_CT2, @IN_DATA,     @cLote,      @cSubLote,  @cDoc,      @cLinha,    @cMoeda1,   @cDc,"+CRLF
cCorpo += "                                   @cContaDeb,   @cContaCrd,   @nValor1,    @cHist,     @cCustoDeb, @cCustoCrd, @cItemDeb,  @cItemCrd,"+CRLF
cCorpo += "                                   @IN_EMPORI,   @cFilial_CQ5, @IN_TPSALDO, @cManual,   @cRotina,   @cAglut,"+CRLF
cCorpo += "                                   @cSeqHis,     @cSeqLan,     @cCrConv,    @iRecno )"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Select @nValor = Round( @nValor, 2)"+CRLF
cCorpo += "            Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "            Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "            Select @cCrConv   = '4'"+CRLF
cCorpo += "            Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,     CT2_LOTE,    CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                CT2_DEBITO,   CT2_CREDIT,   CT2_VALOR,   CT2_HIST,   CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,"+CRLF
cCorpo += "                                CT2_EMPORI,   CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,"+CRLF
cCorpo += "                                CT2_SEQHIS,   CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                        Values (@cFilial_CT2, @IN_DATA,     @cLote,      @cSubLote,  @cDoc,      @cLinha,    @cMoeda,    @cDc,"+CRLF
cCorpo += "                                @cContaDeb,   @cContaCrd,   @nValor,     @cHist,     @cCustoDeb, @cCustoCrd, @cItemDeb,  @cItemCrd,"+CRLF
cCorpo += "                                @IN_EMPORI,   @cFilial_CQ5, @IN_TPSALDO, @cManual,   @cRotina,   @cAglut,"+CRLF
cCorpo += "                                @cSeqHis,     @cSeqLan,     @cCrConv,    @iRecno )"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "      select @cMoedaAnt = @cMoeda"+CRLF
cCorpo += "      select @cDataAnt  = @cData"+CRLF
cCorpo += "      select @cContaAnt = @cConta"+CRLF
cCorpo += "      select @cCustoAnt = @cCusto"+CRLF
cCorpo += "      select @cItemAnt  = @cItem"+CRLF
cCorpo += "      select @cFilAnt   = @cFilial_CQ5"+CRLF
/* ------------------------------------------------------------------------------------------------------
   Tratamento para o DB2
   ------------------------------------------------------------------------------------------------------ */
If Trim(TcGetDb()) = 'DB2'
	cCorpo += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cCorpo += "      Fetch CUR_CTB220CQ5 into @cFilial_CQ5, @cMoeda, @cData, @cConta, @cCusto, @cItem, @nDebito, @nCredit"+CRLF
      /*   saldo na moeda 1 zerado e na 2 nao zerado */
cCorpo += "      If ( @cFilial_CQ5 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cItemAnt != @cItem) begin"+CRLF
cCorpo += "         select @lPrim  = '1'"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "   End"+CRLF
cCorpo += "   Close CUR_CTB220CQ5"+CRLF
cCorpo += "   Deallocate CUR_CTB220CQ5"+CRLF
cCorpo += CRLF
cCorpo += "   Select @OUT_LOTE = @cLote"+CRLF
cCorpo += "   Select @OUT_DOC = @cDoc"+CRLF
cCorpo += "   select @OUT_CONT = @iContador"+CRLF
cCorpo += "End "+CRLF


cQuery := cParam+cDeclare+cCorpo
cQuery := MsParse(cQuery,Alltrim(TcGetDB()))
cQuery := CtbAjustaP(.F., cQuery)

Return (cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220CQ3  ³ Autor  ³ Alice Y. Yamamoto       ³ Data 08.03.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria procedure p geracao de lactos de saldos inciais do CQ3 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220CQ3(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpresas )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³cQuery -> procedure de geracao de lactos de slds iniciais CQ3³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmp     - empresa que tera os dados consolidados   ³±±
±±³           ³ ExpC2 = cCT2Dest - CT2 destino. Os dados serao consolidados ³±±
±±³           ³ ExpC3 = cCTFDest - CTF destino. Os dados serao consolidados ³±±
±±³           ³ ExpC4 = cTabela  - Tabela(CQ3)que sera os consolidada       ³±±
±±³           ³ ExpA1 = aEmpresas- Array com as empresas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220CQ3(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpresas, cArray)
Local cParam   := ""
Local cDeclare := ""
Local cCorpo   := ""
Local cQuery   := ""
Local aCampos  := CT2->(DbStruct())
Local cTabCQ7
Local cTabCQ5
Local aEmpTab
Local nPos
Local cINAux
Local cFiliais  // filiais a serem cosolidadas
Local cTipo
Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local cXFILIAL  :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "XFILIAL_03", "XFILIAL" ))
Local cMSSTRZERO:=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSTRZERO_03"+"_"+cEmpAnt, "MSSTRZERO")
Local cMSSOMA1  :=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSOMA1_03"+"_"+cEmpAnt, "MSSOMA1")
cINAux   := "#"+cEmp
cFiliais := CTB220FilIn(cInAux, cArray)

aEmpTab := Ctb220aEmp(aEmpresas, "CQ7")
nPos    := Ascan( aEmpTab, {|x| Alltrim(x[1]) == cEmp } )
cTabCQ7 := aEmpTab[nPos][2]

aEmpTab := Ctb220aEmp(aEmpresas, "CQ5")
nPos    := Ascan( aEmpTab, {|x| Alltrim(x[1]) == cEmp } )
cTabCQ5 := aEmpTab[nPos][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procedure =>cQuery = cParam+cDeclare+cCorpo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada - cParam                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cParam := " Create Procedure CTB220CQ3_"+cEmpAnt+CRLF
cParam += "(" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_EMPORI" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_EMPORI       "+cTipo+CRLF  // empresa origem dos lancamentos
cParam += "  @IN_FILIALDEST   Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )," +CRLF  // filial destino sm0->m0_codfil
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_TPSALDO      "+cTipo+CRLF
cParam += "  @IN_DATA         Char( 08 )," +CRLF
cParam += "  @IN_LMOEDAESP    Char( 01 )," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_MOEDA        "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_LOTE         "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_SUBLOTE      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_DOC          "+cTipo+CRLF
cParam += "  @IN_MAXLINHA     Integer," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_LOTE        "+cTipo+" OutPut," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_DOC         "+cTipo+" OutPut, " +CRLF
cParam += "  @OUT_CONT        Integer    OutPut " +CRLF
cParam += ")"+CRLF
cParam += "as "+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis da Procedure - cDeclare                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDeclare := "Declare @cFilial_CT2 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ3 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ5 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CTF Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ7 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilAnt     Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cData       Char( 08 )" +CRLF
cDeclare += "Declare @cDataAnt    Char( 08 )" +CRLF
cDeclare += "Declare @cAux1       Char( 01 )" +CRLF
cDeclare += "Declare @cAux        Char( 03 )" +CRLF
cDeclare += "Declare @lPrim       Char( 01 )" +CRLF
cDeclare += "Declare @cDc         Char( 01 )" +CRLF
cDeclare += "Declare @cManual     Char( 01 )" +CRLF
cDeclare += "Declare @cRotina     VarChar( 10 )" +CRLF
cDeclare += "Declare @cAglut      Char( 01 )" +CRLF
cDeclare += "Declare @cCrConv     Char( 01 )" +CRLF
cDeclare += "Declare @iRecno      integer" +CRLF
cDeclare += "Declare @iRecnoCTF   integer" +CRLF
cDeclare += "Declare @iMaxLinha   integer" +CRLF
cDeclare += "Declare @iLinha      integer" +CRLF
cDeclare += "Declare @iAux        integer" +CRLF
cDeclare += "Declare @iContador   integer" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSubLote    "+cTipo+CRLF
/* Crio com tamanho das variaveis de acordo com a estrutura do CT2*/
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_HIST" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cHist     "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQHIS" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqHis   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQLAN" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqLan   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cDoc      "+ cTipo+CRLF
cDeclare += "Declare @cDocAux   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLote     "+ cTipo+CRLF
cDeclare += "Declare @cLoteAux  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DEBITO" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cConta    "+ cTipo+CRLF
cDeclare += "Declare @cContaDeb "+ cTipo+CRLF
cDeclare += "Declare @cContaCrd "+ cTipo+CRLF
cDeclare += "Declare @cContaAnt "+ cTipo+CRLF
cDeclare += "Declare @cContaCQ5 "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CCD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cCusto    "+ cTipo+CRLF
cDeclare += "Declare @cCustoDeb "+ cTipo+CRLF
cDeclare += "Declare @cCustoCrd "+ cTipo+CRLF
cDeclare += "Declare @cCustoAnt "+ cTipo+CRLF
cDeclare += "Declare @cCustoCQ5 "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ITEMD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cItemCQ5  "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cMoeda    "+ cTipo+CRLF
cDeclare += "Declare @cMoeda1   "+ cTipo+CRLF
cDeclare += "Declare @cMoedaAnt "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLinha    "+ cTipo+CRLF
cDeclare += "Declare @cLinhaAux "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_VALOR" } )
cTipo := " Decimal( "+StrZero(aCampos[nPos][3],3)+","+StrZero(aCampos[nPos][4],2)+" )"
cDeclare += "Declare @nValor     "+cTipo+CRLF
cDeclare += "Declare @nValor1    "+cTipo+CRLF  
cDeclare += "Declare @nValorDeb  "+cTipo+CRLF  
cDeclare += "Declare @nValorCrd  "+cTipo+CRLF  
cDeclare += "Declare @nDebito    "+cTipo+CRLF
cDeclare += "Declare @nCredit    "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ7 "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ7 "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ5 "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ5 "+cTipo+CRLF
cDeclare += "Declare @nAuxDebCQ5 "+cTipo+CRLF
cDeclare += "Declare @nAuxCrdCQ5 "+cTipo+CRLF
cDeclare += "Declare @nTotDeb    "+cTipo+CRLF
cDeclare += "Declare @nTotCrd    "+cTipo+CRLF
cDeclare += "Declare @iLinha1     Integer"+CRLF
cDeclare += "Declare @lCriaLinha  Char(01)"+CRLF
cDeclare += CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corpo da Procedure                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpo := "begin"+CRLF 
cCorpo += "   Select @cLote     = @IN_LOTE"+CRLF
cCorpo += "   Select @cSubLote  = @IN_SUBLOTE"+CRLF
cCorpo += "   Select @cDoc      = @IN_DOC"+CRLF
cCorpo += "   Select @iRecno    = 0"+CRLF
cCorpo += "   Select @iRecnoCTF = 0"+CRLF
cCorpo += "   Select @iLinha    = 1"+CRLF
cCorpo += "   Select @iContador = 0"+CRLF
cCorpo += "   Select @cLinha    = '000'"+CRLF
cCorpo += "   Select @cLinhaAux = '000'"+CRLF
cCorpo += "   Select @cAux1     = '0'"+CRLF
cCorpo += "   select @cMoedaAnt = ' '"+CRLF
cCorpo += "   select @cDataAnt  = ' '"+CRLF
cCorpo += "   select @cContaAnt = ' '"+CRLF
cCorpo += "   select @cCustoAnt = ' '"+CRLF
cCorpo += "   select @lPrim     = '1'"+CRLF
cCorpo += "   Select @cHist     = 'Saldo Inicial'"+CRLF
cCorpo += "   Select @cManual   = '1'"+CRLF
cCorpo += "   Select @cRotina   = 'CTBA101'"+CRLF
cCorpo += "   Select @cAglut    = '2'"+CRLF
cCorpo += "   Select @cSeqHis   = '001'"+CRLF
cCorpo += "   Select @cSeqLan   = ''"+CRLF
cCorpo += "   Select @cCrConv   = '4'"+CRLF
cCorpo += "   Select @iMaxLinha = @IN_MAXLINHA"+CRLF
cCorpo += "   select @nValor    = 0"+CRLF
cCorpo += "   Select @iAux      = 0"+CRLF
cCorpo += "   Select @nTotDeb   = 0"+CRLF
cCorpo += "   Select @nTotCrd   = 0"+CRLF
cCorpo += "   Select @OUT_LOTE  = ''"+CRLF
cCorpo += "   select @OUT_DOC   = ''"+CRLF
cCorpo += "   select @OUT_CONT  = @iContador"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   select @cAux      = 'CT2'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CT2 OutPut"+CRLF
cCorpo += "   select @cAux      = 'CTF'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CTF OutPut"+CRLF
cCorpo += CRLF
/* Valor no Centro Custo     = A
   Total da Classe de valor  = B
   Total do Item             = C
   @nValor = A - B - C
   @nValor = ( @nCredit - @nDebito ) - ( @nCreditCQ7 - @nDebitoCQ7 ) - @nValorAux  */
cCorpo += "   Declare CUR_CTB220CQ3 insensitive cursor  for"+CRLF
cCorpo += "   Select CQ3_FILIAL, CQ3_MOEDA, CQ3_DATA, CQ3_CONTA, CQ3_CCUSTO, Sum(CQ3_DEBITO),Sum(CQ3_CREDIT)"+CRLF
cCorpo += "       From "+cTabela+" A"+CRLF
cCorpo += "      Where D_E_L_E_T_ = ' '"+CRLF
If Substr(cFiliais,3,1) = " "
	cCorpo += "        and CQ3_FILIAL = '  '"+CRLF
Else
	cCorpo += "        and CQ3_FILIAL IN "+cFiliais+CRLF
EndIf
// PASSO4
cCorpo += "        and CQ3_DATA  <= @IN_DATA"+CRLF
cCorpo += "        and CQ3_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "        and CQ3_LP    != 'S'"+CRLF
cCorpo += "        and ( (CQ3_MOEDA  = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )"+CRLF
cCorpo += "   Group By CQ3_FILIAL, CQ3_CONTA, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA"+CRLF
cCorpo += "   Order By 1, 4, 5, 2, 3"+CRLF
cCorpo += "   For read only"+CRLF
cCorpo += "   Open CUR_CTB220CQ3"+CRLF
cCorpo += "   Fetch CUR_CTB220CQ3 into @cFilial_CQ3, @cMoeda, @cData, @cConta, @cCusto, @nDebito, @nCredit"+CRLF
cCorpo += CRLF
cCorpo += "   While ( @@fetch_status = 0 ) begin"+CRLF
cCorpo += "      select @cAux      = 'CQ7'"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @cFilial_CQ3, @cFilial_CQ7 OutPut"+CRLF
cCorpo += "      select @cAux      = 'CQ5'"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @cFilial_CQ3, @cFilial_CQ5 OutPut"+CRLF
/* ---------------------------------------------------------------------------------------
   Somo um no Documento e qdo a Linha for maxlinha
   --------------------------------------------------------------------------------------- */
//--    verifico qto foi lancado no CQ7 sem o ITEM
cCorpo += "      Select @nTotDeb    = 0"+CRLF
cCorpo += "      Select @nTotCrd    = 0"+CRLF
cCorpo += "      select @nDebitoCQ7 = 0"+CRLF
cCorpo += "      select @nCreditCQ7 = 0"+CRLF
cCorpo += "      Select @nDebitoCQ5 = 0"+CRLF
cCorpo += "      Select @nCreditCQ5 = 0"+CRLF
cCorpo += "      Select @nAuxDebCQ5 = 0"+CRLF
cCorpo += "      Select @nAuxCrdCQ5 = 0"+CRLF
cCorpo += CRLF
// PASSO5  nao tem group by neste select sum
cCorpo += "      Select @nDebitoCQ7 = IsNull( Sum(CQ7_DEBITO), 0 ), @nCreditCQ7 = IsNull( Sum(CQ7_CREDIT), 0 )"+CRLF
cCorpo += "        From "+cTabCQ7+" B"+CRLF
cCorpo += "       Where D_E_L_E_T_ = ' '"+CRLF
cCorpo +="          and CQ7_FILIAL = @cFilial_CQ7"+CRLF
cCorpo += "         and CQ7_CONTA  = @cConta"+CRLF
cCorpo += "         and CQ7_CCUSTO = @cCusto"+CRLF
cCorpo += "         and CQ7_MOEDA  = @cMoeda"+CRLF
cCorpo += "         and CQ7_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "         and CQ7_DATA   = @cData"+CRLF
cCorpo += "         and CQ7_LP     != 'S'"+CRLF
cCorpo += CRLF
      /* 2 -  VERIFICO QTO JA FOI LANCADO NO CQ5 */
// PASSO6
cCorpo += "      Declare CUR_CTB220CQ5 insensitive cursor  for"+CRLF
cCorpo += "      Select CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, Sum(CQ5_DEBITO), Sum(CQ5_CREDIT)"+CRLF
cCorpo += "        From "+cTabCQ5+" C"+CRLF
cCorpo += "       Where D_E_L_E_T_ = ' '"+CRLF
cCorpo += "         and CQ5_FILIAL = @cFilial_CQ5"+CRLF
cCorpo += "         and CQ5_CONTA  = @cConta"+CRLF
cCorpo += "         and CQ5_CCUSTO = @cCusto"+CRLF
cCorpo += "         and CQ5_MOEDA  = @cMoeda"+CRLF
cCorpo += "         and CQ5_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "         and CQ5_DATA   = @cData"+CRLF
cCorpo += "         and CQ5_LP    != 'S'"+CRLF
cCorpo += "      Group By CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM"+CRLF
cCorpo += "      Order By 1, 2, 3"+CRLF
cCorpo += "      For read only"+CRLF
cCorpo += "      Open CUR_CTB220CQ5"+CRLF
cCorpo += "      Fetch CUR_CTB220CQ5 into @cContaCQ5, @cCustoCQ5, @cItemCQ5, @nDebitoCQ5, @nCreditCQ5"+CRLF
cCorpo += CRLF
cCorpo += "      While ( @@fetch_status = 0 ) begin"+CRLF
         /*  O item no CQ5 AAAAAAAAAAAAAAAAQUI*/
cCorpo += "         Select @nValorDeb = 0"+CRLF
cCorpo += "         Select @nValorCrd = 0"+CRLF
// PASSO7
cCorpo += "         Select @nValorDeb = IsNull( Sum(CQ7_DEBITO), 0 ), @nValorCrd = IsNull( Sum(CQ7_CREDIT), 0 )"+CRLF
cCorpo += "           From " +cTabCQ7+" D"+CRLF
cCorpo += "          Where CQ7_FILIAL = @cFilial_CQ7"+CRLF
cCorpo += "            and CQ7_CONTA  = @cContaCQ5"+CRLF
cCorpo += "            and CQ7_CCUSTO = @cCustoCQ5"+CRLF
cCorpo += "            and CQ7_ITEM   = @cItemCQ5"+CRLF
cCorpo += "            and CQ7_MOEDA  = @cMoeda"+CRLF
cCorpo += "            and CQ7_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "            and CQ7_DATA   = @cData"+CRLF
cCorpo += "            and CQ7_LP    != 'S'"+CRLF
cCorpo += "            and D_E_L_E_T_ = ' '"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         Select @nAuxDebCQ5 = @nAuxDebCQ5 + (@nDebitoCQ5 - @nValorDeb)"+CRLF
cCorpo += "         Select @nAuxCrdCQ5 = @nAuxCrdCQ5 + (@nCreditCQ5 - @nValorCrd)"+CRLF
cCorpo += "         Fetch CUR_CTB220CQ5 into @cContaCQ5, @cCustoCQ5, @cItemCQ5, @nDebitoCQ5, @nCreditCQ5"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "      Close CUR_CTB220CQ5"+CRLF
cCorpo += "      Deallocate CUR_CTB220CQ5"+CRLF
cCorpo += CRLF
      /*  FIM DA VERIFICACAO - qto ja foi lancado no CQ5 */
      /*     Vlr lancar    Total do CCusto      -   Total da Calsse de Valor     - Total co Item   */
cCorpo += "      Select @nTotDeb   = @nTotDeb + ( @nDebito - @nDebitoCQ7 - @nAuxDebCQ5 )"+CRLF
cCorpo += "      Select @nTotCrd   = @nTotCrd + ( @nCredit - @nCreditCQ7 - @nAuxCrdCQ5 )"+CRLF
cCorpo += "      Select @nValor = ( @nTotCrd - @nTotDeb )"+CRLF
cCorpo += "      select @iLinha1 = 1"+CRLF
      /*   @lCrialinha = '1' gerar CT2 */
cCorpo += "      select @lCriaLinha = '1'"+CRLF
cCorpo += "      While @iLinha1 < 3 begin"+CRLF
cCorpo += "         If ( Round(@nTotCrd, 2)  = Round(@nTotDeb, 2) ) and ( Round(@nTotCrd, 2) != 0 or Round(@nTotDeb, 2) != 0 ) begin"+CRLF
cCorpo += "            If @iLinha1 = 1 begin"+CRLF
cCorpo += "               Select @nValor = @nTotCrd"+CRLF
cCorpo += "               select @iLinha1 = 2"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               If @iLinha1 = 2 begin"+CRLF
cCorpo += "                  Select @nValor = ( 0 - @nTotDeb )"+CRLF
cCorpo += "                  select @iLinha1 = 3"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            select @lPrim = '1'"+CRLF
cCorpo += "            select @lCriaLinha = '1'"+CRLF
cCorpo += "         end else begin"+CRLF
cCorpo += "            If Round(@nValor, 2) != 0 begin"+CRLF
cCorpo += "               select @lCriaLinha = '1'"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               select @lCriaLinha = '0'"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            select @iLinha1 = 3"+CRLF
cCorpo += "         end"+CRLF
cCorpo += "         If @lCriaLinha = '1' begin"+CRLF
cCorpo += "            select @iContador = 1"+CRLF
/* ---------------------------------------------------------------------------------------
   Somo um no Documento Qdo mudar de filial e qdo a Linha for maxlinha
   --------------------------------------------------------------------------------------- */
cCorpo += "            If ( @cFilial_CQ3 != @cFilAnt and (@cFilAnt is not null) ) begin"+CRLF
cCorpo += "               If @cDoc = '999999' begin"+CRLF
cCorpo += "                  select @cAux1     = '0'"+CRLF
cCorpo += "                  select @cLoteAux  = @cLote"+CRLF
cCorpo += "                  Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                  select @cDoc = '000000'"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "               select @iLinha = 1"+CRLF
cCorpo += "               select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "               exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "               select @cAux1     = '0'"+CRLF
cCorpo += "               select @cDocAux   = @cDoc"+CRLF
cCorpo += "               Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               If @IN_LMOEDAESP = '1' begin"+CRLF
cCorpo += "                  If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                     If @cDoc = '999999' begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLoteAux  = @cLote"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                        select @cDoc = '000000'"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                     select @iLinha = 1"+CRLF
cCorpo += "                     select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                     exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                     select @cDocAux   = @cDoc"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                  end else begin"+CRLF
cCorpo += "                     select @cAux1     = '0'"+CRLF
cCorpo += "                     select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                     select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End else begin"+CRLF
/* ---------------------------------------------------------------------------------------
   Qdo a moeda nao e'especifica gero a proxima linha somente qdo a moeda for diferente
   --------------------------------------------------------------------------------------- */
cCorpo += "                  If ( @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto ) or @lPrim  = '1' begin"+CRLF
cCorpo += "                     select @lPrim = '0'"+CRLF
cCorpo += "                     If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                        If @cDoc = '999999' begin"+CRLF
cCorpo += "                           select @cAux1     = '0'"+CRLF
cCorpo += "                           select @cLoteAux  = @cLote"+CRLF
cCorpo += "                           Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                           select @cDoc = '000000'"+CRLF
cCorpo += "                        End"+CRLF
cCorpo += "                        select @iLinha = 1"+CRLF
cCorpo += "                        select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                        exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                        select @cDocAux   = @cDoc"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                     end else begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                        select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
/* ---------------------------------------------------------------------------------------
   Valor, ct2_dc, cta débito e credito  a Gravar
   --------------------------------------------------------------------------------------- */
cCorpo += "            Select @cSeqLan = @cLinha"+CRLF
cCorpo += "            If @nValor < 0 begin"+CRLF
/* ---------------------------------------------
   Lanca a Débito
   --------------------------------------------- */
cCorpo += "               Select @cDc = '1'"+CRLF
cCorpo += "               Select @cContaDeb = @cConta"+CRLF
cCorpo += "               Select @cContaCrd = ' '"+CRLF
cCorpo += "               Select @cCustoDeb = @cCusto"+CRLF
cCorpo += "               Select @cCustoCrd = ' '"+CRLF
cCorpo += "               Select @nValor    = @nValor * ( -1 )"+CRLF
cCorpo += "            end else begin"+CRLF
/* ---------------------------------------------
   Lanca a Credito
   --------------------------------------------- */
cCorpo += "               Select @cDc = '2'"+CRLF
cCorpo += "               Select @cContaDeb = ' '"+CRLF
cCorpo += "               Select @cContaCrd = @cConta"+CRLF
cCorpo += "               Select @cCustoDeb = ' '"+CRLF
cCorpo += "               Select @cCustoCrd = @cCusto"+CRLF
cCorpo += "            end"+CRLF
/* insercao na tabela destino CT2  */
/* ----------------------------------------------------------------------------
    Atualizao CTF
   ---------------------------------------------------------------------------- */
cCorpo += "            Select @iRecnoCTF = R_E_C_N_O_"+CRLF
cCorpo += "              From "+cCTFDest+CRLF
cCorpo += "             Where CTF_FILIAL = @cFilial_CTF"+CRLF
cCorpo += "               and CTF_DATA   = @IN_DATA"+CRLF
cCorpo += "               and CTF_LOTE   = @cLote"+CRLF
cCorpo += "               and CTF_SBLOTE = @cSubLote"+CRLF
cCorpo += "               and CTF_DOC    = @cDoc"+CRLF
cCorpo += "               and D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            If @iRecnoCTF Is Null begin "+CRLF
cCorpo += "               Select @iRecnoCTF = IsNull(Max( R_E_C_N_O_), 0) From "+cCTFDest+CRLF
cCorpo += "               Select @iRecnoCTF = @iRecnoCTF + 1"+CRLF
cCorpo += "               Insert into "+cCTFDest+" ( CTF_FILIAL,   CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values ( @cFilial_CTF, @IN_DATA, @cLote,   @cSubLote,  @cDoc,   @cLinha,   @iRecnoCTF )"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update "+cCTFDest+CRLF
cCorpo += "               Set CTF_LINHA = @cLinha"+CRLF
cCorpo += "               Where R_E_C_N_O_ = @iRecnoCTF"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            If @IN_LMOEDAESP = '1' and @IN_MOEDA != '01' begin"+CRLF
cCorpo += "               Select @cMoeda1 = '01'"+CRLF
cCorpo += "               Select @nValor1 = 0"+CRLF
cCorpo += "               Select @cCrConv   = '5'"+CRLF
cCorpo += "               Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "               Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "               Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,     CT2_LOTE,    CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                   CT2_DEBITO,   CT2_CREDIT,   CT2_VALOR,   CT2_HIST,   CT2_CCD,    CT2_CCC,"+CRLF
cCorpo += "                                   CT2_EMPORI,   CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,"+CRLF
cCorpo += "                                   CT2_SEQHIS,   CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values (@cFilial_CT2, @IN_DATA,     @cLote,      @cSubLote,  @cDoc,      @cLinha,    @cMoeda1,   @cDc,"+CRLF
cCorpo += "                                   @cContaDeb,   @cContaCrd,   @nValor1,    @cHist,     @cCustoDeb, @cCustoCrd,"+CRLF
cCorpo += "                                   @IN_EMPORI,   @cFilial_CQ3, @IN_TPSALDO, @cManual,   @cRotina,   @cAglut,"+CRLF
cCorpo += "                                   @cSeqHis,     @cSeqLan,     @cCrConv,    @iRecno )"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Select @nValor = Round( @nValor, 2)"+CRLF
cCorpo += "            Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "            Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "            Select @cCrConv   = '4'"+CRLF
cCorpo += "            Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,     CT2_LOTE,    CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                CT2_DEBITO,   CT2_CREDIT,   CT2_VALOR,   CT2_HIST,   CT2_CCD,    CT2_CCC, "+CRLF
cCorpo += "                                CT2_EMPORI,   CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,"+CRLF
cCorpo += "                                CT2_SEQHIS,   CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                        Values (@cFilial_CT2, @IN_DATA,     @cLote,      @cSubLote,  @cDoc,      @cLinha,     @cMoeda,   @cDc,"+CRLF
cCorpo += "                                @cContaDeb,   @cContaCrd,   @nValor,     @cHist,     @cCustoDeb, @cCustoCrd, "+CRLF
cCorpo += "                                @IN_EMPORI,   @cFilial_CQ3, @IN_TPSALDO, @cManual,   @cRotina,   @cAglut,"+CRLF
cCorpo += "                                @cSeqHis,     @cSeqLan,     @cCrConv,    @iRecno )"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "      select @cMoedaAnt = @cMoeda"+CRLF
cCorpo += "      select @cDataAnt  = @cData"+CRLF
cCorpo += "      select @cContaAnt = @cConta"+CRLF
cCorpo += "      select @cCustoAnt = @cCusto"+CRLF
cCorpo += "      select @cFilAnt   = @cFilial_CQ3"+CRLF
/* ------------------------------------------------------------------------------------------------------
   Tratamento para o DB2
   ------------------------------------------------------------------------------------------------------ */
If Trim(TcGetDb()) = 'DB2'
	cCorpo += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cCorpo += "      Fetch CUR_CTB220CQ3 into @cFilial_CQ3, @cMoeda, @cData, @cConta, @cCusto, @nDebito, @nCredit"+CRLF
      /*   saldo na moeda 1 zerado e na 2 nao zerado */
cCorpo += "      If ( @cFilial_CQ3 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto) begin"+CRLF
cCorpo += "         select @lPrim  = '1'"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "   End"+CRLF
cCorpo += "   Close CUR_CTB220CQ3"+CRLF
cCorpo += "   Deallocate CUR_CTB220CQ3"+CRLF
cCorpo += CRLF
cCorpo += "   Select @OUT_LOTE = @cLote"+CRLF
cCorpo += "   Select @OUT_DOC = @cDoc"+CRLF
cCorpo += "   select @OUT_CONT = @iContador"+CRLF
cCorpo += "End "+CRLF

cQuery := cParam+cDeclare+cCorpo
cQuery := MsParse(cQuery,Alltrim(TcGetDB()))
cQuery := CtbAjustaP(.F., cQuery)

Return (cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220CQ1  ³ Autor  ³ Alice Y. Yamamoto       ³ Data 08.03.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria procedure p geracao de lactos de saldos inciais do CT7 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220CQ1(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpresas )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³cQuery -> procedure de geracao de lactos de slds iniciais CT7³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmp     - empresa que tera os dados consolidados   ³±±
±±³           ³ ExpC2 = cCT2Dest - CT2 destino. Os dados serao consolidados ³±±
±±³           ³ ExpC2 = cCTFDest - CTF destino. Os dados serao consolidados ³±±
±±³           ³ ExpC3 = cTabela  - Tabela(CT7)que sera os consolidada       ³±±
±±³           ³ ExpA1 = aEmpresas- Array com as empresas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220CQ1(cEmp, cCT2Dest, cCTFDest, cTabela, aEmpresas, cArray)
Local cParam   := ""
Local cDeclare := ""
Local cCorpo   := ""
Local cQuery   := ""
Local aCampos  := CT2->(DbStruct())
Local cTabCQ7
Local cTabCQ5
Local cTabCQ3
Local aEmpTab
Local nPos
Local cINAux
Local cFiliais
Local cTipo
Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local cXFILIAL  :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "XFILIAL_03", "XFILIAL" ))
Local cMSSTRZERO:=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSTRZERO_03"+"_"+cEmpAnt, "MSSTRZERO")
Local cMSSOMA1  :=  IIF(Alltrim(cCTB020) = "CTB020_03", "MSSOMA1_03"+"_"+cEmpAnt, "MSSOMA1")

aEmpTab := Ctb220aEmp(aEmpresas, "CQ7")
nPos    := Ascan( aEmpTab, {|x| Alltrim(x[1]) == cEmp } )
cTabCQ7 := aEmpTab[nPos][2]

aEmpTab := Ctb220aEmp(aEmpresas, "CQ5")
nPos    := Ascan( aEmpTab, {|x| Alltrim(x[1]) == cEmp } )
cTabCQ5 := aEmpTab[nPos][2]

aEmpTab := Ctb220aEmp(aEmpresas, "CQ3")
nPos    := Ascan( aEmpTab, {|x| Alltrim(x[1]) == cEmp } )
cTabCQ3 := aEmpTab[nPos][2]

cINAux   := "#"+cEmp
cFiliais := CTB220FilIn(cInAux, cArray)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procedure =>cQuery = cParam+cDeclare+cCorpo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada - cParam                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cParam := " Create Procedure CTB220CQ1_"+cEmpAnt+CRLF
cParam += "(" +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_EMPORI" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_EMPORI       "+cTipo+CRLF  // empresa destino
cParam += "  @IN_FILIALDEST   Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )," +CRLF  // filial destino sm0->m0_codfil
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_TPSALD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_TPSALDO      "+cTipo+CRLF
cParam += "  @IN_DATA         Char( 08 )," +CRLF
cParam += "  @IN_LMOEDAESP    Char( 01 )," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_MOEDA        "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_LOTE         "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SBLOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_SUBLOTE      "+cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+"),"
cParam += "  @IN_DOC          "+cTipo+CRLF
cParam += "  @IN_MAXLINHA     Integer," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_LOTE        "+cTipo+" OutPut," +CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cParam += "  @OUT_DOC         "+cTipo+" OutPut, " +CRLF
cParam += "  @OUT_CONT        Integer    OutPut " +CRLF
cParam += ")"+CRLF
cParam += "as "+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis da Procedure - cDeclare                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDeclare := "Declare @cFilial_CT2 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ3 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ5 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ1 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CTF Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilial_CQ7 Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cFilAnt     Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cData       Char( 08 )" +CRLF
cDeclare += "Declare @cDataAnt    Char( 08 )" +CRLF
cDeclare += "Declare @cAux1       Char( 01 )" +CRLF
cDeclare += "Declare @cAux        Char( 03 )" +CRLF
cDeclare += "Declare @lPrim       Char( 01 )" +CRLF
cDeclare += "Declare @cDc         Char( 01 )" +CRLF
cDeclare += "Declare @cManual     Char( 01 )" +CRLF
cDeclare += "Declare @cRotina     VarChar( 10 )" +CRLF
cDeclare += "Declare @cAglut      Char( 01 )" +CRLF
cDeclare += "Declare @cCrConv     Char( 01 )" +CRLF
cDeclare += "Declare @iRecno      integer" +CRLF
cDeclare += "Declare @iRecnoCTF   integer" +CRLF
cDeclare += "Declare @iMaxLinha   integer" +CRLF
cDeclare += "Declare @iLinha      integer" +CRLF
cDeclare += "Declare @iAux        integer" +CRLF
cDeclare += "Declare @iContador   integer" +CRLF
cDeclare += "Declare @cSubLote    Char( 03 )" +CRLF
/* Crio com tamanho das variaveis de acordo com a estrutura do CT2*/
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_HIST" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cHist      "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQHIS" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqHis    "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_SEQLAN" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cSeqLan    "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DOC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cDoc       "+ cTipo+CRLF
cDeclare += "Declare @cDocAux    "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LOTE" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLote      "+ cTipo+CRLF
cDeclare += "Declare @cLoteAux   "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_DEBITO" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cConta     "+ cTipo+CRLF
cDeclare += "Declare @cContaDeb  "+ cTipo+CRLF
cDeclare += "Declare @cContaCrd  "+ cTipo+CRLF
cDeclare += "Declare @cContaAnt  "+ cTipo+CRLF
cDeclare += "Declare @cContaCQ3  "+ cTipo+CRLF
cDeclare += "Declare @cContaCQ5  "+ cTipo+CRLF
cDeclare += "Declare @cContaCQ5A "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_CCD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cCustoCQ3  "+ cTipo+CRLF
cDeclare += "Declare @cCustoCQ5  "+ cTipo+CRLF
cDeclare += "Declare @cCustoCQ5A "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_ITEMD" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cItemCQ5  "+ cTipo+CRLF
cDeclare += "Declare @cItemCQ5A "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_MOEDLC" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cMoeda    "+ cTipo+CRLF
cDeclare += "Declare @cMoeda1   "+ cTipo+CRLF
cDeclare += "Declare @cMoedaAnt "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_LINHA" } )
cTipo := " Char("+StrZero(aCampos[nPos][3],3)+")"
cDeclare += "Declare @cLinha    "+ cTipo+CRLF
cDeclare += "Declare @cLinhaAux "+ cTipo+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_VALOR" } )
cTipo := " Float"
cDeclare += "Declare @nValor        "+cTipo+CRLF
cDeclare += "Declare @nValor1       "+cTipo+CRLF
cDeclare += "Declare @nValorDeb     "+cTipo+CRLF
cDeclare += "Declare @nValorCrd     "+cTipo+CRLF
cDeclare += "Declare @nDebito       "+cTipo+CRLF
cDeclare += "Declare @nCredit       "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ3    "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ3    "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ5    "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ5    "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ5A   "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ5A   "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ7    "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ7    "+cTipo+CRLF
cDeclare += "Declare @nDebitoCQ7A   "+cTipo+CRLF
cDeclare += "Declare @nCreditCQ7A   "+cTipo+CRLF
cDeclare += "Declare @iLinha1       Integer"+CRLF
cDeclare += "Declare @lCriaLinha    Char(01)"+CRLF
cDeclare += "Declare @nTotDebCQ5A   "+cTipo+CRLF
cDeclare += "Declare @nTotCrdCQ5A   "+cTipo+CRLF
cDeclare += "Declare @nTotDebCQ3    "+cTipo+CRLF
cDeclare += "Declare @nTotCrdCQ3    "+cTipo+CRLF
cDeclare += "Declare @nTotDebCQ5    "+cTipo+CRLF
cDeclare += "Declare @nTotCrdCQ5    "+cTipo+CRLF
cDeclare += "Declare @nTotDeb       "+cTipo+CRLF
cDeclare += "Declare @nTotCrd       "+cTipo+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corpo da Procedure                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpo := "begin"+CRLF 
cCorpo += "   Select @cLote     = @IN_LOTE"+CRLF
cCorpo += "   Select @cSubLote  = @IN_SUBLOTE"+CRLF
cCorpo += "   Select @cDoc      = @IN_DOC"+CRLF
cCorpo += "   Select @iRecno    = 0"+CRLF
cCorpo += "   Select @iRecnoCTF = 0"+CRLF
cCorpo += "   Select @iLinha    = 1"+CRLF
cCorpo += "   Select @iContador = 0"+CRLF
cCorpo += "   Select @cLinha    = '000'"+CRLF
cCorpo += "   Select @cLinhaAux = '000'"+CRLF
cCorpo += "   Select @cAux1     = '0'"+CRLF
cCorpo += "   select @cMoedaAnt = ' '"+CRLF
cCorpo += "   select @cDataAnt  = ' '"+CRLF
cCorpo += "   select @cContaAnt = ' '"+CRLF
cCorpo += "   select @lPrim     = '1'"+CRLF
cCorpo += "   Select @cHist     = 'Saldo Inicial'"+CRLF
cCorpo += "   Select @cManual   = '1'"+CRLF
cCorpo += "   Select @cRotina   = 'CTBA101'"+CRLF
cCorpo += "   Select @cAglut    = '2'"+CRLF
cCorpo += "   Select @cSeqHis   = '001'"+CRLF
cCorpo += "   Select @cSeqLan   = ''"+CRLF
cCorpo += "   Select @cCrConv   = '4'"+CRLF
cCorpo += "   Select @iMaxLinha = @IN_MAXLINHA"+CRLF
cCorpo += "   select @nValor    = 0"+CRLF
cCorpo += "   Select @iAux      = 0"+CRLF
cCorpo += "   Select @OUT_LOTE  = ''"+CRLF
cCorpo += "   select @OUT_DOC   = ''"+CRLF
cCorpo += "   select @OUT_CONT  = @iContador"+CRLF
cCorpo += CRLF
cCorpo += "   select @cAux      = 'CT2'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CT2 OutPut"+CRLF
cCorpo += "   select @cAux      = 'CTF'"+CRLF
cCorpo += "   exec "+cXFILIAL+" @cAux, @IN_FILIALDEST, @cFilial_CTF OutPut"+CRLF
cCorpo += CRLF
cCorpo += "   Declare CUR_CTB220CQ1 insensitive cursor  for"+CRLF 
cCorpo += "   Select CQ1_FILIAL, CQ1_MOEDA, CQ1_DATA, CQ1_CONTA, Sum(CQ1_DEBITO), Sum(CQ1_CREDIT)"+CRLF
cCorpo += "       From "+cTabela+CRLF 
cCorpo += "      Where D_E_L_E_T_ = ' '"+CRLF 
If Substr(cFiliais,3,1) = " " 
	cCorpo += "        and CQ1_FILIAL = '  '"+CRLF 
Else
	cCorpo += "        and CQ1_FILIAL IN "+cFiliais+CRLF
EndIf
// PASSO8
cCorpo += "        and CQ1_DATA  <= @IN_DATA"+CRLF 
cCorpo += "        and CQ1_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "        and CQ1_LP    != 'S'"+CRLF 
cCorpo += "        and ( (CQ1_MOEDA  = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )"+CRLF 
cCorpo += "   group by CQ1_FILIAL, CQ1_CONTA, CQ1_DATA, CQ1_MOEDA"+CRLF
cCorpo += "   Order By 1, 4, 3, 2"+CRLF
cCorpo += "   For read only"+CRLF
cCorpo += "   Open CUR_CTB220CQ1"+CRLF
cCorpo += "   Fetch CUR_CTB220CQ1 into @cFilial_CQ1, @cMoeda, @cData, @cConta, @nDebito, @nCredit"+CRLF

cCorpo += CRLF
cCorpo += "   While ( @@fetch_status = 0 ) begin "+CRLF
cCorpo += "      select @cAux      = 'CQ7'"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @cFilial_CQ1, @cFilial_CQ7 OutPut"+CRLF
cCorpo += "      select @cAux      = 'CQ5'"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @cFilial_CQ1, @cFilial_CQ5 OutPut"+CRLF
cCorpo += "      select @cAux      = 'CQ3'"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @cFilial_CQ1, @cFilial_CQ3 OutPut"+CRLF
cCorpo += "      select @nDebitoCQ7 = 0"+CRLF
cCorpo += "      select @nCreditCQ7 = 0"+CRLF
      /* ----------------------------------------------------------------------------
         1 - CALCULO DO VLR LANCADO NO CQ7 sem CUSTO E SEM ITEM
         ---------------------------------------------------------------------------- */
// PASSO9
cCorpo += "      Select @nDebitoCQ7 = IsNull(Sum(CQ7_DEBITO), 0 ), @nCreditCQ7 = IsNull(Sum(CQ7_CREDIT), 0 )"+CRLF
cCorpo += "        From "+cTabCQ7+" B"+CRLF 
cCorpo += "       Where D_E_L_E_T_ = ' '"+CRLF 
cCorpo += "          and CQ7_FILIAL = @cFilial_CQ7"+CRLF 
cCorpo += "          and CQ7_CONTA  = @cConta"+CRLF 
cCorpo += "          and CQ7_MOEDA  = @cMoeda"+CRLF 
cCorpo += "          and CQ7_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "          and CQ7_DATA   = @cData"+CRLF 
cCorpo += "          and CQ7_LP    != 'S'"+CRLF
      /* ----------------------------------------------------------------------------
        2 -  CALCULO DO VLR LANCADO NO CQ5
         ---------------------------------------------------------------------------- */
cCorpo += "      Select @nDebitoCQ5 = 0"+CRLF 
cCorpo += "      Select @nCreditCQ5 = 0"+CRLF 
cCorpo += "      Select @nTotDebCQ5 = 0"+CRLF 
cCorpo += "      Select @nTotCrdCQ5 = 0"+CRLF 
// PASSO10
cCorpo += "      Declare CUR_CTB220CQ5 insensitive cursor  for"+CRLF 
cCorpo += "      Select CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, Sum(CQ5_DEBITO), SUM(CQ5_CREDIT)"+CRLF 
cCorpo += "        From "+cTabCQ5+" C"+CRLF 
cCorpo += "       Where D_E_L_E_T_ = ' '"+CRLF 
cCorpo += "         and CQ5_FILIAL = @cFilial_CQ5"+CRLF 
cCorpo += "         and CQ5_CONTA  = @cConta"+CRLF 
cCorpo += "         and CQ5_MOEDA  = @cMoeda"+CRLF 
cCorpo += "         and CQ5_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "         and CQ5_DATA   = @cData"+CRLF
cCorpo += "         and CQ5_LP    != 'S'"+CRLF
cCorpo += "      Group By CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM"+CRLF 
cCorpo += "      Order By 1, 2, 3"+CRLF 
cCorpo += "      For read only"+CRLF 
cCorpo += "      Open CUR_CTB220CQ5"+CRLF 
cCorpo += "      Fetch CUR_CTB220CQ5 into @cContaCQ5, @cCustoCQ5, @cItemCQ5, @nDebitoCQ5, @nCreditCQ5"+CRLF 
cCorpo += CRLF
cCorpo += "      While ( @@fetch_status = 0 ) begin"+CRLF 
cCorpo += "         Select @nValorDeb = 0"+CRLF 
cCorpo += "         Select @nValorCrd = 0"+CRLF 
         /* ----------------------------------------------------------------------------
             2.1 - Calculo do vlr lancado no CQ7 a abater do CQ5
            ---------------------------------------------------------------------------- */
// PASSO11
cCorpo += "         Select @nValorDeb = IsNull( Sum(CQ7_DEBITO), 0 ), @nValorCrd = IsNull( Sum(CQ7_CREDIT), 0 )"+CRLF 
cCorpo += "           From "+cTabCQ7+" D"+CRLF 
cCorpo += "          Where CQ7_FILIAL = @cFilial_CQ7"+CRLF
cCorpo += "            and CQ7_CONTA  = @cContaCQ5"+CRLF 
cCorpo += "            and CQ7_CCUSTO = @cCustoCQ5"+CRLF 
cCorpo += "            and CQ7_ITEM   = @cItemCQ5"+CRLF 
cCorpo += "            and CQ7_MOEDA  = @cMoeda"+CRLF 
cCorpo += "            and CQ7_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "            and CQ7_DATA   = @cData"+CRLF
cCorpo += "            and CQ7_LP    != 'S'"+CRLF
cCorpo += "            and D_E_L_E_T_ = ' '"+CRLF 
cCorpo += "         "+CRLF
cCorpo += "         Select @nTotDebCQ5 = @nTotDebCQ5 + (@nDebitoCQ5 - @nValorDeb )"+CRLF
cCorpo += "         Select @nTotCrdCQ5 = @nTotCrdCQ5 + (@nCreditCQ5 - @nValorCrd )"+CRLF
cCorpo += "         Fetch CUR_CTB220CQ5 into @cContaCQ5, @cCustoCQ5, @cItemCQ5, @nDebitoCQ5, @nCreditCQ5"+CRLF 
cCorpo += "      End"+CRLF
cCorpo += CRLF
cCorpo += "      Close CUR_CTB220CQ5"+CRLF 
cCorpo += "      Deallocate CUR_CTB220CQ5"+CRLF 
      /* ----------------------------------------------------------------------------
        3 -  CALCULO DO VLR LANCADO NO CQ3
         ---------------------------------------------------------------------------- */
cCorpo += "      Select @nDebitoCQ3 = 0"+CRLF 
cCorpo += "      Select @nCreditCQ3 = 0"+CRLF 
cCorpo += "      Select @nTotDebCQ3 = 0"+CRLF 
cCorpo += "      Select @nTotCrdCQ3 = 0"+CRLF 

// PASSO12
cCorpo += "      Declare CUR_CTB220CQ3 insensitive cursor  for"+CRLF 
cCorpo += "      Select CQ3_CONTA, CQ3_CCUSTO, Sum(CQ3_DEBITO), Sum(CQ3_CREDIT)"+CRLF 
cCorpo += "        From "+cTabCQ3+" E"+CRLF
cCorpo += "       Where D_E_L_E_T_ = ' '"+CRLF 
cCorpo += "         and CQ3_FILIAL = @cFilial_CQ3"+CRLF 
cCorpo += "         and CQ3_CONTA  = @cConta"+CRLF 
cCorpo += "         and CQ3_MOEDA  = @cMoeda"+CRLF 
cCorpo += "         and CQ3_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "         and CQ3_DATA   = @cData"+CRLF 
cCorpo += "         and CQ3_LP    != 'S'"+CRLF
cCorpo += "      Group By CQ3_CONTA, CQ3_CCUSTO"+CRLF 
cCorpo += "      Order By 1, 2"+CRLF 
cCorpo += "      For read only"+CRLF 
cCorpo += "      Open CUR_CTB220CQ3"+CRLF 
cCorpo += "      Fetch CUR_CTB220CQ3 into @cContaCQ3, @cCustoCQ3, @nDebitoCQ3, @nCreditCQ3"+CRLF 
cCorpo += CRLF
cCorpo += "      While ( @@fetch_status = 0 ) begin"+CRLF 
         /* ----------------------------------------------------------------------------
             3.1 - Calculo do vlr lancado no CQ7 a abater do CQ3
            ---------------------------------------------------------------------------- */
cCorpo += "         select @nCreditCQ7A   = 0"+CRLF 
cCorpo += "         select @nDebitoCQ7A   = 0"+CRLF 
cCorpo += "         "+CRLF
// PASSO13
cCorpo += "         Select @nDebitoCQ7A = IsNull( Sum(CQ7_DEBITO), 0 ), @nCreditCQ7A = IsNull( Sum(CQ7_CREDIT), 0 )"+CRLF 
cCorpo += "           From "+cTabCQ7+" H"+CRLF
cCorpo += "          Where CQ7_FILIAL = @cFilial_CQ7"+CRLF 
cCorpo += "            and CQ7_CONTA  = @cContaCQ3"+CRLF 
cCorpo += "            and CQ7_CCUSTO = @cCustoCQ3"+CRLF 
cCorpo += "            and CQ7_MOEDA  = @cMoeda"+CRLF 
cCorpo += "            and CQ7_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "            and CQ7_DATA   = @cData"+CRLF 
cCorpo += "            and CQ7_LP    != 'S'"+CRLF 
cCorpo += "            and D_E_L_E_T_ = ' '"+CRLF 
cCorpo += CRLF
         /* ----------------------------------------------------------------------------
             3.2 - Calculo do vlr lancado no CQ5 a abater do CQ3
            ---------------------------------------------------------------------------- */
cCorpo += "         Select @nDebitoCQ5A = 0"+CRLF
cCorpo += "         Select @nCreditCQ5A = 0"+CRLF
cCorpo += "         Select @nTotDebCQ5A = 0"+CRLF
cCorpo += "         Select @nTotCrdCQ5A = 0"+CRLF
// PASSO14
cCorpo += "         Declare CUR_CTB220CQ5A insensitive cursor  for"+CRLF 
cCorpo += "         Select CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, Sum(CQ5_DEBITO), Sum(CQ5_CREDIT)"+CRLF 
cCorpo += "           From "+cTabCQ5+" F"+CRLF
cCorpo += "          Where CQ5_FILIAL = @cFilial_CQ5"+CRLF 
cCorpo += "            and CQ5_CONTA  = @cContaCQ3"+CRLF 
cCorpo += "            and CQ5_CCUSTO = @cCustoCQ3"+CRLF 
cCorpo += "            and CQ5_MOEDA  = @cMoeda"+CRLF 
cCorpo += "            and CQ5_TPSALD = @IN_TPSALDO"+CRLF 
cCorpo += "            and CQ5_DATA   = @cData"+CRLF 
cCorpo += "            and CQ5_LP    != 'S'"+CRLF
cCorpo += "            and D_E_L_E_T_ = ' '"+CRLF 
cCorpo += "         group by CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM"+CRLF
cCorpo += "         order by 1, 2, 3"+CRLF
cCorpo += "         For read only"+CRLF
cCorpo += "         Open CUR_CTB220CQ5A"+CRLF
cCorpo += "         Fetch CUR_CTB220CQ5A into @cContaCQ5A, @cCustoCQ5A, @cItemCQ5A, @nDebitoCQ5A, @nCreditCQ5A"+CRLF
cCorpo += CRLF
cCorpo += "         While ( @@fetch_status = 0 ) begin"+CRLF
cCorpo += "            Select @nValorDeb = 0"+CRLF
cCorpo += "            Select @nValorCrd = 0"+CRLF
            /* ----------------------------------------------------------------------------
                3.2.1 - Calculo do vlr lancado no CQ7 a abater do CQ5
               ---------------------------------------------------------------------------- */
// PASSO15
cCorpo += "            Select @nValorDeb = IsNull( Sum(CQ7_DEBITO), 0 ), @nValorCrd = IsNull( Sum(CQ7_CREDIT), 0 )"+CRLF
cCorpo += "              From "+cTabCQ7+" G"+CRLF
cCorpo += "             Where CQ7_FILIAL = @cFilial_CQ7"+CRLF
cCorpo += "               and CQ7_CONTA  = @cContaCQ5A"+CRLF
cCorpo += "               and CQ7_CCUSTO = @cCustoCQ5A"+CRLF
cCorpo += "               and CQ7_ITEM   = @cItemCQ5A"+CRLF
cCorpo += "               and CQ7_MOEDA  = @cMoeda"+CRLF
cCorpo += "               and CQ7_TPSALD = @IN_TPSALDO"+CRLF
cCorpo += "               and CQ7_DATA   = @cData"+CRLF
cCorpo += "               and CQ7_LP    != 'S'"+CRLF
cCorpo += "               and D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            Select @nTotDebCQ5A = @nTotDebCQ5A + (@nDebitoCQ5A - @nValorDeb )"+CRLF
cCorpo += "            Select @nTotCrdCQ5A = @nTotCrdCQ5A + (@nCreditCQ5A - @nValorCrd )"+CRLF
cCorpo += "            Fetch CUR_CTB220CQ5A into @cContaCQ5A, @cCustoCQ5A, @cItemCQ5A, @nDebitoCQ5A, @nCreditCQ5A"+CRLF
cCorpo += "         End   -- FIM CQ5"+CRLF
cCorpo += "         Close CUR_CTB220CQ5A"+CRLF
cCorpo += "         Deallocate CUR_CTB220CQ5A"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         Select @nTotDebCQ3 = @nTotDebCQ3 + ( @nDebitoCQ3 - @nTotDebCQ5A - @nDebitoCQ7A )"+CRLF
cCorpo += "         Select @nTotCrdCQ3 = @nTotCrdCQ3 + ( @nCreditCQ3 - @nTotCrdCQ5A - @nCreditCQ7A )"+CRLF
cCorpo += "         Fetch CUR_CTB220CQ3 into @cContaCQ3, @cCustoCQ3, @nDebitoCQ3, @nCreditCQ3"+CRLF
cCorpo += "      End  -- FIM CQ3"+CRLF
cCorpo += "      Close CUR_CTB220CQ3"+CRLF
cCorpo += "      Deallocate CUR_CTB220CQ3"+CRLF
//      --                  total do CQ1         - (   CQ7         + CQ5           + CQ3 )
cCorpo += "      select @nTotDeb = ( @nDebito - @nDebitoCQ7 - @nTotDebCQ3 - @nTotDebCQ5 )"+CRLF 
cCorpo += "      select @nTotCrd = ( @nCredit - @nCreditCQ7 - @nTotCrdCQ3 - @nTotCrdCQ5 )"+CRLF 
cCorpo += "      select @nValor = @nTotCrd - @nTotDeb"+CRLF 
cCorpo += "      select @iLinha1 = 1"+CRLF 
cCorpo += "      select @lCriaLinha = '1'"+CRLF 
cCorpo += "      While @iLinha1 < 3 begin"+CRLF 
cCorpo += "         If ( Round(@nTotCrd, 2)  = Round(@nTotDeb, 2) ) and ( Round(@nTotCrd, 2) != 0 or Round(@nTotDeb, 2) != 0 ) begin"+CRLF 
cCorpo += "            If @iLinha1 = 1 begin"+CRLF 
cCorpo += "               Select @nValor = @nTotCrd"+CRLF 
cCorpo += "               select @iLinha1 = 2"+CRLF 
cCorpo += "            end else begin"+CRLF 
cCorpo += "               If @iLinha1 = 2 begin"+CRLF 
cCorpo += "                  Select @nValor = ( 0 - @nTotDeb )"+CRLF 
cCorpo += "                  select @iLinha1 = 3"+CRLF 
cCorpo += "               End"+CRLF 
cCorpo += "            End"+CRLF 
cCorpo += "            select @lPrim = '1'"+CRLF
cCorpo += "            select @lCriaLinha = '1'"+CRLF 
cCorpo += "         end else begin"+CRLF 
cCorpo += "            If Round(@nValor, 2) != 0 begin"+CRLF 
cCorpo += "               select @lCriaLinha = '1'"+CRLF 
cCorpo += "            end else begin"+CRLF 
cCorpo += "               select @lCriaLinha = '0'"+CRLF 
cCorpo += "            end"+CRLF 
cCorpo += "            select @iLinha1 = 3"+CRLF 
cCorpo += "         end"+CRLF 
cCorpo += "         If @lCriaLinha = '1' begin"+CRLF 
cCorpo += "            select @iContador = 1"+CRLF 
         /* ----------------------------------------------------------------------------
            Somo 1 no documento se mudar a filial
            ---------------------------------------------------------------------------- */
cCorpo += "            If ( @cFilial_CQ1 != @cFilAnt and (@cFilAnt is not null)) begin"+CRLF 
cCorpo += "               If @cDoc = '999999' begin"+CRLF 
cCorpo += "                  select @cAux1     = '0'"+CRLF 
cCorpo += "                  select @cLoteAux  = @cLote"+CRLF 
cCorpo += "                  Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF 
cCorpo += "                  select @cDoc = '000000'"+CRLF 
cCorpo += "               End"+CRLF 
cCorpo += "               select @iLinha = 1"+CRLF 
cCorpo += "               select @iAux   = Len( @cLinha )"+CRLF 
cCorpo += "               exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF 
cCorpo += "               select @cAux1     = '0'"+CRLF 
cCorpo += "               select @cDocAux   = @cDoc"+CRLF 
cCorpo += "               Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF 
cCorpo += "            End else begin"+CRLF 
cCorpo += "      	        If @IN_LMOEDAESP = '1' begin"+CRLF
cCorpo += "                  If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                     If @cDoc = '999999' begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLoteAux  = @cLote"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                        select @cDoc = '000000'"+CRLF 
cCorpo += "                     End"+CRLF
cCorpo += "                     select @iLinha = 1"+CRLF
cCorpo += "                     select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                     exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                     select @cDocAux   = @cDoc"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                  end else begin"+CRLF
cCorpo += "                     select @cAux1     = '0'"+CRLF
cCorpo += "                     select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                     Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                     select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End else begin"+CRLF
cCorpo += "                  If ( @cDataAnt != @cData or @cContaAnt != @cConta ) or @lPrim  = '1' begin"+CRLF
cCorpo += "                     select @lPrim = '0'"+CRLF
cCorpo += "                     If @iLinha = @iMaxLinha begin"+CRLF
cCorpo += "                        If @cDoc = '999999' begin"+CRLF
cCorpo += "                           select @cAux1     = '0'"+CRLF
cCorpo += "                           select @cLoteAux  = @cLote"+CRLF
cCorpo += "                           Exec "+cMSSOMA1+" @cLoteAux, @cAux1, @cLote OutPut"+CRLF
cCorpo += "                           select @cDoc = '000000'"+CRLF 
cCorpo += "                        End"+CRLF
cCorpo += "                        select @iLinha = 1"+CRLF
cCorpo += "                        select @iAux   = Len( @cLinha )"+CRLF
cCorpo += "                        exec "+cMSSTRZERO+" @iLinha, @iAux, @cLinha output"+CRLF
cCorpo += "                        select @cDocAux   = @cDoc"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cDocAux, @cAux1, @cDoc OutPut"+CRLF
cCorpo += "                     end else begin"+CRLF
cCorpo += "                        select @cAux1     = '0'"+CRLF
cCorpo += "                        select @cLinhaAux = @cLinha"+CRLF
cCorpo += "                        Exec "+cMSSOMA1+" @cLinhaAux, @cAux1, @cLinha OutPut"+CRLF
cCorpo += "                        select @iLinha = @iLinha + 1"+CRLF
cCorpo += "                     End"+CRLF
cCorpo += "                  End"+CRLF
cCorpo += "               End"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Select @cSeqLan = @cLinha"+CRLF
cCorpo += "            If @nValor < 0 begin"+CRLF
cCorpo += "               Select @cDc = '1'"+CRLF
cCorpo += "               Select @cContaDeb = @cConta"+CRLF
cCorpo += "               Select @cContaCrd = ' '"+CRLF
cCorpo += "               Select @nValor    = @nValor * ( -1 )"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Select @cDc = '2'"+CRLF
cCorpo += "               Select @cContaDeb = ' '"+CRLF
cCorpo += "               Select @cContaCrd = @cConta"+CRLF
cCorpo += "            end"+CRLF
/* ----------------------------------------------------------------------------
    Atualizao CTF
   ---------------------------------------------------------------------------- */
cCorpo += "            Select @iRecnoCTF = R_E_C_N_O_"+CRLF
cCorpo += "              From "+cCTFDest+CRLF
cCorpo += "             Where CTF_FILIAL = @cFilial_CTF"+CRLF
cCorpo += "               and CTF_DATA   = @IN_DATA"+CRLF
cCorpo += "               and CTF_LOTE   = @cLote"+CRLF
cCorpo += "               and CTF_SBLOTE = @cSubLote"+CRLF
cCorpo += "               and CTF_DOC    = @cDoc"+CRLF
cCorpo += "               and D_E_L_E_T_ = ' '"+CRLF
cCorpo += CRLF
cCorpo += "            If @iRecnoCTF is Null begin "+CRLF
cCorpo += "               Select @iRecnoCTF = IsNull(Max( R_E_C_N_O_), 0) From "+cCTFDest+CRLF
cCorpo += "               Select @iRecnoCTF = @iRecnoCTF + 1"+CRLF
cCorpo += "               Insert into "+cCTFDest+" ( CTF_FILIAL,   CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values ( @cFilial_CTF, @IN_DATA, @cLote,   @cSubLote,  @cDoc,   @cLinha,   @iRecnoCTF )"+CRLF
cCorpo += "               "+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update "+cCTFDest+CRLF
cCorpo += "               Set CTF_LINHA = @cLinha"+CRLF
cCorpo += "               Where R_E_C_N_O_ = @iRecnoCTF"+CRLF
cCorpo += "            End"+CRLF      
cCorpo += "            If @IN_LMOEDAESP   = '1' and @IN_MOEDA != '01' begin"+CRLF
cCorpo += "               Select @cMoeda1 = '01'"+CRLF
cCorpo += "               Select @nValor1 = 0"+CRLF
cCorpo += "               Select @cCrConv = '5'"+CRLF
cCorpo += "               Select @iRecno  = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "               Select @iRecno  = @iRecno + 1"+CRLF
cCorpo += "               Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC, CT2_DC,"+CRLF
cCorpo += "                                   CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_EMPORI,  CT2_FILORI,   CT2_TPSALD, CT2_MANUAL,"+CRLF
cCorpo += "                                   CT2_ROTINA,   CT2_AGLUT,  CT2_SEQHIS,  CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                           Values (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda1,    @cDc,"+CRLF
cCorpo += "                                   @cContaDeb,   @cContaCrd, @nValor1,    @cHist,     @IN_EMPORI,  @cFilial_CQ1, @IN_TPSALDO, @cManual,"+CRLF
cCorpo += "                                   @cRotina,     @cAglut,    @cSeqHis,    @cSeqLan,   @cCrConv,    @iRecno )"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Select @nValor = Round( @nValor, 2)"+CRLF
cCorpo += "            Select @iRecno = IsNull( Max( R_E_C_N_O_ ), 0 ) From "+cCT2Dest+CRLF
cCorpo += "            Select @iRecno = @iRecno + 1"+CRLF
cCorpo += "            Select @cCrConv   = '4'"+CRLF
cCorpo += "            Insert into "+cCT2Dest+" (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC,  CT2_DC,"+CRLF
cCorpo += "                                CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_EMPORI,  CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL,"+CRLF
cCorpo += "                                CT2_ROTINA,   CT2_AGLUT,  CT2_SEQHIS,  CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )"+CRLF
cCorpo += "                        Values (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda ,    @cDc,"+CRLF
cCorpo += "                                @cContaDeb,   @cContaCrd, @nValor,     @cHist,     @IN_EMPORI,  @cFilial_CQ1, @IN_TPSALDO, @cManual,"+CRLF
cCorpo += "                                @cRotina,     @cAglut,    @cSeqHis,    @cSeqLan,   @cCrConv,    @iRecno )"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "      select @cMoedaAnt = @cMoeda"+CRLF
cCorpo += "      select @cDataAnt  = @cData"+CRLF
cCorpo += "      select @cContaAnt = @cConta"+CRLF
cCorpo += "      select @cFilAnt   = @cFilial_CQ7"+CRLF
/* ------------------------------------------------------------------------------------------------------
   Tratamento para o DB2
   ---------------------------------------------------
   
   --------------------------------------------------- */
If Trim(TcGetDb()) = 'DB2'
	cCorpo += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cCorpo += "      Fetch CUR_CTB220CQ1 into @cFilial_CQ1, @cMoeda, @cData, @cConta, @nDebito, @nCredit"+CRLF
	
//cCorpo += "               If ( @cDataAnt != @cData or @cContaAnt != @cConta ) or @lPrim  = '1' begin"+CRLF
      /*   saldo na moeda 1 zerado e na 2 nao zerado */
cCorpo += "      If ( @cFilial_CQ1 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta)  begin"+CRLF
cCorpo += "         select @lPrim  = '1'"+CRLF
cCorpo += "      End"+CRLF
cCorpo += CRLF
cCorpo += "   End"+CRLF
cCorpo += "   Close CUR_CTB220CQ1"+CRLF
cCorpo += "   Deallocate CUR_CTB220CQ1"+CRLF
cCorpo += CRLF
cCorpo += "   Select @OUT_LOTE = @cLote"+CRLF
cCorpo += "   Select @OUT_DOC = @cDoc"+CRLF
cCorpo += "   select @OUT_CONT = @iContador"+CRLF
cCorpo += "End "+CRLF

cQuery := cParam+cDeclare+cCorpo
cQuery := MsParse(cQuery,Alltrim(TcGetDB()))
cQuery := CtbAjustaP(.F., cQuery)

Return (cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctb220DEL  ³ Autor  ³ Alice Y. Yamamoto       ³ Data 14.08.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Exclui dados das tagelas de cadastros CT1/CTT/CTD/CTH       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220DEL(cEmpAnt, cFilAnt, cTabela )                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³cQuery - procedure de exclusao de cadastros                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cEmpAnt - empresa que tera os dados excluidos       ³±±
±±³           ³ ExpC2 = cFilAnt - filial que tera os dados excluidos        ³±±
±±³           ³ ExpC3 = cTabela - Tabela que tera os dados excluidos        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb220DEL(cEmpAnt, cFilAnt, cTabela)
Local aSaveArea	:= GetArea()
Local cParam   :=""
Local cDeclare :=""
Local cCorpo   :=""
Local cQuery   :=""
Local cCTB020    := IIF(FindFunction("GetSPName"), GetSPName("CTB020","03"), "CTB020")
Local cXFILIAL  :=  xProcedure( IIF(Alltrim(cCTB020) = "CTB020_03", "XFILIAL_03", "XFILIAL" ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procedure =>cQuery = cParam+cDeclare+cCorpo                          ³
//³cParam    - Parametros de entrada                                    ³
//³cDeclare  - Variaveis                                                ³
//³cCorpo    - Corpo da Procedure                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cParam := " Create Procedure CTB220DEL_"+cEmpAnt+CRLF
cParam += "(" +CRLF
cParam += "  @IN_FILIAL       Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )," +CRLF  // filial destino sm0->m0_codfil
cParam += "  @IN_TAB          Char( 03 )," +CRLF
cParam += "  @IN_DELFISICO    Char( 01 )," +CRLF
cParam += "  @OUT_RESULTADO   Char( 01 ) OutPut " +CRLF
cParam += ")"+CRLF
cParam += "as "+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis da Procedure - cDeclare                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDeclare += "Declare @cFilial    Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )" +CRLF
cDeclare += "Declare @cAux       Char( 03 )" +CRLF
cDeclare += "Declare @cExec      Char( 01 )" +CRLF
cDeclare += "Declare @iRecno     Integer" +CRLF
cDeclare += "Declare @iNroRegs   Integer" +CRLF  //   -- Controle de cOMMITS
cDeclare += "Declare @iTranCount Integer" +CRLF  // --Var.de ajuste para SQLServer e Sybase.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corpo da Procedure                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpo := "begin"+CRLF
cCorpo += "      select @cAux = @IN_TAB"+CRLF
cCorpo += "      exec "+cXFILIAL+" @cAux, @IN_FILIAL, @cFilial OutPut"+CRLF
cCorpo += "      select @OUT_RESULTADO = '0'"+CRLF
   /*---------------------------------------------------------------
     Exclui dados do CT1
     --------------------------------------------------------------- */
cCorpo += "      select @cExec = '1'"+CRLF
cCorpo += "   "+CRLF
cCorpo += "   If @IN_TAB = 'CT1' begin"+CRLF
cCorpo += "   "+CRLF
cCorpo += "      While @cExec = '1' begin"+CRLF
cCorpo += "         select @iNroRegs = 0"+CRLF
cCorpo += "         Declare CUR_CT1 cursor for"+CRLF
cCorpo += "         Select R_E_C_N_O_"+CRLF
cCorpo += "           From CT1"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CT1_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            AND CT1_CONTA NOT IN ( Select CT1_CTASUP"+CRLF
cCorpo += "                                     from CT1"+cEmpAnt+"0"+CRLF
cCorpo += "                                    Where CT1_FILIAL = @cFilial"+CRLF
cCorpo += "                                      AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "                                   Group by CT1_CTASUP )"+CRLF
cCorpo += "         for read Only"+CRLF
cCorpo += "         Open CUR_CT1"+CRLF
cCorpo += "         Fetch CUR_CT1 into @iRecno"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         While @@Fetch_status = 0 begin"+CRLF
cCorpo += "            select @iNroRegs = @iNroRegs + 1"+CRLF
cCorpo += "            If @iNroRegs = 1 begin"+CRLF
cCorpo += "               Select @iNroRegs = @iNroRegs"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            If @IN_DELFISICO = '1' begin"+CRLF
cCorpo += "               Update CT1"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*'"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "               "+CRLF
cCorpo += "               delete CT1"+cEmpAnt+"0"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "               "+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update CT1"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            If @iNroRegs >= 1024 begin"+CRLF
cCorpo += "               Select @iNroRegs = 0"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Fetch CUR_CT1 into @iRecno"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "         Close CUR_CT1"+CRLF
cCorpo += "         deallocate CUR_CT1"+CRLF
cCorpo += "         If @iNroRegs > 0 begin"+CRLF
cCorpo += "            select @iTranCount = 0"+CRLF
cCorpo += "         End"+CRLF
         /*---------------------------------------------------------------
           Verifico se ainda existem registros a excluir no CT1
           --------------------------------------------------------------- */
cCorpo += "         Select @iRecno = 0"+CRLF
cCorpo += "         Select @iRecno = IsNull( R_E_C_N_O_,0)"+CRLF
cCorpo += "           From CT1"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CT1_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         If @iRecno = 0 begin"+CRLF
cCorpo += "            select @cExec = '0'"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF  //  -- While @cExec
cCorpo += "   End"+CRLF
cCorpo += "   "+CRLF
   /*---------------------------------------------------------------
     Exclui dados do CTT
     --------------------------------------------------------------- */
cCorpo += "   If @IN_TAB = 'CTT' begin"+CRLF
cCorpo += "      While @cExec = '1' begin "+CRLF
cCorpo += "         select @iNroRegs = 0"+CRLF
cCorpo += "         Declare CUR_CTT cursor for"+CRLF
cCorpo += "         Select R_E_C_N_O_"+CRLF
cCorpo += "           From CTT"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CTT_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            AND CTT_CUSTO NOT IN ( Select CTT_CCSUP"+CRLF
cCorpo += "                                     from CTT"+cEmpAnt+"0"+CRLF
cCorpo += "                                    Where CTT_FILIAL = @cFilial"+CRLF
cCorpo += "                                      AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "                                   Group by CTT_CCSUP )"+CRLF
cCorpo += "         for read Only"+CRLF
cCorpo += "         Open CUR_CTT"+CRLF
cCorpo += "         Fetch CUR_CTT into @iRecno"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         While @@Fetch_status = 0 begin"+CRLF
cCorpo += "            select @iNroRegs = @iNroRegs + 1"+CRLF
cCorpo += "            If @iNroRegs = 1 begin"+CRLF
cCorpo += "               Select @iNroRegs = @iNroRegs"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "	           "+CRLF
cCorpo += "            If @IN_DELFISICO = '1' begin"+CRLF
cCorpo += "               Update CTT"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*'"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "               "+CRLF
cCorpo += "                delete CTT"+cEmpAnt+"0"+CRLF
cCorpo += "               where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update CTT"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            If @iNroRegs >= 1024 begin"+CRLF
cCorpo += "               Select @iNroRegs = 0"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Fetch CUR_CTT into @iRecno"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "         Close CUR_CTT"+CRLF
cCorpo += "         deallocate CUR_CTT"+CRLF
cCorpo += "         If @iNroRegs > 0 begin"+CRLF
cCorpo += "            select @iTranCount = 0"+CRLF
cCorpo += "         End"+CRLF
         /*---------------------------------------------------------------
           Verifico se ainda existem registros a excluir no CT1
           --------------------------------------------------------------- */
cCorpo += "         Select @iRecno = 0"+CRLF
cCorpo += "         Select @iRecno = IsNull( R_E_C_N_O_,0)"+CRLF
cCorpo += "           From CTT"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CTT_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         If @iRecno = 0 begin"+CRLF
cCorpo += "            select @cExec = '0'"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF
cCorpo += "   End"+CRLF
   /*---------------------------------------------------------------
     Exclui dados do CTD
     --------------------------------------------------------------- */
cCorpo += "   select @cExec = '1'"+CRLF
cCorpo += "   If @IN_TAB = 'CTD' begin"+CRLF
cCorpo += "      While @cExec = '1' begin "+CRLF
cCorpo += "         select @iNroRegs = 0"+CRLF
cCorpo += "         Declare CUR_CTD cursor for"+CRLF
cCorpo += "         Select R_E_C_N_O_"+CRLF
cCorpo += "           From CTD"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CTD_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            AND CTD_ITEM NOT IN ( Select CTD_ITSUP"+CRLF
cCorpo += "                                     from CTD"+cEmpAnt+"0"+CRLF
cCorpo += "                                    Where CTD_FILIAL = @cFilial"+CRLF
cCorpo += "                                      AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "                                   Group by CTD_ITSUP )"+CRLF
cCorpo += "         for read Only"+CRLF
cCorpo += "         Open CUR_CTD"+CRLF
cCorpo += "         Fetch CUR_CTD into @iRecno"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         While @@Fetch_status = 0 begin"+CRLF
cCorpo += "            select @iNroRegs = @iNroRegs + 1"+CRLF
cCorpo += "            If @iNroRegs = 1 begin"+CRLF
cCorpo += "               Select @iNroRegs = @iNroRegs"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            If @IN_DELFISICO = '1' begin"+CRLF
cCorpo += "               Update CTD"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*'"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "               "+CRLF
cCorpo += "               delete CTD"+cEmpAnt+"0"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update CTD"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            If @iNroRegs >= 1024 begin"+CRLF
cCorpo += "               Select @iNroRegs = 0"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Fetch CUR_CTD into @iRecno"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "         Close CUR_CTD"+CRLF
cCorpo += "         deallocate CUR_CTD"+CRLF
cCorpo += "         If @iNroRegs > 0 begin"+CRLF
cCorpo += "            select @iTranCount = 0"+CRLF
cCorpo += "         End"+CRLF
         /*---------------------------------------------------------------
           Verifico se ainda existem registros a excluir no CT1
           --------------------------------------------------------------- */
cCorpo += "         Select @iRecno = 0"+CRLF
cCorpo += "         Select @iRecno = IsNull( R_E_C_N_O_,0)"+CRLF
cCorpo += "           From CTD"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CTD_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         If @iRecno = 0 begin"+CRLF
cCorpo += "            select @cExec = '0'"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF   //  -- While @cExec
cCorpo += "   End"+CRLF
   /*---------------------------------------------------------------
     Exclui dados do CTH
     --------------------------------------------------------------- */
cCorpo += "   select @cExec = '1'"+CRLF
cCorpo += "   If @IN_TAB = 'CTH' begin"+CRLF
cCorpo += "      While @cExec = '1' begin"+CRLF
cCorpo += "         select @iNroRegs = 0"+CRLF
cCorpo += "         Declare CUR_CTH cursor for"+CRLF
cCorpo += "         Select R_E_C_N_O_"+CRLF
cCorpo += "           From CTH"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CTH_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "            AND CTH_CLVL NOT IN ( Select CTH_CLSUP"+CRLF
cCorpo += "                                     from CTH"+cEmpAnt+"0"+CRLF
cCorpo += "                                    Where CTH_FILIAL = @cFilial"+CRLF
cCorpo += "                                      AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "                                   Group by CTH_CLSUP )"+CRLF
cCorpo += "         for read Only"+CRLF
cCorpo += "         Open CUR_CTH"+CRLF
cCorpo += "         Fetch CUR_CTH into @iRecno"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         While @@Fetch_status = 0 begin"+CRLF
cCorpo += "            select @iNroRegs = @iNroRegs + 1"+CRLF
cCorpo += "            If @iNroRegs = 1 begin"+CRLF
cCorpo += "               Select @iNroRegs = @iNroRegs"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            If @IN_DELFISICO = '1' begin"+CRLF
cCorpo += "               Update CTH"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*'"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "                "+CRLF
cCorpo += "               delete CTH"+cEmpAnt+"0"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end else begin"+CRLF
cCorpo += "               Update CTH"+cEmpAnt+"0"+CRLF
cCorpo += "                  set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"+CRLF
cCorpo += "                where R_E_C_N_O_ = @iRecno"+CRLF
cCorpo += "            end"+CRLF
cCorpo += "            "+CRLF
cCorpo += "            If @iNroRegs >= 1024 begin"+CRLF
cCorpo += "               Select @iNroRegs = 0"+CRLF
cCorpo += "            End"+CRLF
cCorpo += "            Fetch CUR_CTH into @iRecno"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "         Close CUR_CTH"+CRLF
cCorpo += "         deallocate CUR_CTH"+CRLF
cCorpo += "         If @iNroRegs > 0 begin"+CRLF
cCorpo += "            select @iTranCount = 0"+CRLF
cCorpo += "         End"+CRLF
         /*---------------------------------------------------------------
           Verifico se ainda existem registros a excluir no CT1
           --------------------------------------------------------------- */
cCorpo += "         Select @iRecno = 0"+CRLF
cCorpo += "         Select @iRecno = IsNull( R_E_C_N_O_,0)"+CRLF
cCorpo += "           From CTH"+cEmpAnt+"0"+CRLF
cCorpo += "          Where CTH_FILIAL = @cFilial"+CRLF
cCorpo += "            AND D_E_L_E_T_ = ' '"+CRLF
cCorpo += "         "+CRLF
cCorpo += "         If @iRecno = 0 begin"+CRLF
cCorpo += "            select @cExec = '0'"+CRLF
cCorpo += "         End"+CRLF
cCorpo += "      End"+CRLF    //  -- While @cExec
cCorpo += "   End"+CRLF
cCorpo += "   select @OUT_RESULTADO = '1'"+CRLF
cCorpo += "End"+CRLF

cQuery := cParam+cDeclare+cCorpo
cQuery := MsParse(cQuery,Alltrim(TcGetDB()))
cQuery := CtbAjustaP(.F., cQuery)

RestArea(aSaveArea)
Return (cQuery)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ChkCtbFileºAutor  ³Marcos S. Lobo      º Data ³  02/15/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua verificação/criação de arquivos com base no SM0      º±±
±±º          ³posicionado                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP -> CTB Consolidaçao                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChkCtbFile()
// ***ESTA FORA DE USO, NAO FOI IMPLEMENTADO NO BOPS, ESTAVA GERANDO ERRO EM FUNÇÃO DA RPCSETENV E DA REINICIALIZAÇÃO DE VARIAVEIS DE AMBIENTE***
Local nCtbF		:= 1
Local aCtbFiles	:= {"CT1","CT2","CT3","CT4","CT5","CT6","CT7","CT8","CT9","CTA","CTB","CTC","CTD","CTE","CTF","CTG","CTH",;
					"CTI","CTJ","CTK","CTL","CTM","CTN","CTO","CTP","CTQ","CTR","CTS","CTT","CTU","CTV","CTW","CTX","CTY",;
					"CTZ","CV1","CV2"}
Local lExecCheck:= .F.


If __nChkFile == 1 .and. !__lBlind
	If MsgYesNo(STR0043+CRLF+;//"A verificação de arquivos irá criar os arquivos nas empresas a consolidar caso não existam."
				STR0044+CRLF+;//"Esta verificação pode demorar vários minutos de acordo com a quantidade de empresas, porém,"
				STR0045+CRLF+CRLF+;//"é fortemente recomendada na primeira execução da consolidação."
				STR0046,STR0047)//"Executar verificação de arquivos antes da Consolidação ? "##"Verificação de arquivos..."
		__nChkFile := 2		/// Efetua verificação e não ira perguntar novamente (nesta execuçao)					
	Else
		__nChkFile := 3		///Não efetua verificação
	EndIf
EndIf

dbSelectArea("SM0")

If __nChkFile <= 2 
		
	nRegM0Atu := SM0->(Recno())
	RpcClearEnv()
	OpenSm0()	
	RpcSetType(3)
	SM0->(dbGoTo(nRegM0Atu))
	RpcSetEnv(SM0->M0_CODIGO, IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),,,,, aCtbFiles )

	/// Efetua abertura de todos os arquivos para garantir que estao criadas em todas as empresas.
	For nCtbF := 1 to Len(aCtbFiles)
		ChkFile(aCtbFiles[nCtbF],.F.)
		dbSelectArea(aCtbFiles[nCtbF])
	Next
	lExecCheck := .T.
Endif

Return(lExecCheck)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerIDProc ³ Autor ³ Marcelo Pimentel      ³ Data ³24.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
±±³          ³a stored procedure a variavel sera incrementada.            ³±±
±±³          ³Procedure CTB020                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function VerIDProc()
Return '012'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220InvSl³ Autor  ³ Marcelo Akama           ³ Data 14.05.10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Inverte a selecao validando                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220InvSl(aQuais)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = aQuais                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ct220InvSl(aArray)
Local nI

For nI:=1 to len(aArray)
	aArray:=Ct220Troca(nI, aArray, .T., .F.)
Next
Return aArray
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct220TpSaldo³ Autor  ³ 					    ³ Data 03.12.12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gerar os tipos de saldos contábeis numa string             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct220TpSaldo()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ caracter com tos tipos de saldo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ct220TpSaldo()
Local aArea    := GetArea()
Local aTpSaldo := {}
Local cChave   := ""

dbSelectArea("SX5")
dbSetOrder(1)
cChave := xFilial("SX5")+"SL"
If dbSeek(cChave)
	While !Eof() .and. cChave == SX5->X5_FILIAL + SX5->X5_TABELA
		If SX5->X5_CHAVE != "0" .and. SX5->X5_CHAVE != "9" // orcamento e pre-lancamento
			AADD( aTpSaldo, SX5->X5_CHAVE )
		EndIf
		dbSkip()
    EndDo
EndIf

RestArea(aArea)
Return(aTpSaldo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTB220Alt³ Autor  ³ 					     ³ Data 19/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Ponto de entrada permite alteração de valor e hist na gravação
				da tabela CT2                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctb220Alt()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ script (corpo da procedure)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB220Alt()
Local cProcAlt := ""
Local lRet := .T.
Local nRet := 0

cProcAlt := "Create procedure CTB220ALT_"+cEmpAnt+CRLF
cProcAlt += "("+CRLF
cProcAlt += "   @IN_FILIAL    Char( "+Str(TamSx3("CT2_FILIAL")[1])+" ),"+CRLF
cProcAlt += "   @IN_DATA      Char( "+Str(TamSx3("CT2_DATA")[1])  +" ),"+CRLF
cProcAlt += "   @IN_LINHA     Char( "+Str(TamSx3("CT2_LINHA")[1]) +" ),"+CRLF
cProcAlt += "   @IN_TPSALD    Char( "+Str(TamSx3("CT2_TPSALD")[1])+" ),"+CRLF
cProcAlt += "   @IN_EMPORI    Char( "+Str(TamSx3("CT2_EMPORI")[1])+" ),"+CRLF
cProcAlt += "   @IN_FILORI    Char( "+Str(TamSx3("CT2_FILORI")[1])+" ),"+CRLF
cProcAlt += "   @IN_MOEDLC    Char( "+Str(TamSx3("CT2_MOEDLC")[1])+" ),"+CRLF
cProcAlt += "   @IN_LOTE      Char( "+Str(TamSx3("CT2_LOTE")[1])  +" ),"+CRLF
cProcAlt += "   @IN_SBLOTE    Char( "+Str(TamSx3("CT2_SBLOTE")[1])+" ),"+CRLF
cProcAlt += "   @IN_DOC       Char( "+Str(TamSx3("CT2_DOC")[1])   +" ),"+CRLF
cProcAlt += "   @IN_HIST      Char( "+Str(TamSx3("CT2_HIST")[1])  +" ),"+CRLF
cProcAlt += "   @IN_VALOR     Float,"+CRLF
cProcAlt += "   @OUT_HIST     Char( "+Str(TamSx3("CT2_HIST")[1])  +" ) OutPut,"+CRLF
cProcAlt += "   @OUT_VALOR    float OutPut"+CRLF
cProcAlt += "   )"+CRLF

cProcAlt += "as"+CRLF
cProcAlt += "Declare @cHist  Char( "+Str(TamSx3("CT2_HIST")[1])+ " )"+CRLF
cProcAlt += "Declare @nValor Float"+CRLF

cProcAlt += "begin"+CRLF
   /* Tratameto de valores e histórico */
   
cProcAlt += "   select @OUT_HIST  = @IN_HIST"+CRLF
cProcAlt += "   select @OUT_VALOR = @IN_VALOR "+CRLF
cProcAlt += "   "+CRLF
cProcAlt += "end"+CRLF

cProcAlt := MsParse(cProcAlt,Alltrim(TcGetDB()))

If !TCSPExist( cProcAlt )
	nRet := TcSqlExec(cProcAlt)
	If nRet < 0
	   	If !__lBlind
   			MsgAlert(STR0021+" "+cProcAlt,"Ponto de Entrada")  //'Erro na criacao da procedure'
   		EndIf
		lRet := .f.
	EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} CloseCTB220
(Fecha todas das tabelas de usuario)
@author vitor.pires
@since 05/02/2016
@version 1.0
@return ${Nil}, ${Nil}
@example
/*/
Static Function CloseCTB220()
Local aFecha	:= {"CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CQ8","CQ9","CT0","CT1","CT2","CT3","CT4","CT5","CT6","CT7","CTC","CTD","CTF","CTG","CTH","CTI","CTK","CTO","CTP","CTT","CTU","CTV","CTW","CTX","CTY","CTZ","CV1","CV2","CV3","CV8","CVA","CVG","CVJ","CVX","CVY","CVZ","CW0","INTEGR","CT220DEL","AGLUTINA","MAXRECNO","TRB"}
Local nIx		:= 1

For nIx := 1 TO Len(aFecha)
	cAliasFecha := aFecha[nIx]
	
	If !Empty(cAliasFecha) .And. Select(cAliasFecha) > 0
		(cAliasFecha)->(DbCloseArea())
	Endif
Next nIx 
	
DbSelectArea("SX2")

Return(Nil)

/*  Novo Processo Procedure - Processo 03
/{Protheus.doc} EngPos03Compile
Funcao executada após a compilacao da procedure (Pos-Compile)
@type function
@version 1.0
@author Squad Control
@since 08/11/
@param cProcesso, character, Codigo do processo
@param cEmpresa, character, Codigo da empresa
@param cProcName, character, Nome da stored procedure
@param cLocalDB, character, Nome do Banco de Dados
@param cBuffer, character, Codigo original da procedure (corpo da procedure)
@param cError, character, Passada por referencia, deve conter a mensagem de erro caso ocorra
@return logical, .T. caso tudo ok
/*/
// Processo 03 - CONSOLIDAÇÃO GERAL DE EMPRESAS
Function EngPos03Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)

	Do Case

		Case cLocalDB == DEF_DB_INFORMIX

			If cProcName $ "CTB211"
				cBuffer := StrTran(cBuffer, "GROUP BY CT2_FILIAL , SUBSTR ( CT2_DATA , 1 , 6 )", "GROUP BY CT2_FILIAL , 2")
			EndIf

			If cProcName $ "CTB021/CTB230/CTB232"
				cBuffer := StrTran(cBuffer, "GROUP BY CQ1_FILIAL , CQ1_CONTA , CQ1_MOEDA , SUBSTR ( CQ1_DATA , 1 , 6 )", "GROUP BY CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, 4")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ3_FILIAL , CQ3_CONTA , CQ3_CCUSTO , CQ3_MOEDA , SUBSTR ( CQ3_DATA , 1 , 6 )", "GROUP BY CQ3_FILIAL, CQ3_CONTA ,CQ3_CCUSTO, CQ3_MOEDA, 5")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ5_FILIAL , CQ5_CONTA , CQ5_CCUSTO , CQ5_ITEM , CQ5_MOEDA , SUBSTR ( CQ5_DATA , 1 , 6 ), CQ5_DTLP , CQ5_LP", "GROUP BY 1, 2 ,3, 4 , 5, 6,7,8")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ7_FILIAL , CQ7_CONTA , CQ7_CCUSTO , CQ7_ITEM , CQ7_CLVL , CQ7_MOEDA , SUBSTR ( CQ7_DATA , 1 , 6 ), CQ7_DTLP , CQ7_LP", "GROUP BY 1, 2, 3, 4, 5, 6, 7,8,9")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ9_FILIAL , CQ9_IDENT , CQ9_CODIGO , CQ9_MOEDA , SUBSTR ( CQ9_DATA , 1 , 6 )", "GROUP BY CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, 5")
			EndIf

			If cProcName == "CTB209"
				cBuffer := StrTran(cBuffer, "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , SUBSTR ( CVX_DATA , 1 , 6 )", "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , 5")
			EndIf

		Case cLocalDB == DEF_DB_POSTGRES

			If cProcName $ "CTB211"
				cBuffer := StrTran(cBuffer, "GROUP BY CT2_FILIAL , SUBSTR ( CT2_DATA , 1 , 6 )", "GROUP BY CT2_FILIAL , 2")
			EndIf

			If cProcName $ "CTB021/CTB230/CTB232"
				cBuffer := StrTran(cBuffer, "GROUP BY CQ1_FILIAL , CQ1_CONTA , CQ1_MOEDA , SUBSTR ( CQ1_DATA , 1 , 6 )", "GROUP BY CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, 4")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ3_FILIAL , CQ3_CONTA , CQ3_CCUSTO , CQ3_MOEDA , SUBSTR ( CQ3_DATA , 1 , 6 )", "GROUP BY CQ3_FILIAL, CQ3_CONTA ,CQ3_CCUSTO, CQ3_MOEDA, 5")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ5_FILIAL , CQ5_ITEM , CQ5_CCUSTO , CQ5_CONTA , CQ5_MOEDA , SUBSTR ( CQ5_DATA , 1 , 6 )", "GROUP BY CQ5_FILIAL, CQ5_ITEM ,CQ5_CCUSTO, CQ5_CONTA , CQ5_MOEDA, 6")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ7_FILIAL , CQ7_CLVL , CQ7_ITEM , CQ7_CCUSTO , CQ7_CONTA , CQ7_MOEDA , SUBSTR ( CQ7_DATA , 1 , 6 )", "GROUP BY CQ7_FILIAL, CQ7_CLVL, CQ7_ITEM, CQ7_CCUSTO, CQ7_CONTA, CQ7_MOEDA, 7")
				cBuffer := StrTran(cBuffer, "GROUP BY CQ9_FILIAL , CQ9_IDENT , CQ9_CODIGO , CQ9_MOEDA , SUBSTR ( CQ9_DATA , 1 , 6 )", "GROUP BY CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, 5")
			EndIf
			
			If cProcName == "CTB209"
				cBuffer := StrTran(cBuffer, "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , SUBSTR ( CVX_DATA , 1 , 6 )", "GROUP BY CVX_FILIAL , CVX_CONFIG , CVX_MOEDA , CVX_TPSALD , 5")
			EndIf
			/*----------------------------------------------------------------------------------------------
		 		Efetua tratamento para o POSTGRES substitui somente se a declaracao da variavel fim_CUR ocorreu
		 	----------------------------------------------------------------------------------------------*/
			If At("fim_CUR INTEGER default 0;",cBuffer) >0
				cBuffer	:= StrTran( cBuffer, 'vfim_CUR  := 0 ;', 'fim_CUR  := 0 ;' )
			EndIf
		Case cLocalDB == DEF_DB_DB2 .or. cLocalDB == DEF_DB_MYSQL
			/*------------------------------------------------
			 Efetua tratamento para o DB2 / MySQL
			------------------------------------------------*/
			cBuffer	:= StrTran( cBuffer, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
			cBuffer	:= StrTran( cBuffer, "IF fim_CUR <> 1 THEN", "IF fim_CUR = 1 THEN")
		
	EndCase

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS03Signature
Processo 03 - CONSOLIDAÃ‡ÃƒO GERAL DE EMPRESAS
Funções executadas durante a exibição de informações detalhadas 
do processo na interface de gestão de procedures.
Faz a execução de funções STATIC proprietárias das rotinas donas 
dos processos.

@return cAssinatura
@author  TOTVS
@since   13/12/2021
@version 12
/*/
//-------------------------------------------------------------------
Function EngSPS03Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := STATICCALL(CTBA220,VERIDPROC)

Return cAssinatura
