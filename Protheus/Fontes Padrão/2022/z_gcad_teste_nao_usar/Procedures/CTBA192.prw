#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA192.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres
Static nJOBS
Static lFWCodFil := FindFunction("FWCodFil")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA192   บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reprocessamento de saldos por conta.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA192(aParams)                     
Local aSays 	  := {}                        		
Local aButtons    := {}
Local nOpcA		  := 0
Local cPerg		  := "CTB192"
Local dDataIni
Local dDataFim                            		
Local cFilDe
Local cFilAte
Local cTpSald
Local lMoedaEsp	
Local cMoeda	
Local cContaDe
Local cContaAte
Local aCtbMoeda
Local nMoedaIni
Local nMoedaFim
Local cArquivo
Local cArqLog
Local aEstrut := {}
Local nX	:=	0
Local lRet	:=	.T.
Local lRetDoc	:=	.F.
Local lAbortou := .F.
Local lCT192Pos  := (ExistBlock("CT192POS"))
Local dDtAux
Local aGestEmp := {}
Local nI
Local lCompart := .F.

Private cCadastro := STR0001 //"Reprocessamento"
Private aListaJob :={}  // lista de jobs carregados
Private lAuto		:=	Nil
Private nTipoLog	:=	1
Private lEnded192	:=	.F.

Default	aParams := {}


lAuto := IsBlind() .OR. Len(aParams) > 0

// seta o numero de jobs para a Rotina
nJOBS :=  GetNewPar( 'MV_CTB192J' , 2 )
//nJOBS := 1

AjtSx1_192()

CriaTabLog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a tela de abertura/parametros							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(cPerg,.F.)

ProcLogIni({} ,'CTBA192')

If !( Alltrim(Upper(TcSrvType())) != "AS/400" .and.  Alltrim(Upper(TCGetDb())) $ "MSSQL|MSSQL7|ORACLE|DB2|DB2/400")
	ProcLogAtu("ERRO","NOEXEC",STR0063)

	If lAuto
		Help(" ",1,"NOEXEC",,STR0063,3,0)
	Endif
	
	Return()
Endif 

If IsCtbJob() // se tem o schedule da CTBA193 criado
	// Atualiza o log de processamento com o erro		
	ProcLogAtu("ERRO","NOEXEC","Rotina de atualiza็ใo de saldos por schedule em execu็ใo. Pare a execu็ใo do schedule para continuar.")
	
	If lAuto
		Help(" ",1,"NOEXEC",,"Rotina de atualiza็ใo de saldos por schedule em execu็ใo. Pare a execu็ใo do schedule para continuar.",3,0)
	Endif

	Return
Endif

If !lAuto
	aAdd(aSays,STR0002 )   //"Este programa tem como objetivo recalcular os saldos de um determinado periodo."
	aAdd(aSays,STR0003 )   //"Devera ser utilizado caso haja necessidade de se recalcular os saldos das entidades contabeis."
//	aAdd(aSays,STR0004 )   //"O Reprocessamento podera ser efetuado a partir da data do ultimo fechamento contabil ou a partir"
//	aAdd(aSays,STR0005 )   //"de uma data informada."
	aAdd(aSays,STR0006 )   //"Aten็ใo: Esta rotina nใo efetua o recalculo de saldos compostos."
		
	aAdd(aButtons, { 15,.T.,{|| ProcLogView(cFilAnt, "CTBA192")} } )
	aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{|| nOpca:= 1, If( CTBOk(), FechaBatch(), nOpca:=0 ) }} )
	aAdd(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons,, 220, 560 )
Else
	If aParams <> Nil
		For nX:=1 To Len(aParams)
			&("mv_par"+Strzero(nX,2))	:=	aParams[nX]
		Next
	Endif
	nOpcA :=	1
Endif

If nOpcA == 1        
	nTipoLog	:=	mv_par11
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAuto
		ConOut( STR0007+ Dtoc(Date())+"-"+Time() )   //"INICIO CTBA192 : "
	Endif

	CTB192Proc( nTipoLog, STR0008 )  //"INICIO"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz primeiro as validacoes									 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	// Nova opcao
	If mv_par01 == 2
		CTB192Proc( nTipoLog, STR0010,STR0009 )	//"ERRO" ,"Reprocessa a partir do ๚ltimo fechamento nใo estแ disponํvel." 

		If lAuto
			Help(" ",1,"NOEXEC",,STR0009,3,0)// "Reprocessa a partir do ๚ltimo fechamento nใo estแ disponํvel."
		Endif

		lRet	:=	 .F.
	EndIf
	
	// Verifica se as datas foram preenchidas
	If lRet	.And. (Empty(mv_par02) .Or. Empty(mv_par03))
		CTB192Proc( nTipoLog, STR0010,STR0011)   //"ERRO","Campos de data nao preenchidos."
		
		If lAuto
			Help(" ",1,"CTB190DATA")
		Endif

		lRet	:=	 .F.	
	EndIf     
	
	// Valida calendario
	If lRet .and. !VlDtCal(mv_par02,mv_par03,mv_par07,mv_par08)	               
		CTB192Proc( nTipoLog, STR0010,STR0012) //"ERRO","Configuracoes invalidas para os calendarios disponiveis"

		If lAuto
			Help(" ",1,"NOEXEC",,STR0012,3,0)// "Reprocessa a partir do ๚ltimo fechamento nใo estแ disponํvel."
		Endif

		lRet	:=	 .F.
	Endif
                  
    // Valida tipo de saldo
	If lRet	.And. Empty(mv_par06)
		CTB192Proc( nTipoLog, STR0010,STR0013)  //"ERRO", "Tipo de saldo vazio"

		If lAuto
			Help(" ",1,"CT2_TPSALD")
		Endif

		lRet	:=	 .F.	
	EndIf

    // Valida tipo de saldo (somente 192)
	If lRet	.And. (mv_par06 == "*" .And. mv_par06 == "0")
		CTB192Proc( nTipoLog, STR0010,STR0014) // "ERRO","Tipo de saldo nao permitido nesta rotina."

		If lAuto
			Help(" ",1,"NOEXEC",,STR0014,3,0)// "Reprocessa a partir do ๚ltimo fechamento nใo estแ disponํvel."
		Endif

		lRet :=	.F.	
	EndIf

	If lRet
		cFilDe		:= mv_par04
		cFilAte		:= mv_par05
		
		//aGestEmp = Array que guarda o compartilhamento da tabela CT2
		//Posi็ใo 1 = Compartilhamento | Posi็ใo 2 = Nํvel
		//Nivel 1 = Empresa, Nivel 2 = Unidade de Neg๓cio e Nivel 3 = Filial)
		
		For nI := 1 to 3
			AAdd(aGestEmp, {FWModeAccess("CT2", nI), nI})
		Next nI

		// Verificar se ้ totalmente exclusiva
		For nI := 1 to 3
			If aGestEmp[nI,1] == "C"
				lCompart := .T.
				Exit
			Else
				lCompart := .F.
			EndIf
		Next nI

		//Se CT2 e compartilhado, so procesar a filial atual.
		If lCompart
			cFilDe	:=	IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			cFilAte	:=	IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
		Endif		
	
		dDataIni	:= mv_par02
		dDataFim	:= mv_par03
		cTpSald		:= mv_par06
		lMoedaEsp	:= Iif(mv_par07 == 1, .F., .T.)
		cMoeda		:= mv_par08
		cContaDe    := MV_PAR09
		cContaAte	:= MV_PAR10    
	
		// Tratamento da moeda especifica
		If lMoedaEsp					
			
			aCtbMoeda := CtbMoeda(cMoeda)
			If Empty(aCtbMoeda[1])
				If lAuto
					Help(" ",1,"NOMOEDA")
				Endif

				Return Nil
			EndIf                  
			
			nMoedaIni := val(cMoeda)
			nMoedaFim := val(cMoeda)
		Else
			nMoedaIni	:= 1
			nMoedaFim	:= __nQuantas
		EndIf

		If lRet

			//-----------------------------------------------------------------------------
			// Trava de controle de acesso para quando houver JOB e chamada direta CTBA351
			//-----------------------------------------------------------------------------
			If Ctba192Lock()

				//garantizar qeu as tabelas existam para nao dar erro na procedure
				DbSelectArea('CQ0')

				cQryCta	:=	" SELECT DISTINCT FILIAL, CONTA  FROM ( "
				cQryCta	+=	"    SELECT DISTINCT CQ0_FILIAL FILIAL, CQ0_CONTA CONTA  FROM "+RetSqlName("CQ0")+" CQ0 " 
				If Empty(xFilial('CQ0'))
					cQryCta	+=	"       WHERE CQ0.CQ0_FILIAL = ' '"
				Else
					cQryCta	+=	"       WHERE CQ0.CQ0_FILIAL BETWEEN '"+XFilial("CQ0",cFilDe) +"' AND '"+XFilial("CQ0",cFilAte)+"' "
				Endif
				cQryCta	+=	"         AND CQ0.CQ0_CONTA BETWEEN '"+cContaDe+"' AND '"+cContaAte+"' "
				cQryCta	+=	"         AND CQ0.CQ0_DATA BETWEEN   '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
				cQryCta	+=	"         AND CQ0.D_E_L_E_T_ = ' ' "                     
				cQryCta	+=	"    UNION"
				cQryCta	+=	"    SELECT DISTINCT  CT2_FILIAL FILIAL, CT2_DEBITO CONTA  FROM "+RetSqlName("CT2")+" CT2 " 
				If Empty(xFilial('CT2'))
					cQryCta	+=	"       WHERE CT2.CT2_FILIAL = ' '"
				Else
					cQryCta	+=	"       WHERE CT2.CT2_FILIAL BETWEEN '"+XFilial("CT2",cFilDe) +"' AND '"+XFilial("CT2",cFilAte)+"' "
				Endif
				cQryCta	+=	"         AND CT2.CT2_DEBITO BETWEEN '"+cContaDe+"' AND '"+cContaAte+"' "
				cQryCta	+=	"         AND CT2.CT2_DATA   BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
				cQryCta	+=	"         AND CT2.CT2_DC IN ('1','3') "
				cQryCta	+=	"         AND CT2.D_E_L_E_T_ = ' ' "                     
				cQryCta	+=	"    UNION"
				cQryCta	+=	"    SELECT DISTINCT CT2_FILIAL FILIAL, CT2_CREDIT CONTA  FROM "+RetSqlName("CT2")+" CT2 " 
				If Empty(xFilial('CT2'))
					cQryCta	+=	"       WHERE CT2.CT2_FILIAL = ' '"
				Else
					cQryCta	+=	"       WHERE CT2.CT2_FILIAL BETWEEN '"+XFilial("CT2",cFilDe) +"' AND '"+XFilial("CT2",cFilAte)+"' "
				Endif
				cQryCta	+=	"         AND CT2.CT2_CREDIT BETWEEN '"+cContaDe+"' AND '"+cContaAte+"' "
				cQryCta	+=	"         AND CT2.CT2_DATA   BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
				cQryCta	+=	"         AND CT2.CT2_DC IN ('2','3') "
				cQryCta	+=	"         AND CT2.D_E_L_E_T_ = ' ' "                     
				cQryCta	+=	" ) A "                     
				cQryCta	+=	" ORDER BY FILIAL, CONTA "   
            
				cQryCta	:=	ChangeQuery(cQryCta)                     
				cNextAlias	:=	CriaTrab(,.F.)

				If Select( cNextAlias ) > 0
					(cNextAlias)->( dbCloseArea() )
				EndIf

				MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryCta), cNextAlias, .F., .T.)},'Executando query','Selecionando contas a processar...')

				TCRefresh( cNextAlias )
				DbSelectArea(cNextAlias)
				aFils	:=	{}

				//Caso haja algum compartilhamento, gravar em aFils o c๓digo completo da filial

				If !lCompart
					While !Eof()
						If (nPosFil:=Ascan(aFils,{|x| x[1]==FILIAL})) > 0
							Aadd(aFils[nPosFil,2], CONTA)
						Else
							Aadd(aFils,{FILIAL,{CONTA}})
						Endif
						DbSelectArea(cNextAlias)
						DbSkip()
					Enddo
				Else
					While !Eof()
						If (nPosFil:=Ascan(aFils,{|x| x[1]==cFilDe})) > 0
							Aadd(aFils[nPosFil,2], CONTA)
						Else
							Aadd(aFils,{cFilDe,{CONTA}}) //Utilizando a variavel cFilDe pois em caso de compartilhamento, s๓ sera processada a filial atual
						Endif
						DbSelectArea(cNextAlias)
					DbSkip()
					Enddo
				EndIf
							
				dbCloseArea()
				lAbortou	:=	.F.	           
				aDados1	:= Array(Len(aFils))
				// Processa todo o arquivo de filiais ou apenas a filial atual
				If Len(aFils) > 0
					SM0->( MsSeek( cEmpAnt + RTrim(aFils[1,1]) , .T. ) )
					lAbortou	:=	AguardJOB(@aDados1,cArquivo,cArqLog,dDataIni,dDataFim,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,aFils,Nil,cContaDe,cContaAte,cFilAte, mv_par11, cFilDe )
				Endif

				If lAbortou
					dDtAux := dDataIni
					For nx := nMoedaIni to nMoedaFim
						If GetCV7Date(cTpSald,StrZero(nx,2,0)) < dDataIni 
							dDataIni := GetCV7Date(cTpSald,StrZero(nx,2,0))+1
						EndIf
						PutCV7Date(cTpSald,StrZero(nx,2,0),dDataFim)
					Next nx
					dDataIni := dDtAux // Retorno a dataini para nใo afetar o ponto de entrada abaixo 
				EndIf

				//----------------------------------------------------------------------------------------------------------------------------
				// O ponto de entrada CT192POS possibilita outros processamentos ap๓s o t้rmino dos jobs de reprocessamento da rotina CTBA192
				//----------------------------------------------------------------------------------------------------------------------------
				If lCT192Pos
					CTB192Proc( nTipoLog, STR0027,"Executando ponto de entrada CT192POS.")
					ExecBlock("CT192POS",.F.,.F.,{cFilDe,cFilAte,dDataIni,dDataFim,lMoedaEsp,cMoeda,cTpSald})
				Endif

				//----------------------------------------------------
				// efetuo a libera็ใo da rotina para outras execu็๕es
				//----------------------------------------------------
				Ctba192UnLock()

			Else
				lRet := .F.
			EndIf

		EndIf

	Endif
EndIf

aListaJob :={}  // zera a quantidade de jobs startados

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCriaTMP   บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria um arquivo temporario com as contas que serao lidas   บฑฑ
ฑฑบ          ณ pelo JOB.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaTMP(aFils)
Local cArquivo  := C192RetArq()
Local nPosFil	:= 0
Local nX		:= 0

For nPosFil := 1 To Len(aFils)
	For nX := 1 To Len(aFils[nPosFil,2])
		dbSelectArea("TMPCTA")
		RecLock("TMPCTA",.T.)
		REPLACE TMPCTA->FILPROC  WITH aFils[nPosFil,1]
		REPLACE TMPCTA->CONTA  	 WITH aFils[nPosFil,2,nX]
		REPLACE TMPCTA->SITUAC	 WITH "1" //1 = PENDENTE, 2=PROCESSAMENTO OK, 3=ERRO NA EXECUCAO
		REPLACE TMPCTA->VEZES  	 WITH 0
		REPLACE TMPCTA->ARQUIVO	 WITH cArquivo
		MsUnLock()
	Next
Next nPosFil
dbSelectArea("TMPCTA")

Return cArquivo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณChamaJOB  บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de chamada e controle de execucao dos JOBS.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChamaJOB(cArquivo,cArqLog,dDataIni,dDataFim,cFilProc,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,cMoedaEsp)
Local nX
Local cNomeJob   := ""

// Variaveis passadas como parametro para a chamada da procedure
Local lCusto	 := CtbMovSaldo("CTT")
Local lItem		 := CtbMovSaldo("CTD")
Local lCLVL		 := CtbMovSaldo("CTH")				
Local nFKInUse	 := 0
Local lDelFisico :=	GetNewPar('MV_CTB190D',.T.) 
Local cQuery	 := ""
Local cMV_SOMA := StrZero(Getmv("MV_SOMA"),1)

ProcRegua(nJOBS+1)

aListaJob	:=	{}

If lMoedaEsp
	cMoedaEsp := '1'
	cMoeda := cMoeda
Else
	cMoedaEsp := '0'
	cMoeda := '00'
EndIf

// Verifica se a integridade referencial esta ativa                          
If TcSrvType() != "AS/400"
	cQuery := "SELECT count(*) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" +  SM0->M0_CODIGO + "'"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'INTEGR', .F., .T.)
	nFKInUse := INTEGR->TOTAL
	INTEGR->( dbCloseArea() )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa os JOBS de processamento							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TMPCTA->( dbGotop() )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Le o arquivo temporario de contas para processamento         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nX := 1 TO nJOBS        			

	cNomeJob := Upper("JobCTB" + AllTrim( Str(nX) ) + "_TMPCTA")
	IncProc(STR0015+cNomeJob)     //"Iniciando Job "
	If !IsThreadOn(Val(GetGlbValue(cNomeJob+"_ID")) )
		// Inicializa variavel global de controle do Job
		// 0 = nao subiu ainda
		PutGlbValue( cNomeJob , "0" )
			
		aAdd(aListaJob,{cNomeJob,'0'})   						
		StartJob( "JOB192", GetEnvServer(), .F., { {.F., cEmpAnt , cFilProc , cNomeJob, cArquivo, cArqLog,dDataIni,dDataFim,cTpSald,cMoeda,cMoedaEsp,lCusto,lItem,lCLVL,nFKInUse,lDelFisico,nX,nJOBS,cUserName,nTipoLog, cMV_SOMA }} )
		// habilitar as 2 linhas abaixo para debugar e comentar a de cima
     	//JOB192({                                  {.T., cEmpAnt , cFilProc , cNomeJob, cArquivo, cArqLog,dDataIni,dDataFim,cTpSald,cMoeda,cMoedaEsp,lCusto,lItem,lCLVL,nFKInUse,lDelFisico,nX,nJOBS,cUserName ,nTipoLog, cMV_SOMA }})  //1
		//Exit
		Sleep(200)
	Else
		aAdd(aListaJob,{cNomeJob,"2"})   						
	EndIf			
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o JOB esta no "ar" 							           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Sleep( 500 * Len( aListaJob ))

IncProc( STR0016 ) //"Verificando status dos Jobs..."
// verifica o status dos jobs

RETURN JOBSTATUS()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณJobStatus บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION JOBSTATUS(nQuantos)
LOCAL nX
Local lCont      := .T.
Local nVezesAbre := 0
Local nVezesCon	 := 0
Local aJobOk	 := {}
Local aJOBAB	 := {}
Local nJobCaidos	:=	0
DEFAULT nQuantos	:=	1
If !lEnded192
	For nX := 1 To Len( aListaJob )
		lCont 		:= .T.
		nVezesAbre  := 1
		nVezesCon	:= 1
		
		While lCont
			Do Case
				// Verifica se o Job subiu
				Case GetGlbValue(aListaJob[nX][1]) == '0'
					If nVezesAbre >= 50
							CTB192Proc( nTipoLog,STR0017,STR0018+aListaJob[nX][1])  //"ALERTA","Nao foi possivel subir: "
						lCont := .F.
					Else
						nVezesAbre++
					EndIf
					
					// Verifica se conseguiu se conectar
				Case GetGlbValue(aListaJob[nX][1]) == '1'
	
					If nVezesCon >= 10
						CTB192Proc( nTipoLog,STR0010,STR0019+aListaJob[nX][1]+STR0020)  //"ERRO","Erro de conexao: ",". Numero de tentativas excedido."
						lCont := .F.
					Else
						// Inicializa variavel global de controle de Job
						PutGlbValue(aListaJob[nX][1],"0")
			
						// Reinicia o JOB para tentar conectar novamente
							CTB192Proc( nTipoLog,STR0017,STR0021+aListaJob[nx][1]+STR0022+StrZero(nVezesCon,2)+STR0023)  //"ALERTA","Erro de conexao: ",". Tentativa numero: ",". Nova tentativa sera realizada."
					EndIf
					nVezesCon++
					Sleep(1000)
					
				// Verifica se o Job estแ no ar
				Case GetGlbValue(aListaJob[nX][1]) == '2'
					If !IsThreadOn(Val(GetGlbValue(aListaJob[nX][1]+"_ID")) )
							CTB192Proc( nTipoLog,STR0010,STR0024+aListaJob[nX][1]+ STR0025)  //"ERRO","O JOB "," caiu."
						nJobCaidos++  
						lCont := .F.
	   			Else
						aAdd(aJOBAB ,aListaJob[nX][1])
						lCont := .F.
	   			Endif		
				// Verifica se o Job foi finalizado com sucesso
				Case GetGlbValue(aListaJob[nX][1]) == '3'
					aAdd(aJOBOK ,aListaJob[nX][1])
					lCont := .F.
				Otherwise
					CTB192Proc( nTipoLog,STR0010,STR0026+aListaJob[nX][1]+" = ["+GetGlbValue(aListaJob[nX][1])+"]")  //"ERRO","Status Inesperado: "
					lCont := .F.
			EndCase
		EndDo
	Next
	
	CTB192Proc( nTipoLog,STR0027,STR0028 + StrZero( Len( aJOBAB ),2 )+"/"+StrZero( Len( aJOBOK ),2  )+"/"+StrZero( nJobcaidos,2  )+"..."  ) //"MENSAGEM","Verificao de status de JOBS - NO AR/FINALIZADOS/QUEDAS.: "
	
	ConOut( STR0028 + StrZero( Len( aJOBAB ),2 )+"/"+StrZero( Len( aJOBOK ),2  )+"/"+StrZero( nJobcaidos,2  )+"..."  )  //"Verificao de status de JOBS - NO AR/FINALIZADOS/QUEDAS.: "
	
Endif	

Return ( lEnded192 .Or. Len( aJOBAB ) >= nQuantos )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAguardJob บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AguardJOB(aDados1,cArquivo,cArqLog,dDataIni,dDataFim,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,aFils,aParams,cContaDe,cContaAte,cFilAte,cPMvpar11,cFilDe)
Local oTimer
Local nTimeOut := GetNewPar( 'MV_CTB192T' , 3000 )

Local oBrowse1
Local aCpoTit1  := { STR0029, STR0030, STR0031, STR0032, STR0033, STR0034, STR0035, STR0036, STR0037}
 //"Filial","Data Inicio", "Hora Inicio","Total","Processadas","% Realizado","Tempo","Restante","Estimativa"
Local aCampos1	:= {}
Local aCpoCols1	:= { 040, 040, 040,040,040,040,040,040,040}

Local oBrowse2
Local aDados2 := {}
Local aCpoTit2  := { STR0038, STR0029, STR0039, STR0040, STR0041} //"Job", "Filial","Conta","Hora Inicio","Status processamento"
Local aCampos2  := {}
Local aCpoCols2 := {   080,     040,     040,           040,060 }
Local nX
Local oDlg	
Local lFinal	:=	.F.
Local lNextFil	:=	.F.
Local nQtdCta	:=	0
Local cFilAtu  := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local cFil  := xFilial("CT2",cFilAtu)
	
Local oMeter1,oMeter2
Local nPosFilAtu	:=	0
Local cSQLExec      := ""

// Cria o arquivo temporario de contas para ser usado pelos JOBS
MsAguarde({|| cArquivo := CriaTMP(aFils)},STR0042, STR0043)   //"Aguarde","Criando arquivo com as contas a processar..."


//Inicia a primeira filial
//IniProcFil(SM0->M0_CODFIL,@cArquivo,@cArqLog,dDataIni,dDataFim,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,cContaDe,cContaAte,aFils)

Processa({|| ChamaJOB( cArquivo,cArqLog,dDataIni,dDataFim,cFil,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim)},STR0044)   //"Iniciando Jobs de processamento ..."

nQtdCta	:=	Len(aFils[1,2])
nTotCta	:=	TMPCTA->(RecCount())

If !lAuto
	//Abre a tela para controle
	DEFINE MSDIALOG oDlg TITLE STR0045 From 1,1 To 25,95 OF oMainWnd //"Monitor do Processamento"
	
	aDados1 := aClone(CarregDad1(cArquivo, aFils,aDados1))
	//aDados2 := aClone(CarregDad2(cArquivo))
	If Len(aDados1) == 0
		Aadd(aDados1,{"","", "","","","","","",""})	
	Endif
	oBrowse1 := TWBrowse():New( 010, 005, 362, 050 , {|| { aCampos1 } }, aCpoTit1, aCpoCols1, oDlg, , , ,,,,,,,,,,"CT1", .T. )
	oBrowse1:SetArray(aDados1)
	//Filiais
	@ 065,08  METER oMeter1 VAR nTotCta TOTAL 10 SIZE 350, 10 OF oDlg BARCOLOR GetSysColor(13),GetSysColor() PIXEL
	oMeter1:nTotal := nTotCta
	oMeter1:Set(0)
	//Contas
	@ 080,08  METER oMeter2 VAR nQtdCta TOTAL 10 SIZE 350, 10 OF oDlg BARCOLOR GetSysColor(13),GetSysColor() PIXEL                                                                                                            
	oMeter2:nTotal := nQtdCta
	oMeter2:Set(0)
	
	oBrowse1:bLine := { || {aDados1[oBrowse1:nAt,1],aDados1[oBrowse1:nAt,2],aDados1[oBrowse1:nAt,3],aDados1[oBrowse1:nAt,4],aDados1[oBrowse1:nAt,5],aDados1[oBrowse1:nAt,6],aDados1[oBrowse1:nAt,7],aDados1[oBrowse1:nAt,8],aDados1[oBrowse1:nAt,9]}}
	oBrowse1:LHSCROLL := .F. 
	
	oBrowse2 := TWBrowse():New( 095, 005, 362, 065 , {|| { aCampos2 } }, aCpoTit2, aCpoCols2, oDlg, , , ,,,,,,,,,,"TMPCTA", .T. )
	For nX:= 1 To Len(aListaJob)
//		Aadd(aDados2,{aListaJob[nX,1],If(Empty(xFilial("CT2",cFilAtu)),"  ", IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )),'','',''})
		Aadd(aDados2,{aListaJob[nX,1],If(Empty(xFilial("CT2",cFilAtu)),Space(Len(xFilial("CT2"))), IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )),' ',' ',' '})
	Next                          
	oBrowse2:SetArray(aDados2)
	oBrowse2:bLine := { || {aDados2[oBrowse2:nAt,1],aDados2[oBrowse2:nAt,2],aDados2[oBrowse2:nAt,3],aDados2[oBrowse2:nAt,4],aDados2[oBrowse2:nAt,5]}}
	oBrowse2:LHSCROLL := .F. 
	
	//O timer atualiza a tela e controla se acabou a filial atual.
	//Se acabou e tem mais uma, fecha o dialog para porcessar a proxima filial
	//Se acabou e era a ultima, deixa o DIALOG aberto para o usuario confirmar.
	oTimer:= TTimer():New(nTimeOut,{|| If(!lEnded192,CheckProc(@cArquivo, oBrowse1,oBrowse2,aDados1,aDados2,aFils,cContaDe,cContaAte,cFilAte,@cArqLog,dDataIni,dDataFim,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,oMeter1,oMeter2),Nil)  },oDlg)
	oTimer:Activate()
	DEFINE SBUTTON oBtn1 From 165, 260 TYPE 15 ACTION (ProcLogView(cFilAnt, "CTBA192")) Enable Of oDlg
	DEFINE SBUTTON oBtn2 From 165, 295 TYPE 02 ACTION (oTimer:End(),MsAguarde({|| CancelJobs(nil,cArquivo)},STR0046) ,lFinal:=.T.,oDlg:End()) Enable Of oDlg  //'Cancelando processamento..'
	DEFINE SBUTTON oBtn3 From 165, 330 TYPE 01 ACTION Iif(lEnded192,(oTimer:End(),MsAguarde({|| CancelJobs(nil,cArquivo)},STR0046) ,lFinal:=.T.,oDlg:End()),Help("  ",1,"CTB192PRC",,STR0067,1,0)) Enable Of oDlg
	ACTIVATE MSDIALOG oDlg CENTERED VALID (IIf(MV_PAR12=1, IIF(Atu_Doc_Ent(cFilDe, cFilAte, cContaDe, cContaAte, dDataIni, dDataFim, cTpSald, lMoedaEsp, cMoeda ),,Msgalert('Nao conseguiu atualizar Docs e/ou Slds por Entidades')) ,) ,  MsAguarde({|| CancelJobs(lFinal,cArquivo)},STR0046) , lFinal:=.T. , oTimer:End())
Else                                   
	While !CheckProc(@cArquivo, ,,aDados1,aDados2,aFils,cContaDe,cContaAte,cFilAte,@cArqLog,dDataIni,dDataFim,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,,) 
		Sleep(nTimeOut)
	Enddo
	//-------------------------------------------------------------
	// Chama procedure para atualiza็ใo de Documento CTC e CQ8/CQ9
	//-------------------------------------------------------------
	If MV_PAR12 = 1	
		Atu_Doc_Ent(cFilDe, cFilAte, cContaDe, cContaAte, dDataIni, dDataFim, cTpSald, lMoedaEsp, cMoeda )
	Endif
Endif

If Select( "TMPCTA" ) > 0	
	cSQLExec := "DELETE FROM TMPCTA WHERE ARQUIVO = '"+cArquivo+"'"
	If TcSqlExec(cSQLExec) <> 0 
		If !lAuto
			UserException(TCSqlError())
		Else
			Conout(TCSqlError())
		EndIf
	EndIf
	TMPCTA->( dbCloseArea() )	
Endif

Return lFinal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCheckProc  ณMicrosiga                  บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa o processamento das procedures e threads             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA192                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CheckProc(cArquivo, oBrowse1,oBrowse2,aDados1,aDados2,aFils,cContaDe,cContaAte,cFilAte,cArqLog,dDataIni,dDataFim,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim,oMeter1,oMeter2,lFinal)
Local nX
Local nPosFilAtu   := If(Empty(xFilial("CT2")),1, Ascan(aFils,{|x| x[1] == IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )}))
//Local cFil  := If(Empty(xFilial("CT2")),"  ",IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))
Local cFil  := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local nPend	:=	CheckPend(cFil,cArquivo)  //-- aqui
DEFAULT lFinal	:=	.F.
If nPend > 0 //!lCancelando
	//Os JOBS cairam e ainda tem contas a processar, levantar novamente                                    
	//Verifica se tem contas para processar
	If !JobStatus(nJOBS)
		Processa({|| ChamaJOB( cArquivo,cArqLog,dDataIni,dDataFim,cFil,cTpSald,lMoedaEsp,cMoeda,nMoedaIni,nMoedaFim)},STR0047) //  	"Re-Iniciando Jobs de processamento ..."
	Endif
	//Faz todas as atualizacoes da interface
	If !lAuto
		//Se ainda tiver pendencias para a filial atual, so atualiza os dados dos jobs
		If CheckPend(cFil,cArquivo) > 0
			aDados2 := aClone(CarregDad2(cArquivo,aDados2))
			//Atualizado o progreso por filial
			aDados1 := aClone(CarregDad1(cArquivo,aFils,aDados1))
		Else 
			//Acerta o poscionamento dos dados por filialm para sempre visualizar a que esta sendo processada
			//Se nao tem pendencias para a filial atual, vai para a proxima filial do aDados1
			If nPosFilAtu > 0 .And. Len(aFils) >= nPosFilAtu
				SM0->( DbSetOrder(1))
				If nPosFilAtu > 1
					nPosFilAtu --				
					SM0->(DbSeek(cEmpAnt+aFils[nPosFilAtu,1]),.T.)
				Endif
	         	lProxFil	:=	.T.
				//Enquanto nao achar uma filial com pendenciasm continua atualizando o saldo das filial que ja foram proesadas no array
				While lProxFil
					oMeter2:Set(0)       
					oMeter1:Set( TMPCTA->(Reccount())-nPend )
	
					aDados2 := aClone(CarregDad2(cArquivo,aDados2))
					aDados1 := aClone(CarregDad1(cArquivo,aFils,aDados1))    
					
					oMeter2:nTotal	:=	Val(aDados1[nPosFilAtu][4])
					oMeter2:Set(0)        
					
					//Se a quantidade processada e menor que a total da filial atual, nao preciso atualizar mais nada na tela
					If aDados1[nPosFilAtu][4] > aDados1[nPosFilAtu][5]
						lProxFil	:=	.F.
					//Se a quantidade processada e maior ou igual que o total da filial atual, preciso atualizar com os dados da proxima filial
					Else  
						nPosFilAtu++ 
						If Len(aFils) >= nPosFilAtu
							SM0->(DbSeek(cEmpAnt+aFils[nPosFilAtu,1]),.T.)
						Else           
							lProxFil	:=	.F.						
						Endif
					Endif
				Enddo
				nPend	:=	CheckPend(,cArquivo)
			Endif
		Endif
	Endif
Endif   
If nPend == 0
	If !lAuto
		For nX:= 1 To Len(aDados2)
			aDados2[nX,2]	:=	''
			aDados2[nX,3]	:=	''
			aDados2[nX,4]	:=	''
			aDados2[nX,5]	:=	STR0048  //'Finalizado'
		Next
		For nPosFilAtu:=1 To Len(aFils)
			SM0->(DbSeek(cEmpAnt+aFils[nPosFilAtu,1]),.T.)
			//Atualizado o progreso por filial
			aDados1 := aClone(CarregDad1(cArquivo,aFils,aDados1))
		Next
		nPosFilAtu--
		oMeter2:nTotal	:=	1
		oMeter2:Set( 1 )       
	Else
		ConOut( STR0049+ Dtoc(Date())+"-"+Time() )  //"Fim CTBA192 : "
	Endif
	CTB192Proc( nTipoLog, STR0050 )  //"FIM"
Endif
If !lAuto
	If nPosFilAtu	 > 0
		If nPosFilAtu > 3
			oBrowse1:nAt	:= nPosFilAtu -2
		Endif		
		If Len(aDados1) >= nPosFilAtu
			oMeter2:Set(Val(aDados1[nPosFilAtu][5]))
		Endif
	Endif
	oMeter1:Set( TMPCTA->(Reccount())-nPend )       
	oBrowse1:Refresh()
	oBrowse2:Refresh()                                            
	SysRefresh()
EndIf

nPend     := CheckPend( Nil , cArquivo )
lEnded192 := (nPend == 0)

Return (nPend == 0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCarregDad1บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarregDad1(cArquivo,aFils,aDados1)
Local aRet 		:= aClone(aDados1)
Local nQtdProc  := 0
Local nX
Local cFilAtu 	:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) 
Local nPosFil	:= Ascan(aFils,{|x| x[1] == IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) }) //Buscando o c๓digo de filial pois no aFils foi usado o c๓digo de filial completo
Local nQtdCta	:= If(nPosFil > 0,Len(aFils[nPosFil,2]),0)
Local cQuery
Local cFil      := xFilial("CT2",cFilAtu)

If nPosFil > 0
	nQtdProc := nQtdCta-CheckPend(cFil,cArquivo) 
	
	nPercUtil := If(nQtdCta > 0,(nQtdProc * 100 ) / nQtdCta,0)
	
	cQuery := " SELECT MIN(INICIO) INICIO, MIN(DATAINI) DATAINI  "
	cQuery += " FROM TMPCTA "
	cQuery += " WHERE SITUAC  IN ('0','2') "
	cQuery += " 		AND FILPROC = '"+cFil+"' "
	cQuery += " 		AND ARQUIVO = '"+cArquivo+"' "
	cQuery += " 		AND INICIO  <> '' "
	cQuery += " 		AND DATAINI = ( "
	cQuery += " 			SELECT MIN(DATAINI)  "
	cQuery += " 			FROM TMPCTA "
	cQuery += " 			WHERE SITUAC  IN ('0','2') "
	cQuery += " 			AND ARQUIVO = '"+cArquivo+"' "
	cQuery += " 		   	AND FILPROC = '"+cFil+"' "
	cQuery += " 		   	AND DATAINI <> ' ' "
	cQuery += " 		   	AND INICIO  <> ' ' "
	cQuery += " 		   ) "
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.T.,.F.)
	dbSelectArea("TMPQRY")
	If !Eof()
		cHrIni	:=	INICIO
		dDtIni	:=	STOD(DATAINI)
	Else
		cHrIni	:= Time()
		dDtIni	:=	date()
	Endif	                     
	DbCloseArea()
   	If Empty(cHrIni)
		cHrIni	:= Time()
	Endif   
   	If Empty(dDtIni)
		dDtIni	:= Date()
	Endif   
	cTempoUtil := ElapTime( cHrIni, Time() )                
		
	nQtdRest   := nQtdCta-nQtdProc
	nAux := (nQtdRest * Secs(cTempoUtil) / nQtdProc)
	
	nHora := int(nAux/3600)
	nMinu := int(mod(nAux,3600)/60)
	nSeg  := Int(nAux - ((nHora*3600)+(nMinu*60)))
	
	cTempoRest := StrZero(nHora,2)+":"+StrZero(nMinu,2)+":"+StrZero(nSeg,2)
	For nX := 1 To Len(aFils)
		//Buscando o c๓digo de filial pois no aFils foi usado o c๓digo de filial completo
		If aFils[nX,1] ==IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			aRet[nX]:= { IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )  ,DToC(dDtIni),cHrIni,AllTrim(Str(nQtdCta)),AllTrim(Str(nQtdProc)),AllTrim(Transform(nPercUtil,"@E 999.99 %")),cTempoUtil,AllTrim(Str(nQtdRest)),cTempoRest}
		ElseIf aFils[nX,1] > IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
//			aRet[nX]:= {aFils[nX,1],'','',AllTrim(Str(Len(aFils[nX,2]))),AllTrim(Str(0)),AllTrim(Transform(0,"@E 999.99 %")),'',AllTrim(Str(Len(aFils[nX,2]))),''}
			aRet[nX]:= {aFils[nX,1],DToC(dDtIni),cHrIni,AllTrim(Str(Len(aFils[nX,2]))),AllTrim(Str(0)),AllTrim(Transform(0,"@E 999.99 %")),'',AllTrim(Str(Len(aFils[nX,2]))),''}
		Endif
	NExt	
//	TMPCTA->(dbGotop())
Endif	
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCarregDad2บAutor  ณMicrosiga           บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ														      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarregDad2(cArquivo,aDados2,cFil)
Local cQuery
Local nX
For nX := 1 To Len(aDados2)
	cQuery := " SELECT JOB, CONTA,FILPROC,INICIO, SITUAC "
	cQuery += " FROM TMPCTA "
	cQuery += " WHERE "
	cQuery += " R_E_C_N_O_ = "
	cQuery += " 	 ( SELECT MAX(R_E_C_N_O_)"
	cQuery += " 		FROM TMPCTA "
	cQuery += " 		WHERE SITUAC  IN ('0','2') "
	cQuery += " 		AND ARQUIVO = '"+cArquivo+"' "
	cQuery += " 		AND JOB = '"+aDados2[nX,1]+"' ) "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY",.T.,.F.)
	dbSelectArea("TMPQRY")
	If !TMPQRY->(EOF())
 		aDados2[nX][2]	:=	TMPQRY->FILPROC
 		aDados2[nX][3]	:=	TMPQRY->CONTA
 		aDados2[nX][4]	:=	TMPQRY->INICIO
 		If TMPQRY->SITUAC == "0"
 			aDados2[nX][5]	:= STR0051  //"Processando"
		Else
 			aDados2[nX][5]	:= STR0052   //"Ultima processada... Preparando proxima..."
		Endif
	Endif
	dbCloseArea()
Next 

Return aDados2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancelJobs   บAutor  ณMicrosiga        บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancelamento dos jobs                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA192                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CancelJobs(lFinal,cArquivo)

Local nJaProc:= nNaoProc:=nEmProc:=nErro:=0
Local nOpca	:=	0
DEFAULT cArquivo := ""

nEmProc := 1

If !lFinal
	While nEmProc > 0	
		nEmProc  := 0
		dbSelectArea("TMPCTA")
		DbSetFilter( {|| &("AllTrim(TMPCTA->ARQUIVO) =='"+AllTrim(cArquivo)+"'") },"AllTrim(TMPCTA->ARQUIVO) == '"+AllTrim(cArquivo)+"'") 
		DbGoTop()
		While !Eof()            
			If RLock()
				If SITUAC == '2'
					nJaProc++
				ElseIf SITUAC == '1' .Or. SITUAC == '5'
					nNaoProc++
				ElseIf SITUAC == '3'
					nErro++
				Endif			
				Replace SITUAC	With '5'
			Else
				nEmProc++
			Endif
			DbSkip()
		Enddo
		If nEmProc > 0
			MsProcTxt(STR0053+StrZero(nEmProc,4)+STR0054)   //'Aguardando ',' em processamento...'
			Sleep(1000)
		Endif	
	Enddo	
	lEnded192	:=	.T.
	
	If !lAuto
	
	
		nOpca	:= Aviso(STR0055,STR0056+CRLF+StrZero(nJaProc,4)+STR0057+;  //'Processamento finalizado ','Resumo:',' processadas'
									CRLF+StrZero(nNaoProc,4)+STR0058+;       //' canceladas'
									CRLF+StrZero(nErro,4)   +STR0059+;        //' com erro '
									CRLF+CRLF+STR0060,{STR0061,STR0062},3)  //'Verifique o log para detalhes do processamento.','Ver Log','Fechar'
		If nOpca == 1
			ProcLogView(cFilAnt, "CTBA192")
		Endif
	Endif
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIsThreadOn   บAutor  ณMicrosiga        บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo de threads ativas                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA192                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IsThreadOn(nThread)
Local aList	:=GetUserInfoArray()

Return (Ascan(aList,{|x| x[3] == nThread }) > 0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTB192Proc   บAutor  ณMicrosiga         บ Data ณ  01/06/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mensagens de processamento                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA192                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTB192Proc(nNivel,cTipo,cMsg,cDet,cUser)
Local cNaoValidos	:=	""
Do Case
Case nNivel == 3
	cNaoValidos	+=	"MENSAGEM"	
Case nNivel	== 2
	cNaoValidos	+=	"MENSAGEM|ALERTA"	
Case nNivel	== 1
	cNaoValidos	+=	"MENSAGEM|ALERTA|ERRO"	
EndCase

If !(cTipo $ cNaoValidos)
	ProcLogAtu(cTipo,cMsg,cDet,'CTBA192',cUser)
Endif            
If cMsg <> Nil
	PtInternal(1,cMsg)
Endif
Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCheckPend   บAutor  ณMicrosiga         บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo de processamento no banco de dados             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA192                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CheckPend( cFil , cArquivo )
Local cQryCta    := ""
Local cNextAlias := CriaTrab(,.F.)
Local nRet       := 0

cQryCta := " SELECT COUNT(*) CONTA  FROM TMPCTA "
cQryCta += "  WHERE SITUAC IN ( '0' , '1' ) "
cQryCta += "  AND ARQUIVO = '"+cArquivo+"' "

If cFil <> Nil
	cQryCta += " AND FILPROC = '" + cFil + "' "
EndIf

cQryCta += "   AND D_E_L_E_T_ =' ' "

If Select( cNextAlias ) > 0
	(cNextAlias)->( dbCloseArea() )
EndIf

dbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQryCta) , cNextAlias , .F. , .T. )
TcRefresh( cNextAlias )

If !Eof()
	nRet := CONTA
EndIf

(cNextAlias)->( DbCloseArea() ) 

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjtSx1_192   บAutor  ณMicrosiga        บ Data ณ  01/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo de pergunte                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA192                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function AjtSx1_192()
Local cPergunta := "CTB192"	
Local aArea := GetArea()

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(Padr(cPergunta,Len(SX1->X1_GRUPO))+"01")
	If !Empty(SX1->X1_DEF02 ) .or.  !Empty(SX1->X1_DEFSPA2 ) .or.  !Empty(SX1->X1_DEFENG2 )
		Reclock("SX1", .F.)
		SX1->X1_DEF02    := ""
		SX1->X1_DEFSPA2 := ""
		SX1->X1_DEFENG2 := ""
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)
Return()

/*-------------------------------------------------------------------------
Funcao		  : Ctba192Lock
Autor         : Renato Campos
Data          : 01/11/2016
Uso           : Efetua a trava da excu็ใo da atualiza็ใo via multi-thread
-------------------------------------------------------------------------*/
Static Function Ctba192Lock()
Local nAtt := 0
Local lRet := .T.

While !LockByName('CTBA192_'+cEmpAnt ,.T., .F., .T. )
	nAtt++
	Conout(STR0069) //"Tentando travar a execu็ใo da rotina de atualiza็ใo de saldos via multi-thread"
	Sleep(2000)
	
	If nAtt > 10
		lRet := .F.
		Exit
	Endif	
EndDo

If !lRet
	CTB192Proc( 3, STR0027,STR0068 + cEmpAnt) //"MENSAGEM"###"Nใo foi possivel o acesso exclusivo da rotina de atualiza็ใo de saldos via multi-thread para a empresa "
	MsgAlert(STR0068 + cEmpAnt) //"Nใo foi possivel o acesso exclusivo da rotina de atualiza็ใo de saldos via multi-thread para a empresa "
Endif

Return lRet

/*-------------------------------------------------------------------------
Funcao		  : Ctba192UnLock
Autor         : Renato Campos
Data          : 01/11/2016
Uso           : Efetua a libera็ใo dos da rotina para execu็ใo
-------------------------------------------------------------------------*/
Static Function Ctba192UnLock()

UnLockByName('CTBA192_'+cEmpAnt ,.T., .F., .T. )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtu_Doc_Ent  บAutor  ณMicrosiga           บ Data ณ  31/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑ
ฑฑบDesc.   ณ Atualiza DocumentosCTC e Entidades CQ8/CQ9 apos a atualiza็ใo บฑฑ
ฑฑบ        ณ dos CQ0 a CQ7                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8 - Controladoria - CTB                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Atu_Doc_Ent(cFilDe, cFilAte, cContaDe, cContaAte, dDataIni, dDataFim, cTpSaldo, lMoedaEsp, cMoeda )
Local lRet    := .F.
Local aREsult := {}
Local cMVSOMA := If(GetMv("MV_SOMA") = 1, '1', '2')  // 1 - soma uma vez no total digitado qdo partida dobrada, '2' soma duas vezes
Local lCusto	:= CtbMovSaldo("CTT")
Local lItem	:= CtbMovSaldo("CTD")
Local lCLVL	:= CtbMovSaldo("CTH")
Local cQuery  := ""
Local nFKinUse:= 0
Local lDelFisico	:= GetNewPar('MV_CTB190D',.T.)
Local cCTB240 := IIF(FindFunction("GetSPName"), GetSPName("CTB240","07"), "CTB240")

cQuery := "SELECT count(*) TOTAL FROM TOP_PARAM WHERE PARAM_NAME = 'FKINUSE" + SM0->M0_CODIGO + "'"
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'INTEGR', .F., .T.)
nFKInUse := INTEGR->TOTAL
INTEGR->( dbCloseArea() )
/*
CONOUT('cFilDe    : '+ cFilDe )
CONOUT('cFilAte   : '+ cFilAte )
CONOUT('dDataIni  : '+ dtos(dDataIni) )
CONOUT('dDataFim  : '+ dtos(dDataFim) )
CONOUT('lMoedaEsp : '+ IIf(lMoedaEsp,'1','0') )
CONOUT('cMoeda    : '+ cMoeda)
CONOUT('cTpSald   : '+ cTpSaldo )
CONOUT('cMVSOMA   : '+ cMVSOMA )
CONOUT('lCusto    : '+ If(lCusto, '1', '0'))
CONOUT('lItem     : '+ If(lItem, '1', '0'))
CONOUT('lClvl     : '+ If(lClvl, '1', '0'))
CONOUT('cContaDe  : '+ cContaDe )
CONOUT('cContaAte : '+ cContaAte )
CONOUT('nFkinUse  : '+ If(nFKInUse > 0,'1','0'))
CONOUT('lDelFisico: '+ If(lDelFisico,'1','0'))
*/
/* Chama procedure de atualiza็ใo de documentos */
If !ExistProc( cCTB240 , VerIDProc() )
	MsgAlert(STR0064, STR0065 )  //"ERRO","Procedure CTB240 nao encontrada."
Else
	bAtudoc := {||aResult := TCSPEXEC( xProcedures(cCTB240),;
							cFilDe,        cFilAte,;
						   Dtos(dDataIni), Dtos(dDataFim),;
						   If( lMoedaEsp, '1', '0'), If( lMoedaEsp, cMoeda, '00'),; 
						   cTpSaldo,;
						   cMVSOMA,;
						   If(lCusto, '1', '0'),;
						   If(lItem, '1', '0'),;
						   If(lClvl, '1', '0'),;
						   cContaDe, cContaAte,;
						   If(nFKInUse > 0,'1','0'),;
						   If(lDelFisico,'1','0'))}
	If !lAuto					   
		MsgRun(STR0070,,bAtudoc) //STR0070 - Atualizando Docs e/ou Saldos por Entidades
	Else
		Eval(bAtudoc)							   
	EndIf
	
	IF Len( aResult ) > 0 .And.  ( ValType( aResult[1] ) == "C" )
		lRet := aResult[1] == '1'
	Else
		lRet := .F.
		If !lAuto
			MsgAlert(STR0064,STR0066 )//"ERRO","Erro no retorno da procedure de Atualiza็ใo de Documentos - CTB240." 
		EndIf
	Endif
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณVerIDProc ณ Autor ณ                       ณ Data ณ31/03/2014ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤ
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณIdentifica a sequencia de controle do fonte ADVPL com a     ณฑฑ
ฑฑณ          ณstored procedure, qualquer alteracao que envolva diretamenteณฑฑ
ฑฑณ          ณa stored procedure a variavel sera incrementada.            ณฑฑ
ฑฑณ          ณProcedure CTB023                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/         
Static Function VerIDProc()
Return '001'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณCriaTabLog ณ Autor ณ                      ณ Data ณ30/07/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณSe nใo encontrar, cria a tabela de Log no banco de Dados    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/         
Static Function CriaTabLog()
Local cArquivo  := ""
Local aEstrut   := {}
Local nTamFil	:= TamSX3('CT1_FILIAL')[1]
Local nTamCTA	:= TamSX3('CT1_CONTA')[1]
//Local nIndex    := 0

If !MSFile("TMPCTA", ,__CRDD )
	aAdd(aEstrut ,{"FILPROC"   ,"C", nTamFil, 00})
	aAdd(aEstrut ,{"CONTA" 	   ,"C", nTamCTA, 00})
	aAdd(aEstrut ,{"SITUAC"    ,"C", 01, 00})
	aAdd(aEstrut ,{"VEZES" 	   ,"N", 01, 00})
	aAdd(aEstrut ,{"JOB" 	   ,"C", 16, 00})
	aAdd(aEstrut ,{"INICIO"    ,"C", 08, 00})
	aAdd(aEstrut ,{"DATAINI"   ,"D", 08, 00})
	aAdd(aEstrut ,{"FIM" 	   ,"C", 08, 00})
	aAdd(aEstrut ,{"DURACAO"   ,"C", 08, 00})
	aAdd(aEstrut ,{"ARQUIVO"   ,"C", 09, 00})	
	
	DBCreate( "TMPCTA", aEstrut,__CRDD)
EndIf	

If Select("TMPCTA") == 0
	dbUseArea(.T.,__CRDD,"TMPCTA","TMPCTA", .T., .F. )
EndIf

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณC192RetArq ณ Autor ณ                      ณ Data ณ30/07/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRetorna o pr๓ximo arquivo para utilizar na tabela temporแriaณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  
Static Function C192RetArq()
Local cRet := Criatrab(,.F.)

Return cRet