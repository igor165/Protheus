#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA480.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё gpea480  Ё Autor Ё Valdeci Lira          Ё Data Ё 19.09.07 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Cadastro dos Acumuladores                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁWinstonCostaЁ02/01/19ЁDRHPAG-22991ЁRetirada do trecho que trata o      Ё╠╠
╠╠Ё            Ё        Ё            ЁAS/400                              Ё╠╠
╠╠ЁOscar G.    Ё04/04/20ЁDMINA-8784  ЁCrea grupo de preguntas GPEA480B  p/Ё╠╠
╠╠Ё            Ё        Ё            Ёpaises diferentes de Brasil. (MEX)  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function Gpea480()
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

cCadastro := OemToAnsi(STR0001)  //"Cadastro dos Acumuladores"
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o Arquivo Esta Vazio                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !ChkVazio("SRA")
		Return( NIL )
	Endif   
	
   	If( MV_MODFOL != "2" ) .And. !(cPaisLoc $ "ARG/VEN/COL")
		Help("",1,"NAO_DISPONIVEL" )
		Return( NIL )
	EndIf

	dbSelectArea("SRA")
	mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

Return( NIL )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Valdeci Lira     Ё Data Ё25/10/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA480                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
*/

Static Function MenuDef()

 Local aRotina :=  { 											 ;
						{	STR0010 , "Gpea480Mnt"	, 0 , 1 },	 ;  //"Visualizar"
						{	STR0018 , "GpLegend"	, 0 , 2 }	 ;  //"Legenda"
	                }                                                             
	                
Return aRotina
/*
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGp480Mnt     Ё Autor ЁValdeci Lira         Ё Data Ё26/09/2007Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o Ё     				    									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGp480mnt  													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
*/
Function Gpea480Mnt( cAliasRG7 , nReg , nOpcx )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis Local                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aButtons		:= {}
Local aArea			:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aVirtual		:= {}
Local aRG7Cols		:= {}
Local aColsRec		:= {}
Local nOpcao		:= 0 //0- BOTAO CANCELAR SELECIONADO, 1- BOTAO OK ACIONADO
Local nCoordLin		:= 0
Local bFreeLocks	:= {|| FreeLocks("RG7" , NIL , .T. ), .T.}
Local aPesqIdx 		:= {}
Local aPesqOrd		:= {}
Local lSeeAll		:= .T.
Local cPesqOrd
Local cPesqCampo	:= space(40)
Local lAxPesqui 	:= .F.
Local cPerg			:= IIf(cPaisLoc == "BRA", "GPEA480", "GPEA480B")

/*
зддддддддддддддддд©
ЁObjetos          Ё
юддддддддддддддддды*/
Local oFont
Local oGroup
Local oDlg
Local oBtnPgNext
Local oBtnPgPrev
Local oBntNext
Local oBntPrev
Local oPesqCbx
Local oPesqGet
Local oANOINIe
Local oCriterio
Local oRoteiro
Local oFunc

//Variaveis do Pergunte
Private cAnoIniDe
Private cAnoIniAte
Private cAnoFimDe
Private cAnoFimAte
Private cRoteiroDe		
Private cRoteiroAte		
Private cCodigo      
Private cTipoExibicao

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis Privadas                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private aTELA			:= {}
Private aGETS			:= {}
Private aHeader 	    := {}
Private aCols			:= {}
Private aColsAnt		:= {}
Private aGdAltera		:= {}
Private cFil			:= SRA->RA_FILIAL
Private cMat     		:= SRA->RA_MAT
Private cNome    		:= SRA->RA_NOME
Private	cCategoria		:= SRA->RA_CATFUNC
Private cProcesso		:= SRA->RA_PROCES
Private cPosto 			:= SRA->RA_POSTO 
Private cUsuario		:= ""
Private cDataAtualiza   := DToc(dDataBase)

//Posicoes das colunas
Private nPosProces	:= 0
Private nPosPD		:= 0
Private nPosDescPD	:= 0
Private nPosRoteiro	:= 0
Private nPosCodCri	:= 0
Private nPosAnoFim	:= 0
Private nPosANOINI	:= 0
Private nPosSeqAcu	:= 0
Private nPosHoras	:= 0
Private nPosValor	:= 0
Private nPosUsuari	:= 0
Private nPosDtAtua	:= 0
Private nPosDeleted	:= 0

Private oGet
Private lSRCLock		:= .F.
Private cCond			:= "1"
Private lDaRefresh 		:= .F.

If !Pergunte(cPerg,.T.)
	Return .F.
Else
	cAnoIniDe  		:= if( Empty(mv_par01), "0000", mv_par01)
	cAnoIniAte 		:= if( Empty(mv_par02), "9999", mv_par02)
	cAnoFimDe 	 	:= if( Empty(mv_par03), "0000", mv_par03)
	cAnoFimAte 		:= if( Empty(mv_par04), "9999", mv_par04)
	If cPaisloc == "BRA"
		cRoteiroDe	 	:= If( Empty(mv_par05), ""   , mv_par05)
		cRoteiroAte		:= If( Empty(mv_par06), ""   , mv_par06)
		cCodigo 		:= if( Empty(mv_par07), ""   , mv_par07)
		cCodigo			:= if( !Empty(mv_par08), cCodigo += mv_par08, cCodigo += ""  )
	Else
		cCodigo 		:= if( Empty(mv_par05), ""   , mv_par05)
		cCodigo			:= if( !Empty(mv_par06), cCodigo += mv_par06, cCodigo += ""  )
	EndIF
EndIf

//VERIFICA O USUARIO LOGADO
If __cUserId == Nil .Or. Empty(__cUserId)
	cUsuario := "000000"
Else
	cUsuario := __cUserId
EndIf

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Esta variavel, a nOpcNewGd, informara a instancia da GetDadosЁ
Ё o que podera ser feito na get. So alterar..., ou So inserir..Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
_SetOwnerPrvt( "nOpcNewGd", IF( nOpcX == 1 .or. nOpcX == 4 , 0 , GD_INSERT + GD_UPDATE + GD_DELETE))

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Monta as Dimensoes dos Objetos         					   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

cCadastro := OemToAnsi(STR0001)
Begin Sequence

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define Qual Alias sera utilizado                             Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cAliasRG7 := "RG7"

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cria os Arrays de Campos para logo abaixo instanciar a       Ё
	Ё getDados e exibir os campos segundo as variaveis montadas    Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSelectArea(cAliasRG7)
	If !gp480MontaGetDados(cAliasRG7, nOpcX, cFil, cMat, @aVirtual, @aColsRec, @aRG7Cols)
		MsgAlert( OemToAnsi(STR0019), OemToansi(STR0020) )
		Return .F.
	EndIf

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	/*
	зддддддддддддддддддддддддддддддддд©
	Ё Define grupo do cabecalho       Ё
	юддддддддддддддддддддддддддддддддды*/
 /*зддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё Matricula, Nome, Admissao, Processo e Posto       Ё
   юддддддддддддддддддддддддддддддддддддддддддддддддддды*/
   //CRIA OS GROUPS
   //[POSICAO DE INICIO]                           [POSICAO DE FIM] (ABRE COMO O DESENHO DE UMA CAIXA)[TAMANHO DO OBJETO][CAPTION DO OBJETO, NESTE CASO LABEL]
	@ aObjSize[1,1],aObjSize[1,2] 			GROUP oGroup TO aObjSize[1,3], aObjSize[1,4]*0.18 	LABEL OemToAnsi(STR0004) OF oDlg PIXEL // Matricula:
	oGroup:oFont:= oFont
	@ aObjSize[1,1],aObjSize[1,4]*0.185 	GROUP oGroup TO aObjSize[1,3], aObjSize[1,4]*0.65 	LABEL OemToAnsi(STR0005) OF oDlg PIXEL // Nome:
	oGroup:oFont:= oFont
	@ aObjSize[1,1],aObjSize[1,4]*0.655 	GROUP oGroup TO aObjSize[1,3], aObjSize[1,4]*0.75	LABEL OemToAnsi(STR0006) OF oDlg PIXEL	// Admiss└o:
	oGroup:oFont:= oFont
	@ aObjSize[1,1],aObjSize[1,4]*0.755 	GROUP oGroup TO aObjSize[1,3], aObjSize[1,4]*0.85 	LABEL OemToAnsi(STR0007) OF oDlg PIXEL // Processo:
	oGroup:oFont:= oFont
	@ aObjSize[1,1],aObjSize[1,4]*0.855 	GROUP oGroup TO aObjSize[1,3], aObjSize[1,4] 		LABEL OemToAnsi(STR0008) OF oDlg PIXEL // Posto:
	oGroup:oFont:= oFont

	@ aObjSize[1,1]+10, aObjSize[1,2] * 2.5 	SAY oFunc Var cMat 					SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10, aObjSize[1,4] * 0.2	SAY OemToAnsi(SRA->RA_NOME)			SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10, aObjSize[1,4] * 0.67	SAY Dtoc(SRA->RA_ADMISSA) 			SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10, aObjSize[1,4] * 0.77	SAY OemToAnsi(SRA->RA_PROCES) 		SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+10, aObjSize[1,4] * 0.87	SAY OemToAnsi(SRA->RA_POSTO)		SIZE 050,10 OF oDlg PIXEL FONT oFont

    //INSTANCIA A GETDADOS
   	oGet := MsNewGetDados():New(aObjSize[2,1]	,;	// nTop
							 aObjSize[2,2]		,;  // nLelft
							 aObjSize[2,3]		,;	// nBottom
                             aObjSize[2,4]		,;	// nRright
							 nOpcNewGd			,;	// controle do que podera ser realizado na GetDado - nstyle
							 "Gpea480LinOk"		,;	// funcao para validar a edicao da linha - ulinhaOK
							 "Gpea480TudOk"		,;	// funcao para validar todas os registros da GetDados - uTudoOK
  							 NIL				,;	// cIniCPOS
							 aGdAltera			,;	// aAlter
							 0					,; 	// nfreeze
							 99999				,;  // nMax
							 Nil				,;	// cFieldOK
							 NIL				,;	// usuperdel
							 .T.				,;	// udelOK
							 @oDlg				,;  // objeto de dialogo - oWnd
							 @aHeader			,;	// Vetor com Colunas - AparHeader
							 @aRG7Cols			;	// Vetor com Header - AparCols
							)

 	oGet:oBrowse:bLostFocus := { || If(!Gpea480LinOk(), oGet:oBrowse:SetFocus(), .T.) }

    //INICIA COMO ZERO DEFAULT INDICANDO
    //QUE O BOTAO PADRAO A SER SELECIONADO E O
    //CANCELAR, CASO SEJA O BOTAO OK, ENTAO O
    //BLOCO DE CODIGO BSET15 SERA EXECUTADO MUDANDO O FLAG PARA 1
    //INDICANDO ASSIM QUE O USUARIO CLICOU NO BOTAO OK
    nOpcao := 0

	//BOTAO OK DA ENCHOICEBAR
	bSet15	:= {|| nOpcao :=1, ;
				If(oGet:TudoOk(), oDlg:End(), nOpca:=0)  }

	//BOTAO CANCELAR DA ENCHOICEBAR
	bSet24	:= {|| nOpcao :=0, oDlg:End()}

	//SETA AS PROPIEDADES, OU OS EVENTOS DOS BOTOES ACIMA NA ENCHOICE BAR
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24, NIL , aButtons )

	//VERIFICA A NECESSIDADE DE GRAVACAO DO REGISTRO, CONSIDERANDO AS OPCOES DE ALTERAR
	// OU INCLUIR E SE O BOTAO PRESSIONADO FOR O "OK"
	IF ( nOpcao == 1 )
       MsAguarde( { || Gpea480Grava(cAliasRG7,cFil,cMat,aVirtual,aColsRec,nOpcx,.F.,.F.) }, OemToAnsi(STR0002))
	EndIF

End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Libera Locks						                           Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If ( lSRCLock )
	FreeLocks( "RG7" , NIL , .T. )
EndIf

Return( NIL )

/*
зддддддддддбдддддддддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд©
ЁFun┤┘o    Ёgp480MontaGetDados Ё Autor Ё Valdeci Lira          Ё Data Ё27/09/2007							 Ё
цддддддддддедддддддддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддддддддддддддддддддддддддддддд╢
ЁDescri┤┘o ЁMontar a GetDados de acordo com o periodo informado             						          Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддЁ
ЁSintaxe   Ёgp480MontaGetDados(cAliasRG7, nOpcX, cFil, cMat, aVirtual, aColsRec, aRG7Cols)                     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcAliasRG7                                                                               		      Ё
Ё          ЁnOpcX  																							   Ё
Ё          ЁcFil - Filial.																					   Ё
Ё          ЁcMat - Matricula.																				   Ё
Ё          ЁaVirtual - array dos campos virtuais.															   Ё
Ё          ЁaColsRec - array que contem o Recno() dos registros da aCols.									   Ё
Ё          ЁaRG7Cols 																					       Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁLogico                                                          								   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGpea480Mnt                                                            							   Ё                                                          							   Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function gp480MontaGetDados(cAliasRG7, nOpcX, cFil, cMat, aVirtual, aColsRec, aRG7Cols)

	//DECLARACAO DE VARIAVEIS LOCAIS
	Local aGdNaoAltera	:= {}
	Local bSkip			:= { || .F. }
	Local cQueryCond	:= ""
	Local aGpa480Field	:= {}
	Local nUsado  		:= 0
	Local aVisual		:= {}
	Local cKeySeek		:= ""
	Local nX			:= 0
	Local nI 			:= 0
	Local nTamArray		:= 0
	Local lRet			:= .T.
	Local nForIni		:= 0

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta Bloco para Skip em GdMontaCols                         Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	//bSkip := { || .F. }
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta Query para a Selecao das Informacoes em GdMontaCols    Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	#IFDEF TOP
		cQueryCond	:= "RG7_FILIAL='"+cFil+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "RG7_MAT='"+cMat+"'"

		IF !Empty( cAnoIniDe )
			cQueryCond	+= " AND "
			cQueryCond	+= "RG7_ANOINI>='"+cAnoIniDe+"'"
		EndIF

		IF !Empty( cAnoIniAte )
			cQueryCond	+= " AND "
			cQueryCond	+= "RG7_ANOINI<='"+cAnoIniAte+"'"
		EndIF

		IF !Empty( cAnoFimDe )
			cQueryCond	+= " AND "
			cQueryCond	+= "RG7_ANOFIM>='"+cAnoFimDe+"'"
		EndIF

		IF !Empty( cAnoFimAte )
			cQueryCond	+= " AND "
			cQueryCond	+= "RG7_ANOFIM<='"+cAnoFimAte+"'"
		EndIF

		If cPaisLoc == "BRA"
			cQueryCond	+= " AND RG7_ROTEIR BETWEEN "
	
			IF !Empty( cRoteiroDe )
				cQueryCond	+= "'"+cRoteiroDe+"'" 
			ELSE
				cQueryCond += "''"
			EndIF
	
			cQueryCond	+= " AND "     
	
			IF !Empty( cRoteiroAte )
				cQueryCond	+= "'"+cRoteiroAte+"'"
			Else
				cQueryCond  += "''"
			EndIf
		EndIf
			
		If !Empty( AllTrim(cCodigo) )
			nForFim := Len(AllTrim(cCodigo))
			cQueryCond += " AND RG7_PD IN ("
			For nForIni := 1 To nForFim Step 3 
				cQueryCond	+= "'" 
				cQueryCond += Substr(cCodigo,nForIni,3)
				If ( (nForIni+3) < nForFim )
					cQueryCond	+= "',"
				Else
					cQueryCond	+= "'" 
				EndIf
			Next nForIni
			cQueryCond	+= ")" 
		EndIf  
	        
		cQueryCond	+= " AND "
		cQueryCond	+= "D_E_L_E_T_<> '*' "
	#ENDIF

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define os Campos que nao serao Mostrados                     Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	aGpa480Field	:= {;  
							"RG7_FILIAL"	,;
							"RG7_MAT"	 	,;
							"RG7_NOME"   	;
						}


	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta os Detalhes                                    		   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	RG7->( dbSetOrder( RetOrder( "RG7" , "RG7_FILIAL+RG7_MAT+RG7_ANOINI" ) ) )
	aRG7Cols := GdMontaCols(@aHeader,@nUsado,@aVirtual,@aVisual,cAliasRG7,aGpa480Field,@aColsRec,cAliasRG7,cKeySeek,NIL,bSkip,NIL,NIL,NIL,NIL,NIL,NIL,cQueryCond,.F.,.F.,.T.)
	RG7->( dbSetOrder(1) )

	//RESGATA A POSICAO DOS CAMPOS
	nPosProcess		:= GdFieldPos( "RG7_PROCES" , aHeader )
	nPosCodCri		:= GdFieldPos( "RG7_CODCRI" , aHeader )
	nPosRoteiro		:= GdFieldPos( "RG7_ROTEIR" , aHeader )
	nPosPD			:= GdFieldPos( "RG7_PD"	    , aHeader )
	nPosDescPD		:= GdFieldPos( "RG7_DESCPD"	, aHeader )
	nPosAnoFim		:= GdFieldPos( "RG7_ANOFIM"	, aHeader )
	nPosAnoIni		:= GdFieldPos( "RG7_ANOINI"	, aHeader )
	nPosSeqAcu		:= GdFieldPos( "RG7_SEQACU"	, aHeader )
	nPosHoras		:= GdFieldPos( "RG7_HORAS"	, aHeader )
	nPosValor		:= GdFieldPos( "RG7_VALOR"	, aHeader )
	nPosUsuari		:= GdFieldPos( "RG7_USUARI"	, aHeader )
	nPosDtAtua		:= GdFieldPos( "RG7_DTATUA"	, aHeader )
	nPosDeleted		:= GdFieldPos( "GDDELETED" )
    /*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega, apenas, os Campos Editaveis            			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	aGdAltera := {}
	For nX := 1	To nUsado
		IF (;
				( aScan( aVirtual 		, aHeader[ nX , 02 ] ) == 0 );
				.and.;
		   		( aScan( aVisual  		, aHeader[ nX , 02 ] ) == 0 );
		   		.and.;
		   		( aScan( aGpa480Field	, aHeader[ nX , 02 ] ) == 0 );
		   		.and.;
		   		( aScan( aGdNaoAltera	, aHeader[ nX , 02 ] ) == 0 );
		  	)
			aAdd( aGdAltera , aHeader[ nX , 02 ] )
		EndIF
	Next nX
    
	//CARREGA AS DESCRICOES DE VERBAS
	For nI := 1 To Len(aRG7Cols) 
		aRG7Cols[ nI, nPosDescPD ] := fDesc( "SRV" , aRG7Cols[ nI, nPosPD ] , "RV_DESC" )
	Next

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё salva o acols e o periodo antes da alteracao 	 			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	aColsAnt	:= aClone( aRG7Cols )
	
	// atualiza a getdados
	If !(oGet == nil)
		oGet:aCols := aClone(aRG7Cols)
		oGet:Refresh()
	EndIf
	
	If ( Empty(aRG7Cols[ 01, nPosDescPD ]) .and. Len(aRG7Cols) == 1 )
		lRet := .F.
	EndIf

Return (lRet)

Function Gpea480LinOk( oBrowse )
	Local cChave := "" 
	Local cCriterioDe := ""  
    Local lTudoIgual  := Nil
    Local lChaveIgual := .F.
    
	//VERIFICA SE ESTA DENTRO DA DATA LIMITADA 'NO PERGUNTE'
	If !(oGet:aCols[ oGet:oBrowse:nRowPos , nPosAnoIni] >= cAnoIniDe) .AND. !(oGet:aCols[ oGet:oBrowse:nRowPos , nPosAnoIni] <= cAnoIniAte)
		oGet:SetFocus()
		msgAlert( OemToAnsi( STR0012 ) )
		Return .F.
	EndIF 
	
	//VERIFICA SE ESTA DENTRO DO CRITERIO LIMITADO 'NO PERGUNTE'
	If !(oGet:aCols[ oGet:oBrowse:nRowPos , nPosCodCri ] >= cCriterioDe) .AND. !(oGet:aCols[ oGet:oBrowse:nRowPos , nPosCodCri ] <= cCriterioAte)
		
		oGet:SetFocus()
		msgAlert( OemToAnsi( STR0013 ) )
		Return .F.
	EndIF
	
	lTudoIgual := ArrayCompare( oGet:aCols[ oGet:oBrowse:nRowPos ] , aColsAnt[ oGet:oBrowse:nRowPos ] )
	lExisteCampoVazio := Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosProcess ]);
								.OR. ;
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosRoteiro ]);
								.OR. ;			
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosPD ]);
								.OR. ;
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoFim ]);
								.OR. ;
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoIni ]);
								.OR. ;
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosCodCri ]);
								.OR. ;
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosSeqAcu ]);
								.OR. ;
							Empty(oGet:aCols[ oGet:oBrowse:nRowPos, nPosValor ])
							
	//VERIFICA SE EXISTEM CAMPOS OBRIGATORIOS VAZIOS
	If lExisteCampoVazio .AND. !(lTudoIgual) 
		oGet:SetFocus()
		msgAlert( OemToAnsi( STR0014 ) )
		Return .F.
	EndIf
	
	If Val(oGet:aCols[ oGet:oBrowse:nRowPos, nPosSeqAcu ]) <= 0 
		oGet:SetFocus()
		msgAlert( OemToAnsi( STR0015 ) )
		Return .F.
	EndIf
	
	If !ValidIntervAnoGP480( oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoIni ], oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoFim ])
		oGet:SetFocus()
		msgAlert( OemToAnsi( STR0016 ) )
		Return .F.
	EndIf
	
	//VERIFICA SE HOUVE ALTERACAO NA CHAVE  
	If !(oGet:oBrowse:nRowPos > Len(aColsAnt))
		lChaveIgual := oGet:aCols[ oGet:oBrowse:nRowPos, nPosPD ] == aColsAnt[ oGet:oBrowse:nRowPos, nPosPD ] ;
							.And. ; 
					   oGet:aCols[ oGet:oBrowse:nRowPos, nPosProcess ] == aColsAnt[ oGet:oBrowse:nRowPos, nPosProcess ] ;
							.And. ;
					   oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoFim ] == aColsAnt[ oGet:oBrowse:nRowPos, nPosAnoFim ] ;
							.And. ;
					   oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoIni ] == aColsAnt[ oGet:oBrowse:nRowPos, nPosAnoIni ]		
	Else
		lChaveIgual := .F.
	EndIf	
	
	//VERIFICA SE JA EXISTE A CHAVE DIGITADA 
	cChave := cFil+cMat
	cChave += oGet:aCols[ oGet:oBrowse:nRowPos, nPosPD ]
	cChave += oGet:aCols[ oGet:oBrowse:nRowPos, nPosProcess]
	cChave += oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoFim ]
	cChave += oGet:aCols[ oGet:oBrowse:nRowPos, nPosAnoIni ] 
	
	//ExistChav( "RG7", cChave, 1 )
	If RG7->( dbSeek( cChave )) .And. !lChaveIgual 
		Help(STR0017,1,"EXISTCHAV")
		Return .F.
	EndIf     
	
Return .T.

Function Gpea480TudOk( oBrowse )       
	Local nI 		   := 0
	Local nTotalLinhas := Len(oGet:aCols)
	
	For nI:=1 To nTotalLinhas
		oGet:oBrowse:nRowPos := nI
		If !(Gpea480LinOk( oBrowse ))
			oGet:SetFocus()
			Return .F.
		EndIf
	Next
Return .T.       
/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁValidPD   Ё Autor Ё Valdeci Lira          Ё Data Ё03/09/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValida o Intervalo de Anos Digitados				        Ё
Ё 		   Ё		                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁValidIntervAnoGP480( nAnoIni, nAnoFim )                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁLogico por se Tratar de Validacao                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID do campo RG7_PD                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function ValidIntervAnoGP480(nAnoIni, nAnoFim)

 	nAnoIni := Val(nAnoIni)   
 	nAnoFim := Val(nAnoFim)
	If !(nAnoIni > 1900) .Or. !(nAnoFim > 1900)	
		Return .F.
	EndIf
	
	If nAnoFim < nAnoIni
		Return .F.
	EndiF
	
Return .T.

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁValidPD   Ё Autor Ё Valdeci Lira          Ё Data Ё03/09/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidar o Conteudo do RG7_PD e Preencher o conteudo de      Ё
ЁDescri┤┘o ЁRG7_DESC                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁValidPD( )                                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁLogico por se Tratar de Validacao                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID do campo RG7_PD                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function ValidPd()
	Local cValorCampo := &( ReadVar() )
	
	oGet:aCols[oGet:oBrowse:nRowPos , nPosDescPD] = fDesc( "SRV" , cValorCampo , "RV_DESC" )
	
Return .T.

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠Ё                                                                       Ё╠╠
╠╠Ё                                                                       Ё╠╠
╠╠Ё                   ROTINAS DE CRITICA DE CAMPOS                        Ё╠╠
╠╠Ё                                                                       Ё╠╠
╠╠Ё                                                                       Ё╠╠
╠╠юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpea480GravaЁ Autor Ё Valdeci Lira 		 Ё Data Ё27/09/2007Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁGrava no arquivo de Acumuladores      	                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      ЁGPEA480                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function Gpea480Grava( cAlias , cFil , cMat , aVirtual , aRegAltera , nOpc, lMontaGetDados, lPerg )

Local aRG7Cols			:= ( oGet:aCols )						//-> MATRIZ QUE REPRESENTA A GETDADOS
Local cPrefixo			:= ( PrefixoCpo( cAlias ) + "_" )
Local cCampo			:= ""
Local lTudoIgual		:= .F.
Local lAlteraOrig   	:= .F.
Local nX 				:= 0    								//-> CONTADOR
Local nY 				:= 0
Local nLenHeader		:= Len( aHeader 	)                   //-> QUANTIDADE DE CAMPOS NA GETDADOS
Local nLenCols			:= Len( aRG7Cols   	)					//-> QUANTIDADE DE LINHAS NA GETDADOS
Local nLenRegAlt		:= Len( aRegAltera	)					//-> MATRIZ DA GETDADOS ANTES DA ALTERACAO


	//VERIFICA SE HOUVE ALTERACOES NOS CAMPOS DA GETDADOS
	If !ArrayCompare( aRG7Cols , aColsAnt )
		
		Begin Transaction 
			If lPerg //Se deve fazer a pergunta ...
				If !(MsgYesNo( OemToAnsi( STR0009 ) ) )	//"Deseja salvar as alteracoes?"
					Break
				EndIf
			EndIf

			//ATUALIZA OS CAMPOS SE NECESSARIO
			IF ( nLenRegAlt > 0 )
				For nX := 1 To nLenRegAlt
					lTudoIgual := ArrayCompare( aRG7Cols[ nX ] , aColsAnt[nX] )
					
					//VERIFICA SE A LINHA CORRENTE FOI ALTERADA
					IF ( lTudoIgual ) .and. !( aRG7Cols[nX,nPosDeleted] )            
						Loop
					EndIF
                    
                    //SE TRATA DA INCLUSAO DO PRIMEIRO REGISTRO E SOMENTE 1 REGISTRO
					If !(lTudoIgual) .AND. Empty(aColsAnt[ 1, 1 ])
						Gpea480Incluir( cAlias , cPrefixo , cFil , cMat , aVirtual , ( nLenRegAlt + 1 ) )
						Loop
					EndIf
					
					//POSICIONA O REGISTRO DE ACORDO COM O RECNO
					( cAlias )->( dbGoto( aRegAltera[nX] ) )
					( cAlias )->( RecLock( cAlias , .F. , .T. ) )
					
					If ( aRG7Cols[nX,nPosDeleted] )
						(cAlias)->( dbDelete() )
					Else
						
						//SE SOMENTE FOI ALTERADA A LINHA ENTAO A LINHA SERA SETADA COMO ALTERADA
						//E UMA NOVA LINHA COM A ALTERACAO SERA VISUALIZADA MANTENDO ASSIM O HISTORICO
						//DE ANTES E DEPOIS
						
						//INSERE O NOVO REGISTRO PARA SUBSTITUIR A VISUALIZACAO DO ANTERIOR
						(cAlias)->(&(cPrefixo+"FILIAL"))	:= cFil
						(cAlias)->(&(cPrefixo+"MAT"   ))	:= cMat

						//CAMPOS DA GETDADOS
						(cAlias)->(&(cPrefixo+"FGALTE"))	:=  4    //INDICA O FLAG COMO REGISTRO INSERIDO POR CAUSA DE UMA ALTERACAO
						(cAlias)->(&(cPrefixo+"PROCES"))	:= aRG7Cols[nX,nPosProcess]
						(cAlias)->(&(cPrefixo+"ROTEIR"))  	:= aRG7Cols[nX,nPosRoteiro]
						(cAlias)->(&(cPrefixo+"PD"    )) 	:= aRG7Cols[nX,nPosPD     ]
						(cAlias)->(&(cPrefixo+"ANOFIM")) 	:= aRG7Cols[nX,nPosAnoFim ]
						(cAlias)->(&(cPrefixo+"ANOINI")) 	:= aRG7Cols[nX,nPosAnoIni ]
						(cAlias)->(&(cPrefixo+"CODCRI")) 	:= aRG7Cols[nX,nPosCodCri ]
						(cAlias)->(&(cPrefixo+"SEQACU")) 	:= aRG7Cols[nX,nPosSeqAcu ]
						(cAlias)->(&(cPrefixo+"HORAS" )) 	:= aRG7Cols[nX,nPosHoras  ]
						(cAlias)->(&(cPrefixo+"VALOR" )) 	:= aRG7Cols[nX,nPosValor  ]
						(cAlias)->(&(cPrefixo+"USUARI")) 	:= cUsuario
						(cAlias)->(&(cPrefixo+"DTATUA")) 	:= cDataAtualiza
					EndIf
				   
					/*
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					ЁDestrava o Registro								           Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					( cAlias )->( MsUnLock() )
				Next nX

				// Se Trata de Inclusao de Itens
				If ( nLenCols > nLenRegAlt )
					Gpea480Incluir( cAlias , cPrefixo , cFil , cMat , aVirtual , ( nLenRegAlt + 1 ) )
				EndIf
			Else
				Gpea480Incluir( cAlias , cPrefixo , cFil , cMat , aVirtual , 1 )
			EndIf
			
			( cAlias )->( EvalTrigger() )
		
		End Transaction
	EndIf

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁGpea480IncluirЁ Autor ЁValdeci Lira		   Ё Data Ё 28.09.07 Ё╠╠
╠╠цддддддддддеддддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁGrava os registros Incluidos na GetDados	                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      ЁGpea480Incluir                                                Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Static Function Gpea480Incluir( cAlias , cPrefixo , cFil , cMat , aVirtual , nIniciar )

Local aRG7Cols		:=    ( oGet:aCols )
Local nLenCols		:= Len( aRG7Cols   ) //->QTDE DE LINHAS
Local cUserId		:= ""
Local nX			:= 0  //-> CONTADOR

For nX := nIniciar To nLenCols

	If !( aRG7Cols[nX,nPosDeleted] )
		(cAlias)->( RecLock(cAlias,.T.) )

		//CAMPOS FIXOS
		(cAlias)->(&(cPrefixo+"FILIAL"))	:= cFil
		(cAlias)->(&(cPrefixo+"MAT"   ))	:= cMat

		//CAMPOS DA GETDADOS
		//(cAlias)->(&(cPrefixo+"FGALTE"))	:= 3 //INDICA O FLAG COMO REGISTRO INSERIDO MANUALMENTE
		(cAlias)->(&(cPrefixo+"PROCES"))	:= aRG7Cols[nX,nPosProcess]
		(cAlias)->(&(cPrefixo+"ROTEIR"))  	:= aRG7Cols[nX,nPosRoteiro]
		(cAlias)->(&(cPrefixo+"PD"    )) 	:= aRG7Cols[nX,nPosPD     ]
		(cAlias)->(&(cPrefixo+"ANOFIM")) 	:= aRG7Cols[nX,nPosAnoFim ]
		(cAlias)->(&(cPrefixo+"ANOINI")) 	:= aRG7Cols[nX,nPosAnoIni ]
		(cAlias)->(&(cPrefixo+"CODCRI")) 	:= aRG7Cols[nX,nPosCodCri ]
		(cAlias)->(&(cPrefixo+"SEQACU")) 	:= aRG7Cols[nX,nPosSeqAcu ]
		(cAlias)->(&(cPrefixo+"HORAS" )) 	:= aRG7Cols[nX,nPosHoras  ]
		(cAlias)->(&(cPrefixo+"VALOR" )) 	:= aRG7Cols[nX,nPosValor  ]
		(cAlias)->(&(cPrefixo+"USUARI")) 	:= cUsuario
		(cAlias)->(&(cPrefixo+"DTATUA")) 	:= cDataAtualiza

		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁDestrava o Registro									       Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		( cAlias )->( MsUnLock() )
	EndIf
Next nX

Return( NIL )