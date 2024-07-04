#INCLUDE "PROTHEUS.ch"
#INCLUDE "GPEM875.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEM875   บAutor  ณL.Trombini                                        บ Data ณ  15/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออฯออออออออออออออออออฯอออออนฑฑ
ฑฑบDesc.     ณGera arquivos Magneticos para o Equador                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออฯอออออนฑฑ
ฑฑณ Uso      ณ Generico                                                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออฯอออออนฑฑ
ฑฑบ          ณ    ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                                     บฑฑ
ฑฑฬอออออออออออออุอออออออออุอออออออออุอออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออฯออออนฑฑ
ฑฑบProgramador  ณ Data    ณFNC/PLANO ณ Motivo da Alteracao                                              บฑฑ
ฑฑฬอออออออออออออุอออออออออุอออออออออุอออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออฯออออนฑฑ
ฑฑบKelly Soares ณ18/08/11 ณ20964/2011ณ Parametros: ajuste no grupo de perguntas, atualizacao do conteudoบฑฑ
ฑฑบ             ณ         ณ          ณ tipo de arquivo. Alteradas funcoes AjustaGPM875 e fTpoRot.       บฑฑ
ฑฑบ             ณ         ณ          ณ Geracao dos arquivos: Obter codigo de rescisao para IESS da tabe-บฑฑ
ฑฑบ             ณ         ณ          ณ la S018, ajuste no intervalo de datas para query dos arq. tipo 1,บฑฑ
ฑฑบ             ณ         ณ          ณ 2 e 3, obter dias de ausencia em todos os meses do arq. tipo 6.  บฑฑ
ฑฑบKelly Soares ณ27/10/11 ณTDUJOF    ณ Ajuste no intervalo de filial.                                   บฑฑ
ฑฑบ             ณ         ณ          ณ                                                                  บฑฑ
ฑฑบJonathan Glezณ04/05/15 ณPCREQ-4256ณ Se elimina funcion AjustaGPM875 por motivo de adeciacion de nuevaบฑฑ
ฑฑบ             ณ         ณ          ณ estructura de SXs para version 12 y se cambia el grupo de pregun-บฑฑ
ฑฑบ             ณ         ณ          ณ tas por GPM875a                                                  บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GPEM875()

Local nOpca
Local aSays			:= {}, aButtons:= { } //<== arrays locais de preferencia

Private cCadastro 	:= OemToAnsi(STR0001) //"Ajuste de Parametros"
Private nSavRec  		:= RECNO()
Private cProcessos	:= ""
Private cPer         := ""
Private nTipoRel		:= 0
Private cProcRange   := ""
Private cProcAux		:= ""
Private lUmProc		:= .F.
Private lSubAG		:= .F.
Private lTemS1		:= .F.
Private lTemS2		:= .F.
Private lTemS3		:= .F.
Private cValSr		:= "01"

nOpca := 0

AADD(aSays,OemToAnsi(STR0002) )  //"Rutina para gener. de archivo de texto "
AADD(aSays,OemToAnsi(STR0003) )  //"O sistema irแ gerar o arquivo de acordo com os parโmetros informados."
AADD(aSays,OemToAnsi(STR0025) )  //"Executar somente com o periodo aberto

AADD(aButtons, { 5,.T.,{|| Pergunte("GPM875a",.T.) }} )
AADD(aButtons, { 1,.T.,{|| If( GPE875Gera(), FechaBatch(), ) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao     GPE875GeraบAutor  ณLuis Trombini       บ Data ณ  15/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega parametros e cria arquivo texto escolhido pelo     บฑฑ
ฑฑบ          ณ usuario.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GPE875Gera()

//--Carrega as perguntas.
Pergunte("GPM875a",.F.)

//--Seta e Carrega os Mnemonicos.
SetMnemonicos(NIL,NIL,.T.)

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis utilizadas para parametros                         ณ
ณ mv_par01        //  Filial ?	 		    				   ณ
ณ mv_par02        //  Tipo de Arquivo?	     				   ณ
ณ mv_par03        //  Mes/Ano Referencia ?					   ณ
ณ mv_par04        //  Arquivo de Saida?                        ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
cFilial     := mv_par01 // verificar o de/para
nTipoArq	:= mv_par02
cMesAno 	:= mv_par03
Private nTamProc 		:= GetSx3Cache("RC_PROCES", "X3_TAMANHO")
Private nHdl    		:= fCreate(mv_par04)

If nHdl == -1
    MsgAlert(STR0004+mv_par04+STR0005,STR0006) //"O arquivo de nome "###" nao pode ser executado! Verifique os parametros."###"Atencao!"
    Return .F.
Endif

//Inicializa a regua de processamento
Processa({|lEnd| GPE875Proc() },STR0007)         //"Processando..."

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |GPE875ProcบAutor  ณLuis Trombini       บ Data ณ  15/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de geraco do arquivo                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPE875Proc()

Local cForm0, cForm0OK, cFormE, cFormEOK, cFormL, cFormLOK, lCond
Local nTamLin, cLin, cCpo, nPoint, nX, nI, nJ, nZ
Local cLectura 		:= SPACE(1)
Local cFilialAnt 	:= SPACE(FWGETTAMFILIAL)
Local lRotBlank 	:= .F.
Local aPos			:= {,,,,,,,}
Local nAux			:= 0
Local nCount		:= 0
Local nPos			:= 1
Local nTamFil		:= Len(fwxFilial("SRA"))
Private cfilialde   := Space(Len(fwxFilial("SRA")))
Private cFilialate	:= Replicate("Z",nTamFil)
Private nTotalHE    := 0
Private nTotFundo   := 0
Private aRCCE		:= {}
Private aRCCS		:= {}
Private cMes, cAno , cRTrab, cTpEmp, cPubl
Private nMaxEM 		:= 0
Private nDiasTra
Private aPerFechado := {}
Private aPerAberto 	:= {}
Private aVerbasLIQ  := {}
Private aCodFol		:= {}
Private aInfoFil	:= {}
Private ndurac 		:= 0
Private aPerTodos	:= {}
Private DDTINI      := ctod("  /  /  ")
Private DDTFIM      := ctod("  /  /  ")
Private cValN		:= "     0,00"
Private nCodEmp		:= 0
Private cConvenc    := ""
Private ngrav       := .f.
Private dMesIni, dMesFim

If !Empty(mv_par01)
	cfilialde   := substr(mv_par01,1,nTamFil)
	If !Empty( substr(mv_par01,nTamFil+2,nTamFil) )
		cFilialate	:= substr(mv_par01,nTamFil+2,nTamFil)
	EndIf
EndIf
If (Len(StrTran(Alltrim(cProcRange),'*','')) / nTamProc) == 1
	cMesAno := StrTran(Alltrim(cProcRange),'*','')
	lUmProc := .T.
Endif

cMes := Left(mv_par03,2)
cAno := Right(mv_par03,4)

cPer := cMes + cAno

fRetPerComp( 	cMes		  ,;		// Obrigatorio - Mes para localizar as informacoes
				cAno		  ,;		// Obrigatorio - Ano para localizar as informacoes
				xFilial("RCH"),;		 // Opcional - Filial a Pesquisar
						  ,;		// Opcional - Filtro por Processo
			              ,;		// Opcional - Filtro por Roteiro
				@aPerAberto	  ,;		// Por Referencia - Array com os periodos Abertos
				@aPerFechado, ;		// Por Referencia - Array com os periodos Fechados
				@aPerTodos    ;		// Por Referencia - Array com os periodos Abertos e Fechados em Ordem Crescente
				 )
cNomeArq:= "S022"

//monta os ARRAYS de posicoes. Posicao de inicio e tamanho.
nPoint := 1//Ponteiro contador para selecionar a posicao de inicio de cada campo corretamente.
DbSelectArea("RCB")
DbSetOrder(1)
cFilRCB:=xFilial("RCB")
DbSeek(cFilRCB + cNomeArq)
While cFilRCB == RCB_FILIAL .and. RCB_CODIGO == cNomeArq
	cCpo:= Alltrim(RCB_CAMPOS)
	Do Case
		Case cCpo == "ARQUIVO"
			aPos[1]:={nPoint, RCB_TAMAN}
		Case cCpo == "ITEM"
			aPos[2]:={nPoint, RCB_TAMAN}
		Case cCpo == "DIGITOS"
			aPos[3]:={nPoint, RCB_TAMAN}
		Case cCpo == "CONTEUDO"
			aPos[4]:={nPoint, RCB_TAMAN}
	EndCase
	nPoint += RCB_TAMAN
	DbSkip()
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGuarda as posicoes inicio e tamanho, dentro das vaiaves com os respectivos conteudos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFilRCC:=xFilial("RCC")
DbSelectArea("RCC")
DbSetOrder(1)
DbSeek(xFilial()+cNomeArq)
Do While cFilRCC == RCC_FILIAL .and. RCC_CODIGO == cNomeArq
    If SUBSTR(RCC_CONTEU,1,1) == nTipoArq
   		cArquivo    := Alltrim(SubStr(RCC_CONTEU, aPos[1,1], aPos[1,2]))
		cItem   	:= Alltrim(SubStr(RCC_CONTEU, aPos[2,1], aPos[2,2]))
		cDigitos 	:= Alltrim(SubStr(RCC_CONTEU, aPos[3,1], aPos[3,2]))
		CConteudo   := Alltrim(SubStr(RCC_CONTEU, apos[4,1], aPos[4,2]))
		AAdd(aRCCE,{cArquivo,cItem,cDigitos,Cconteudo})
	EndIf
	DbSkip()
EndDo

dMesIni := Ctod("01/"+cMes+"/"+cAno)
dMesFim := Lastdate(dMesIni)

#IFDEF TOP
    SRA->( dbCloseArea() )
	cAliasX := "SRA"
	Do Case
		Case nTipoArq == "1"
		    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
		    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		    cQuery += "SRA.RA_ADMISSA >='" + DTOS(dMesIni)+"' AND "
		    cQuery += "SRA.RA_ADMISSA <='" + DTOS(dMesFim)+ "' AND "
		    cQuery += "SRA.D_E_L_E_T_ = ' ' "
	 		cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT"
	 		cQuery := ChangeQuery(cQuery)
		Case nTipoArq == "2"
		    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
		    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		    cQuery += "SRA.RA_DEMISSA >='" + DTOS(dMesIni)+"' AND "
		    cQuery += "SRA.RA_DEMISSA <='" + DTOS(dMesFim)+ "' AND  "
		    cQuery += "SRA.D_E_L_E_T_ = ' ' "
	 		cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT"
	 		cQuery := ChangeQuery(cQuery)
		Case nTipoArq == "3"
		    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
		    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		    cQuery += "SRA.RA_DATAALT >='" + DTOS(dMesIni)+"' AND  "
		    cQuery += "SRA.RA_DATAALT <='" + DTOS(dMesFim)+ "' AND "
		    cQuery += "SRA.D_E_L_E_T_ = ' ' "
	 		cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT"
	 		cQuery := ChangeQuery(cQuery)
		Case nTipoArq == "4"
		    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
		    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		    cQuery += "SRA.D_E_L_E_T_ = ' ' "
	 		cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT"
	 		cQuery := ChangeQuery(cQuery)
		Case nTipoArq == "5"
		    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
		    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		    cQuery += "SRA.D_E_L_E_T_ = ' ' "
	 		cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT"
	 		cQuery := ChangeQuery(cQuery)
		Case nTipoArq == "6"
		    cQuery :="Select * from "+ RetSqlName("SRA")+" SRA "
		    cQuery += "WHERE " + "SRA."+RANGESX1("RA_FILIAL"  ,MV_PAR01)+" AND "
		    cQuery += "SRA.RA_SITFOLH IN  ('A')" +" AND "
		    cQuery += "SRA.D_E_L_E_T_ = ' ' "
	 		cQuery += "ORDER BY SRA.RA_FILIAL,SRA.RA_MAT"
	 		cQuery := ChangeQuery(cQuery)
	EndCase

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasX,.T.,.T.)
	TcSetField(cAliasX, "RA_DEMISSA", "D", 8, 0)
	TcSetField(cAliasX, "RA_ADMISSA", "D", 8, 0)
	TcSetField(cAliasX, "RA_DATAALT", "D", 8, 0)
	TcSetField(cAliasX, "RA_OPCAO", "D", 8, 0)
#ELSE

	cAliasX := "SRA"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica a ordem selecionada                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cIndCond:= "RA_FILIAL + RA_MAT"
	cIndTRB	:= "FILIAL + MAT"

		//cArqNtx  := CriaTrab(NIL,.F.)
		//IndRegua("SRA",cArqNtx,cIndCond,,,STR0039)				//"Selecionando Registros..."
	(cAliasX)->( DbGoTop() )

	//-- Adiciona no filtro o parametro tipo Range
	//-- Filial
	DO CASE
	   Case nTipoArq == "1"
	   		cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")'
			cFiltro += '(SRA->RA_ADMISSA >="'+ DTOS(dMesIni) + '")'
			cFiltro += '(SRA->RA_ADMISSA <="'+ DTOS(dMesFim) + '")'
	   Case nTipoArq == "2"
			cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")'
			cFiltro += '(SRA->RA_DEMISSA >="'+ DTOS(dMesIni) + '")'
			cFiltro += '(SRA->RA_DEMISSA <="'+ DTOS(dMesFim) + '")'
	   Case nTipoArq == "3"
			cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")'
			cFiltro += '(SRA->RA_DATAALT >="'+ DTOS(dMesIni) + '")'
			cFiltro += '(SRA->RA_DATAALT <="'+ DTOS(dMesFim) + '")'
	   Case nTipoArq == "4"
			cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")'
	   Case nTipoArq == "5"
			cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")'
	   Case nTipoArq == "6"
			cFiltro := '(SRA->RA_FILIAL  $ "' + mv_par01  + '")'
	EndCase

	oSection:SetFilter(cFiltro, cIndCond, , "SRA")
	DBGOTOP()
#ENDIF

	DbSelectArea('SM0')
	DbSetOrder(1)
	DbSeek(cEmpAnt+cFilialDe,.T.)
	While !SM0->(EOF())
		//# Alterado pra melhorar performce
		If SM0->M0_CODIGO+SM0->M0_CODFIL > cEmpAnt+cFilialAte
			Exit
		EndIf

		aSM0 := {}
		For nI:=1 To Len(aRCCS)
			lCond := If(Empty(aRCCS[nI][3]),.T.,&(aRCCS[nI][3]))
			//Verificar se tem que fazer pesquisa em algum arquivo
			If lCond .And. !Empty(aRCCS[nI][6])
				DbSelectArea(aRCCS[nI][6])
				DbSetOrder(aRCCS[nI][7])
				lCond	:=	MsSeek(&(aRCCS[nI][8]))
			Endif

			If lCond//Verifica se existe uma condi็ใo valida
				cForm0 := &(aRCCS[nI][2])//Verifica o retorno da formula e converte para string caso seja numerico ou data.
				If Type("cForm0") == "N"
					cForm0OK := Str(Form0)
				Elseif Type("cForm0") == "D"
					cForm0OK := DtoC(Form0)
				Else
					cForm0OK := cForm0
				EndIf
			Else
				cForm0OK := " "//Se nใo existir uma condi็ใo valida, retorna vazio.
			EndIf

			If aRCCS[nI,5] > 0
				AAdd(aSM0,{aRCCS[nI,4],PADR(cForm0OK,aRCCS[nI,5])}) //Ajusta o tam. do result.(Longitude)
			Endif
		Next
		DbSelectArea('SRA') //Fucionario
//		DbSetOrder(1)
//		DbSeek(cfilialde,.T.)
		ProcRegua(SRA->(RecCount()))
		While !SRA->(EOF()) .and. SRA->Ra_Filial <= cFilialAte
			//# Alterado pra melhorar performce
			If SRA->RA_FILIAL > cFilialAte
				Exit
			EndIf

/*/			If nTipoArq == "1" .and. AnoMes(SRA->RA_ADMISSA) <> (cAno+cMes)
				SRA->(DbSkip())
				Loop
			Endif

			If nTipoArq == "2" .and.AnoMes(SRA->RA_DEMISSA) <> (cAno+cMes)
				SRA->(DbSkip())
				Loop
			Endif
			If nTipoArq == "3" .and. AnoMes(SRA->RA_DATAALT) <> (cAno+cMes)
				SRA->(DbSkip())
				Loop
			Endif
			If nTipoArq == "6" .and. SRA->RA_SITFOLH <> "A"
				SRA->(DbSkip())
				Loop
			Endif */


			aRegistro := {}//Limpa o vetor a cada novo funcionario.
			nposini := 1
			If nTipoArq == "1"
			  cTpEmp := If (FTABELA("S021",1,8, NIL) <> Nil, FTABELA("S021",1,8, NIL) , '')
			  If Empty(cTpEmp)
   				MsgAlert(STR0019,STR0006) //Cadastre o tipo de empregado na tabela S021 # Atencao
				Return .F.
			  Endif
			  cRTrab := If (FTABELA("S021",1,9, NIL) <> Nil, FTABELA("S021",1,9, NIL) , '')
			  If Empty(cRTrab)
   				MsgAlert(STR0020,STR0006) //Cadastre a Relacao de Trabalho na tabela S021 # Atencao
				Return .F.
			  Endif
			  cPubl := If (FTABELA("S021",1,10, NIL) <> Nil, FTABELA("S021",1,10, NIL) , '')
			  If Empty(cPubl)
   				MsgAlert(STR0021,STR0006) //Identifique se a Empresa ้ Publica # Atencao
				Return .F.
			  Endif
			EndIf
			If nTipoArq == "2"
			  dbSelectArea("SRG")
			  dbseek(sra->ra_filial+sra->ra_mat)
			  If eof()
   				MsgAlert(STR0022,STR0006) // Funcionario sem Calulo de Rescisao e com Situacao de Demitido # Atencao
				Return .F.
			  Endif
			  cCod := RG_TIPORES
			  cCodIess := RetcIess("S018","=",cCod)
			  dbSelectArea("SRA")
			Endif

            If nTipoArq == "4"
                cProcesso := SRA->RA_PROCES
		   		aVerbasLIQ := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("1"), , aPerAberto, aPerFechado )
		   		nTotalHE := 0
			   	If !(len(aVerbasLIQ)<1)
					For nAux:= 1 to len(aVerbasLIQ)
						If PosSrv(aVerbasLIQ[nAux,3],SRA->RA_FILIAL, "RV_HE")= "1" //Cantidad de Horas Extras
							nTotalHE += aVerbasLIQ[nAux,7]
            			Endif
					Next
				Endif
				If nTotalHe <= 0
                  		SRA->(DbSkip())
			   		Loop
               	EndIf
            Endif

            If nTipoArq == "5"
                cProcesso := SRA->RA_PROCES
		   		aVerbasLIQ := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("1"), , aPerAberto, aPerFechado )
		   		nTotFundo := 0
			   	If !(len(aVerbasLIQ)<1)
					For nAux:= 1 to len(aVerbasLIQ)
						If PosSrv(aVerbasLIQ[nAux,3],SRA->RA_FILIAL,"RV_CODFOL") $ '1220/1226'
							nTotFundo += aVerbasLIQ[nAux,7]
            			Endif
					Next
				Endif
				If nTotFundo <= 0
                  		SRA->(DbSkip())
			   		Loop
               	EndIf
            Endif

            If nTipoArq == "6"
            	DbSelectArea ("SR8")  //controle de ausencias
				DbSetOrder(1)
				dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
   				While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SR8->R8_FILIAL+R8_MAT

	   				If AnoMes(SR8->R8_DATAINI) <= cAno+cMes .AND. ;
	   				  (Empty(SR8->R8_DATAFIM) .OR. (!Empty(SR8->R8_DATAFIM) .AND. AnoMes(SR8->R8_DATAFIM) >= cAno+cMes))

	   				   DDTINI := MAX(dMesini,SR8->R8_DATAINI)
	   				   DDTFIM := If(Empty(SR8->R8_DATAFIM),dMesFim,MIN(dMesFim,SR8->R8_DATAFIM))
	   				   nDurac := DDTFIM - DDTINI + 1

	   				EndIf

					DbSkip()
   				EndDo
                If Ndurac <= 0
                  	SRA->(DbSkip())
					Loop
                EndIf
            EndIf
			If Len(aVerbasLIQ) == 0  .And. nTipoArq == "4"
				SRA->(DbSkip())
				Loop
			Endif

			IncProc(STR0007 + space(1) + SRA->RA_MAT)

			For nJ:=1 To Len(aRCCE)//Le o vetor aRCCE(Empregados) e alimenta o vetor aRegistro.
				cFormEOK := " "//Se nใo existir uma condi็ใo valida, retorna vazio.
				cFormE := &(aRCCE[nJ][4])//Variavel que recebe o conteudo desse vetor calculado.
			   	If Type("cFormE") == "N"
					cFormEOK := Str(cFormE)
				Else
					cFormEOK := cFormE
				EndIf
				If Val(aRCCE[nJ,3]) > 0
					AAdd(aRegistro,{nposini,PADR(cFormEOK,Val(aRCCE[nJ,3]))})
				Endif
				nposini += Val(aRCCE[nJ,3])
			Next
			For nX:=1 To Len(aSM0) //Adicona o vetor de empresas aSM0{} ao vetro aRegistro{}.
				AAdd(aRegistro,aSM0[nX])
			Next
			aSort(aRegistro,,,{|aReg1,aReg2| aReg1[1] < aReg2[1]})//Ordena vetor.
			GPE875TXT()//Funcao que grava o registro por funcionario.
			ngrav := .t.
			nTotParc := 0

			SRA->(DbSkip())
		EndDo

		SM0->(DbSkip())
	EndDo
	if ngrav
		MsgAlert(STR0024+mv_par04) //Identifique se a Empresa ้ Publica # Atencao
    endif

fClose(nHdl)//Fechamento do objeto Dialog
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPE875TXT บAutor  ณRafael P. Rizzatto  บ Data ณ  19/04/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcion que graba tolo archivo del texto con el conteudo   บฑฑ
ฑฑบ          ณ dos arrays.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPE875TXT()
Local nX, cLin
    cLin := ""
	For nX :=1 To Len(aRegistro)
		cLin += Alltrim(aRegistro[nX,2])+IF(LEN(aRegistro)<> nX,";","")
	Next
	cLin += CRLF

    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //Testa por erros durante a gravacao da linha montada.
        If !MsgAlert(STR0008,STR0006) //"Ocorreu um erro na gravacao do arquivo. Continua?"###"Atencao!"
        Endif
    Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEM875   บAutor  ณLuis Trombini       บ Data ณ  21/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega janela de opcoes dos arquivos a serem gerados.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fTpoRot( )

Local cTitulo	:= STR0016  //"tipo de relatorio"
Local cString	:= ""
Local MvParDef	:= ""
Local nFor		:= 0
Local MvPar
Local lExiste   := .F.
Private aSit	:= {}

cAlias := Alias() 					// Salva Alias Anterior

If Upper(Alltrim(ReadVar() )) == "MV_PAR02"
	MvPar:=&(Alltrim(ReadVar()))	// Carrega o conteudo da variavel
	MvRet:=Alltrim(ReadVar())		// carrega o nome da variavel
Endif

CursorWait()

MvParDef:= "123456"

aAdd(aSit, STR0026)
aAdd(aSit, STR0027)
aAdd(aSit, STR0028)
aAdd(aSit, STR0029)
aAdd(aSit, STR0030)
aAdd(aSit, STR0031)

CursorArrow()

IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,.T.,1)
	&MvRet := MvPar
EndIF

dbSelectArea(cAlias) // Retorna Alias

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDir810m()บAutor  ณLuis Trombini      บ Data ณ  21/09/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApresenta janela para usuario escolher diretorio/arquivo a  บฑฑ
ฑฑบ          ณser gerado.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function fDir810m()

Local mvRet		:= Alltrim(ReadVar())
Local cType 	:= ""
Local cArq		:= ""
Local aDir		:= {}
Local nDir		:= 0

cType:= STR0015 //"Arquivos Texto (*.TXT) |*.txt|"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Comando para selecionar um arquivo.                          ณ
//ณ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   ณ
//ณ            GETF_LOCALHARD - Inclui o Harddisk local.         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cArq 	:= cGetFile(cType, STR0017, 0,,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY)  // "Selecione arquivo "
aDir	:= { { cArq } }


&mvRet := cArq

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER875   บAutor  ณLuis Trombini      บ Data ณ  21/09/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera tabelas necessarias para geracao de arquivos Magneticosบฑฑ
ฑฑบ          ณpara o Equador.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GPEM875B()

Private lImpMnemo		:= .F.

Begin Sequence

		IF ( lImpMnemo := MsgNoYes(	OemToAnsi(	STR0012 + ;	//"O Sistema ira Atualizar a Tabela RCC para geracao de arquivos de texto."
											CRLF	+ ;
											STR0013 + ;	//"Faca um Backup (RCC) antes de Iniciar o Processo de Atualizacao."
											CRLF	+ ;
											CRLF	+ ;
											STR0014   ;	//"Confirma a Atualizacao da Tabela?"
					   					 ),;
				 				OemToAnsi( STR0009 ) ;	//"Ateno"
							);
		)

		MsAguarde( { || CarTab875() } )

	EndIf


End Sequence



Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCarTab875   บAutorณLuis Trombini      บ Data ณ  21/09/2010  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarTab875()

Local aTabRCB   := {}
Local aTabRCC	:= {}
Local nI		:=	0
Private cFilRCC  := xFilial("RCC")

DbSelectArea("RCC")
DbSetOrder(1)

gper875del()        //se tabelas jah existem, apaga.


//Carrega informacoes da tabela S023 - Arquivos Magneticos
cNomeArq := "S022"

AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','001','1RUC DE LA EMPRESA                                 13 SM0->M0_CGC                                                                                                                                                                                         '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','002','1CODIGO DE LA SUCURSAL                             4  "00"+SM0->M0_CODFIL                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','003','1ANO ACTUAL                                        4  CANO                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','004','1MES ACTUAL                                        2  CMES                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','005','1TIPO DEL MOVIMIENTO                               3  "ENT"                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','006','1NR. CEDULA DEL EMPLEADO AFECTADO                  10 SRA->RA_RG                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','007','1FECHA DEL INGRESO EN LA EMPRESA                   8  GRAVADATA(SRA->RA_ADMISSA,.F.,8)                                                                                                                                                                    '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','008','1FECHA REGISTRO EN EL SISTEMA                        8GRAVADATA(SRA->RA_OPCAO,.F.,8)                                                                                                                                                                      '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','009','1JORNADA                                           1  "1"                                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','010','1CODIGO SEGURO SOCIAL                              1  "R"                                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','011','1CODIGO DEL TIPO DEL EMPLEADOR                       2CTPEMP                                                                                                                                                                                              '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','012','1RELACION DE TRABAJO                                 2CRTRAB                                                                                                                                                                                              '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','013','1DENOMINACION DEL CARGO                            64 SUBSTR(SQ3->Q3_DESCSUM,1,64)                                                                                                                                                                        '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','014','1CODIGO DE ACTIVIDAD SECTORIAL                     10 SRJ->RJ_ATISET                                                                                                                                                                                      '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','015','1SUELDO                                             14TRANSFORM(SRA->RA_SALARIO,"@E 999999999.99")                                                                                                                                                        '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','016','1ORIGEN DE PAGO                                      1CPUBL                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','017','2RUC DE LA EMPRESA                                 13 SM0->M0_CGC                                                                                                                                                                                         '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','018','2CODIGO DE LA SUCURSAL                             4  "00"+SM0->M0_CODFIL                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','019','2ANO ACTUAL                                        4  CANO                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','020','2MES ACTUAL                                        2  CMES                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','021','2TIPO DE MOVIMIENTO                                3  "SAL"                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','022','2NR. CEDULA DEL EMPLEADO AFECTADO                  10 SRA->RA_RG                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','023','2FECHA DE SALIDA                                   8  GRAVADATA(SRA->RA_DEMISSA,.F.,8)                                                                                                                                                                    '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','024','2CAUSA                                             1  CCODIESS                                                                                                                                                                                            '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','025','3RUC DE LA EMPRESA                                 13 SM0->M0_CGC                                                                                                                                                                                         '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','026','3CODIGO DE LA SUCURSAL                             4  "00"+SM0->M0_CODFIL                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','027','3ANO ACTUAL                                        4  CANO                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','028','3MES ACTUAL                                        2  CMES                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','029','3TIPO DE MOVIMIENTO                                3  "MSU"                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','030','3NR. CEDULA DEL EMPLEADO AFECTADO                  10 SRA->RA_RG                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','031','3NUEVO SUELDO                                      14 TRANSFORM(SRA->RA_SALARIO,"@E 999999999.99")                                                                                                                                                        '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','032','4RUC DE LA EMPRESA                                 13 SM0->M0_CGC                                                                                                                                                                                         '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','033','4CODIGO DE LA SUCURSAL                             4  "00"+SM0->M0_CODFIL                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','034','4ANO ACTUAL                                        4  CANO                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','035','4MES ACTUAL                                        2  CMES                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','036','4TIPO DEL MOVIMIENTO                               3  "INS"                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','037','4NR. CEDULA DEL EMPLEADO AFECTADO                  10 SRA->RA_RG                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','038','4VALORES EXTRAS                                     14TRANSFORM(NTOTALHE,"@E 999999999.99")                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','039','4CAUSA                                             1  "O"                                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','040','5RUC DE LA EMPRESA                                 13 SM0->M0_CGC                                                                                                                                                                                         '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','041','5CODIGO DE LA SUCURSAL                             4  "00"+SM0->M0_CODFIL                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','042','5ANO ACTUAL                                        4  CANO                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','043','5MES ACTUAL                                        2  CMES                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','044','5TIPO MOVIMIENTO                                   3  "PFR"                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','045','5NR. CEDULA DEL EMPLEADO AFECTADO                  10 SRA->RA_RG                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','046','5VALORES SUELDO TOTAL                              14 TRANSFORM(NTOTFUNDO,"@E 999999999.99")                                                                                                                                                              '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','047','5PERIODO DEL CUAL SE CANCELA LOS FONDOS DE RESERVA 17 CANO+"-"+CMES+" A "+CANO+"-"+CMES                                                                                                                                                                                                    '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','048','5NUMERO DE MESES LABORADO                          2  "01"                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','049','6RUC DE LA EMPRESA                                 13 SM0->M0_CGC                                                                                                                                                                                         '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','050','6CODIGO DE LA SUCURSAL                             4  "00"+SM0->M0_CODFIL                                                                                                                                                                                 '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','051','6ANO ACTUAL                                          4CANO                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','052','6MES ACTUAL                                          2CMES                                                                                                                                                                                                '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','053','6TIPO MOVIMIENTO                                   3  "MND"                                                                                                                                                                                               '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','054','6NR. CEDULA DEL EMPLEADO AFECTADO                  10 SRA->RA_RG                                                                                                                                                                                          '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','055','6FECHA DE INICIO DE LOS DIAS NO LABORADOS            8GRAVADATA(DDTINI,.F.,8)                                                                                                                                                                             '})
AAdd(aTabRCC,{cFilRCC,cNomeArq, Space(FWGETTAMFILIAL),'      ','056','6DIAS NO LABORADOS                                   2TRANSFORM(NDURAC,"@E 99")                                                                                                                                                                           '})

//grava as tabelas

	For nI := 1 To Len(aTabRCC)
		RecLock('RCC',.T.)
		Replace RCC_FILIAL With aTabRCC[nI][01]
		Replace RCC_CODIGO With aTabRCC[nI][02]
		Replace RCC_FIL    With aTabRCC[nI][03]
		Replace RCC_CHAVE  With aTabRCC[nI][04]
		Replace RCC_SEQUEN With aTabRCC[nI][05]
		Replace RCC_CONTEU With aTabRCC[nI][06]
		MsUnLock()
	Next nI


	MsgInfo(STR0010 , STR0009) //Aviso#Tabelas Carregadas

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPER875DELบAutor  ณLuis Trombini       บ Data ณ  21/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga tabelas RCC correspondentes aos Arquivos Magneticos doบฑฑ
ฑฑบ          ณEquador .                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GPER875DEL()

Local nAux := 1
Local aNomeTab := {}

Aadd(aNomeTab,"S022")

For nAux:= 1 to 1
	If RCC->(dbSeek(cFilRCC + aNomeTab[nAux]),.T.)
    	While RCC->( !Eof() ) .And. RCC->(RCC_FILIAL+RCC_CODIGO) == cFilRCC+aNomeTab[nAux]
			IF RCC->( RecLock( "RCC" , .F. , .F. ) )
				RCC->( dbDelete() )
				RCC->( MsUnLock() )
			EndIF
			RCC->( DbSkip() )
		EndDo
	Endif
Next

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetcIess  บAutor  ณLuis Trombini       บ Data ณ  21/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Codigo da causa de dispenda do IESS              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ   PARAMETROS:                                              บฑฑ
ฑฑบ          ณ    cTabela     == Nome da tabela que sera pesquisada       บฑฑ
ฑฑบ          ณ    cOperador   == Tipo de comparacao de valores            บฑฑ
ฑฑบ          ณ    cCodRes     == Codigo da Rescisao                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RetcIess(cTabela,cOperador,cCodres)

Local nPos := 0
Local cIess := 0

nPos := fPosTab(cTabela, cCodRes , cOperador, 4  )

If nPos > 0
	cIess := IF( FTABELA(cTabela, nPos , 14 ) <> NIL, FTABELA(cTabela,  nPos, 14 ) , 0 )
Endif

Return cIess


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfTpoProce บAutor  ณLuis Trombini       บ Data ณ  21/09/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega janela com opcoes dos Processos.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function fTpoProce()

Local cTitulo	:= STR0016  //"tipo de relatorio"
Local cString	:= ""
Local MvParDef	:= ""
Local MvRetor	:= ""
Local nFor		:= 0
Local MvPar
Local lExiste   := .F.
Private aSit	:= {}

cAlias := Alias() 					// Salva Alias Anterior

If Upper(Alltrim(ReadVar() )) == "MV_PAR01"
	MvPar:=&(Alltrim(ReadVar()))	// Carrega o conteudo da variavel
	mvRet:=Alltrim(ReadVar())		// carrega o nome da variavel
Endif

CursorWait()

MvParDef:= "123456"

aAdd(aSit, "Aviso de Entrada")
aAdd(aSit, "Aviso de Salida")
aAdd(aSit, "Cambio de Sueldo")
aAdd(aSit, "Cambio Sueldo por H.E.")
aAdd(aSit, "Valores Fondo Reserva")
aAdd(aSit, "Aviso dias No Laborados")

CursorArrow()

	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,1,1)
		CursorWait()
		For nFor := 1 To Len( MvPar )
		   	IF ( SubStr( mVpar , nFor , 1 ) # "*" )
				mvRetor += SubStr( mVpar , nFor , 1 )
		  	Endif
	   	Next nFor
		&MvRet := Alltrim(Mvretor)  //carrega o resultado da fopcoes
		CursorArrow()
	EndIF

dbSelectArea(cAlias) // Retorna Alias

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณfProcm    ณ Autor ณ Luis Trombini       ณ Data ณ 21/09/2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณSelecionar o Processo                               		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ fProcesso() 												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/

Function fProcM(l1Elem, lTipoRet, aElem)

Local cTitulo	:=""
Local nFor		:= 0
Local nElem		:= 0
Local MvPar
Local MvParDef	:=""
Local MvRetor	:= ""
Local nX3Tam	:= 0

Private aSit:={}
l1Elem := If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet 	:= .T.
DEFAULT aElem		:= {}

cAlias := Alias() 					// Salva Alias Anterior

IF lTipoRet
	MvPar:=&(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

dbSelectArea("RCJ")
If dbSeek(cFilial)
	CursorWait()
	While !Eof() .And. RCJ->RCJ_FILIAL == cFilial
		If allTrim(RCJ->RCJ_CODIGO) != ""
			Aadd(aSit, RCJ->RCJ_CODIGO + " - " + Alltrim(RCJ->RCJ_DESCRI))
			MvParDef += RCJ->RCJ_CODIGO
		Endif
		dbSkip()
	Enddo
	If Len(aElem) > 0
		For nElem := 1 to Len(aElem)
			Aadd(aSit, aElem[nElem]) 				//"EXT - Valores Extras"
			MvParDef += SubStr(aElem[nElem], 1, 3)	//MvParDef += "EXT"
		Next nElem
	EndIf
	CursorArrow()
Endif

IF lTipoRet
	nX3Tam := GetSx3Cache("RCJ_CODIGO","X3_TAMANHO")
	IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,,,l1Elem, nX3Tam)  // Chama funcao f_Opcoes
		CursorWait()
		For nFor := 1 To Len( mVpar ) Step 3
			IF ( SubStr( mVpar , nFor , 3 ) # "***" )
				mvRetor += SubStr( mVpar , nFor , 3 )
			Endif
		Next nFor
	   	If( Empty(mvRetor) )
			mvRetor := Space(nX3Tam)
		EndIf
		&MvRet 	:= mvRetor
		CursorArrow()
	EndIF
EndIF

dbSelectArea(cAlias) // Retorna Alias

Return( IF( lTipoRet , .T. , MvParDef ) )


/****************************/
Static Function LimpiaStatic()
	aRemune	:=	Nil
	aDatasSR8:=	Nil
Return