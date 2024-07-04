#Include "PROTHEUS.CH"
#Include "GPEA1830.CH"

#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEA830  ³ Autor  ³ Luis Trombini          		   ³ Data ³04/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Gastos Pessoais - Equador                          		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA830()                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC            ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex        ³06/10/10³00000021052/2010³ Incluido o fPosTab para posicionamento   ³±±
±±³            ³        ³                ³ do codigo conforme a tabela S019.        ³±±
±±³Emerson Camp³28/02/12³00000004383/2012³ Alterado a validacao do RH5_ANO do linOK ³±±
±±³            ³        ³                ³ p/ uma funcao a partir de do X3_VALID e  ³±±
±±³            ³        ³                ³ inserido uma funcao de ajustaSX3 para    ³±±
±±³            ³        ³                ³ inserir esse nova funcao para o valid    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³30/04/15³      PCREQ-4256³Se elimina la funcion AjustaSX3() que     ³±±
±±³            ³        ³                ³ajusta el valid del campo RH5_ANO con     ³±±
±±³            ³        ³                ³motivo de las nuevas estructuras de las   ³±±
±±³            ³        ³                ³SXs para version 12                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA830(nOpcAuto, xAutoCab, xAutoItens, nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cFiltraSRA			//Variavel para filtro
LOCAL aIndexSRA	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private lGp830Auto := (xAutoCab <> Nil)
Private aAutoCab   := Nil
Private aAutoItens := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0008)  //"Controle de Periodos por Empregado"

If nOpcAuto <> Nil
	Do Case
		Case nOpcAuto == 3
			INCLUI := .T.
			ALTERA := .F.
		Case nOpcAuto == 4
			INCLUI := .F.
			ALTERA := .T.
		OtherWise
			INCLUI := .F.
			ALTERA := .F.
	EndCase

	dbSelectArea('SRA')
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
	If ( nPos <> 0 )
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	EndIf
Else
	If lGp830Auto
		aAutoCab	  := xAutoCab
		aAutoItens := xAutoItens
		If nOpc==3
			nOpc:=6//aRotina -> opçao Incluir
		EndIf
		mBrowseAuto(nOpc,aAutoCab,"SRA")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Arquivo Esta Vazio                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !ChkVazio("SRA")
				Return
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltraRh := CHKRH("GPEA830","SRA","1")
		bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
		Eval(bFiltraBrw)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SRA")
		dbGoTop()
		mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndFilBrw("SRA",aIndexSra)
	EndIf
EndIf
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ gp830atu ³ Autor ³ Mauro                 ³ Data ³ 13/10/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Atualizacao da Provisao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp830atu(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp830atu                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp830Mnt(cAlias,nReg,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos dados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea			:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local oFont
Local oDlg
Local nCnt								//Armazena a quantidade de registros de um determinado funcionario. Utilizada para verificar se usuario podera "Incluir" ou "Alterar".
Local cKey			:= ''				// variavel com os valores das chaves. (variavel para getdados da tabela RH5)
Local aNotFields	:= {}				// vetor com os campos que nao seria visualizados. (variavel para getdados da tabela RH5)
Local aRH5Cols		:= {}				// vetor com as colunas da GetDados SRF. (variavel para getdados da tabela RH5)
Local aRH5VisualGD	:= {} 				// vetor com os campos visuais. (variavel para getdados da tabela RH5)
Local oGroup							// Variavel do tipo objetos
Local bSet15		:= { || NIL }		// Bloco com as validacoes do botao OK. (variavel da janela)
Local bSet24		:= { || NIL }		// Bloco com as validacoes do botao Cancelar. (variavel da janela)
Local cQuery		:= ""
Local nT := 0

Private aHeader		:= {}				// vetor com o cabecalho da GetDados RH5. (variavel para getdados da tabela RH5)
Private nRH5Usado	:= 0.00 			// variavel que retorna a quantidade de campos da tabela. (variavel para getdados da tabela RH5)
Private aRH5ColsRec	:= {}				// vetor que contem os Recnos da tabela. (variavel para getdados da tabela RH5)
Private oGet							// Variavel do tipo objetos
Private aRH5VirtGd	:= {}				// vetor com os campos virtuais. (variavel para getdados da tabela RH5)
Private cMat     	:= ""
Private cFilFunc  	:= ""

Private aMemos := {}
Private aCols	:= {}

M->RH5_Codigo := ""

_SetOwnerPrvt( "nOpcNewGd", IF( nOpc == 2 .or. nOpc == 5 , 0 , GD_INSERT + GD_UPDATE + GD_DELETE))

//nSavRec        := RecNo()

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
   cFilFunc :=	xFilial("SRA")
  	If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RH5_MAT'})) > 0
		cMat :=	aAutoCab[nT,2]
 	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	If !dbSeek(xFilial("SRA")+cMat)
		Help( " ", 1, "REGNOIS" )
		Return
	EndIf
Else
	cMat     	:= SRA->RA_MAT
	cFilFunc  	:= SRA->RA_FILIAL
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lGp830Auto
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
EndIf

cAlias := "RH5"
Begin Sequence

	While .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcA:=0

		dbSelectArea(cAlias)
		dbSeek( cFilFunc + cMat )
	    nCnt := 0
	    While !EOF() .And. RH5_FILIAL + RH5_MAT == cFilFunc + cMat
			nCnt++
			dbSkip()
	    EndDo

	    If nCnt > 0  .And. nOpc = 3    //--Quando Inclusao e existir Registro
	        Help(" ",1,"A830EXIST")
			Exit
	    Elseif nCnt = 0 .And. nOpc # 3  //--Quando Nao for Inclusao e nao existir Registro
	        Help(" ",1,"A830NEXIST")
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Funcionario Esta Demitido                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_SITFOLH == "D"
			Help(" ",1,"A090DEMITI")
		Endif

		If !lGp830Auto
			DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
			DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta os Dados para a GetDados do SRF						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// campos que nao serao visualizados na getdados
		aAdd( aNotFields , "RH5_FILIAL" )
		aAdd( aNotFields , "RH5_MAT"    )
//		aAdd( aNotFields , "RH5_ANO"   )
//		aAdd( aNotFields , "RF_ADMISSA")

		#IFDEF TOP
			If TcSrvType() != "AS/400"
				cQuery := "  RH5_FILIAL = '" + cFilFunc + "'"
				cQuery += " AND "
				cQuery += "  RH5_MAT = '" + cMat + "'"
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ <> '*' "
			Else
				cQuery := NIL
			EndIf
		#ENDIF


		cKey  	 := ( cFilFunc + cMat )
		aRH5Cols := RH5->( GdMontaCols(	@aHeader		,;  //01 -> Array com os Campos do Cabecalho da GetDados
										@nRH5Usado		,;	//02 -> Numero de Campos em Uso
									 	@aRH5VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
									  	@aRH5VisualGd	,;	//04 -> [@]Array com os Campos Visuais
			                          	"RH5"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
									  	aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
									  	@aRH5ColsRec	,;	//07 -> [@]Array unidimensional contendo os Recnos
									  	"SRA"			,;	//08 -> Alias do Arquivo Pai
									  	cKey		 	,;	//09 -> Chave para o Posicionamento no Alias Filho
									    NIL				,;	//10 -> Bloco para condicao de Loop While
									    NIL				,;	//11 -> Bloco para Skip no Loop While
		  							    NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols
					  				    NIL				,;	//13 -> Se cria variaveis Publicas
							  		    NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
		  							    NIL				,;	//15 -> Lado para o inicializador padrao
				  					    NIL				,;	//16 -> Opcional, Carregar Todos os Campos
						  			    NIL 			,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
			  						    cQuery			,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
			  						    .F.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
			  						    .F.				 ;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
			 						  ))

		If !lGp830Auto
			@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO ( aObjSize[1,3] - 3 ),( ( aObjSize[1,4]/100*10 - 2 ) )				LABEL OemToAnsi(STR0012) OF oDlg PIXEL	// "Matricula:"
			oGroup:oFont:= oFont
			@ aObjSize[1,1] , ( ( aObjSize[1,4]/100*10 ) ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),( aObjSize[1,4]/100*80 - 2 )	LABEL OemToAnsi(STR0013) OF oDlg PIXEL	// "Nome:"
			oGroup:oFont:= oFont
			@ aObjSize[1,1] , ( aObjSize[1,4]/100*80 ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),aObjSize[1,4]						LABEL OemToAnsi(STR0014) OF oDlg PIXEL	// "Admiss„o:"
			oGroup:oFont:= oFont
			@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( aObjSize[1,2] + 5 )				SAY SRA->RA_MAT		SIZE 050,10 OF oDlg PIXEL FONT oFont
			@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( ( aObjSize[1,4]/100*10 ) + 5 )	SAY OemToAnsi(SRA->RA_NOME) 					SIZE 146,10 OF oDlg PIXEL FONT oFont
			@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( ( aObjSize[1,4]/100*80 ) + 5 )	SAY Dtoc(SRA->RA_ADMISSA)						SIZE 050,10 OF oDlg PIXEL FONT oFont

			oGet := MsNewGetDados():New(aObjSize[2,1]	,;	// nTop
										 aObjSize[2,2]	,;  // nLelft
										 aObjSize[2,3]	,;	// nBottom
			                             aObjSize[2,4]	,;	// nRright
										 nOpcNewGd		,;	// controle do que podera ser realizado na GetDado - nstyle
										 "gp830LinOk"	,;	// funcao para validar a edicao da linha - ulinhaOK
										 "Gp830TudOk"	,;	// funcao para validar todas os registros da GetDados - uTudoOK
		  								 NIL			,;	// cIniCPOS
										 NIL			,;	// aAlter
										 0				,; 	// nfreeze
										 99999			,;  // nMax
										 NIL			,;	// cFieldOK
										 NIL			,;	// usuperdel
										 If(nOpc=2.Or.nOpc=5,Nil,.T.),;		// udelOK
										 @oDlg			,; 	// objeto de dialogo - oWnd
										 @aHeader		,;	// Vetor com Colunas - AparHeader
										 @aRH5Cols		;	// Vetor com Header - AparCols
										)

			oGet:bDelOk:= {|| gp830ChkDel()}

			bSet15	:= {|| nOpca:= (IF(nOpc=5,2,1)), IF(oGet:TudoOk(),oDlg:End(),nOpca:=0)}
			bSet24	:= {|| oDlg:End()}
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

		Else
		   	If MsGetDAuto(aAutoItens,"gp830LinOk","Gp830TudOk",,nOpcNewGd)
			   	nOpcA:=If(nOpc=5,2,1)
		   	EndIf
		EndIf

        If nOpcA == Redigita
            LOOP
        ElseIf nOpcA == Confirma .And. nOpc # 2
            Begin Transaction
                //--Gravacao
                gp830Grava(cAlias, nOpc)
                //--Processa Gatilhos
  				( cAlias )->( EvalTrigger() )
            End Transaction
        Endif
		Exit
	EndDo

End Sequence

RestArea( aArea )
If ( nOpc == 3 )
	MBrChgLoop(.F.)
EndIf

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp830Grava³ Autor ³ Tatiane Matias        ³ Data ³ 27.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Periodos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp830Grava                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function gp830Grava(cAlias, nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis locais         					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRH5Cols  	:= {}
Local nX 			:= 0
Local ny			:= 0.00					// Contador de colunas.
Local nLenCols		:= 0		// Quantidade de linhas da SRF.
Local nLenRegAlt 	:= Len(aRH5ColsRec)
Local nLenHeader	:= Len( aHeader  )		// Quantidade de colunas da SRF.
Local cPrefixo		:= ( PrefixoCpo( cAlias ) + "_" )
Local cCampo		:= ""
Local nPosDeleted	:= GdFieldPos( "GDDELETED" )

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
	aRH5Cols  	:= aCols
Else
	aRH5Cols  	:= (oGet:aCols)
EndIf

nLenCols		:= Len(aRH5Cols)

Begin Transaction

	If ( nLenRegAlt > 0 )
		For nX := 1 To nLenRegAlt
			( cAlias )->( dbGoto( aRH5ColsRec[nX] ) )
			( cAlias )->( RecLock( cAlias , .F. , .T. ) )
			IF ( aRH5Cols[nX,nPosDeleted] )
				(cAlias)->( dbDelete() )
			Else
				(cAlias)->(&(cPrefixo+"FILIAL"))	:= cFilFunc
				(cAlias)->(&(cPrefixo+"MAT"))		:= cMat
				For nY := 1 To nLenHeader
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Obtem o Campo para Gravacao  							       ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					cCampo := aHeader[nY,2]

					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Nao Grava Campo Virtual									   ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//					IF ( aScan(aSRFVirtGd,cCampo) # 0 )
//						Loop
//					EndIF

					xConteudo := aRH5Cols[nX,nY]
					(cAlias)->( &cCampo ) := xConteudo

				Next nY
			EndIf

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Efetua a gravacao dos campos memos na tabela RE6.			   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			fGravaMemos(aMemos,cAlias)

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Destrava o Registro										   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			( cAlias )->( MsUnLock() )
		Next nX
		IF ( nLenCols > nLenRegAlt ) // Se Trata de Inclusao de Itens
			Gp830GrInc( cAlias , cPrefixo , ( nLenRegAlt + 1 ) )
		EndIF
	Else
		Gp830GrInc( cAlias , cPrefixo , 1 )
	EndIF

End Transaction

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp830GrInc  ³ Autor ³Tatiane Matias       ³ Data ³ 27.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros Incluidos na GetDados	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gp830GrInc                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Gp830GrInc( cAlias , cPrefixo , nIniciar )

Local aRH5Cols		:= {}
Local cCampo		:= ""
Local nLenHeader	:= Len( aHeader )
Local nLenCols		:= 0
Local nPosDeleted	:= GdFieldPos( "GDDELETED" )
Local nX			:= 0
Local nY 			:= 0

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
	aRH5Cols  	:= aCols
Else
	aRH5Cols  	:= (oGet:aCols)
EndIf

nLenCols		:= Len( aRH5Cols )

For nX := nIniciar To nLenCols
	IF !( aRH5Cols[nX,nPosDeleted] )
		(cAlias)->( RecLock(cAlias,.T.) )
		(cAlias)->(&(cPrefixo+"FILIAL"))	:= cFilFunc
		(cAlias)->(&(cPrefixo+"MAT"))		:= cMat
		For nY := 1 To nLenHeader
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Obtem o Campo para Gravacao  							       ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cCampo := aHeader[nY,2]

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Nao Grava Campo Virtual									   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//			IF ( aScan(aSRFVirtGd,cCampo) # 0 )
//				Loop
//			EndIF

			xConteudo := aRH5Cols[nX,nY]
			(cAlias)->( &cCampo ) := xConteudo
		Next nY

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Efetua a gravacao dos campos memos na tabela RE6.			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		fGravaMemos(aMemos,cAlias)

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Destrava o Registro										   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		( cAlias )->( MsUnLock() )
	EndIF
Next nX

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp830LinOk³ Autor ³ Tatiane Matias        ³ Data ³ 27.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp830LinOk()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis locais         					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRH5Cols		:= {}
Local aCposKey		:= {}
Local lRet		  	:= .T.
Local cHelp		  	:= ""
Local nPoscodigo	:= GdFieldPos( "RH5_CODIGO", aHeader )
Local nPosvalor 	:= GdFieldPos( "RH5_VALOR", aHeader )
Local cCodGast		:= ""
//Local nPosDiasDir	:= GdFieldPos( "RF_DIASDIR", aHeader )
//Local nPosDiasVenc	:= GdFieldPos( "RF_DFERVAT", aHeader )
//Local nPosDiasProp	:= GdFieldPos( "RF_DFERAAT", aHeader )

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
	aRH5Cols		:= aCols
Else
	aRH5Cols		:= (oGet:aCols)
EndIf

		If !aRH5Cols[n,nRH5Usado+1]
			/*/
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Verifica Se o Campos Estao Devidamente Preenchidos		   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
			aCposKey := GdObrigat( aHeader )
			lRet := GdNoEmpty( aCposKey )

//		    Em alguns casos, o inicio da contagem do periodo devera ser anterior a admissao do funcionario
//			If lRet .and. aSRFCols[n,nPosDtIni] < SRA->RA_ADMISSA
//				cHelp := OemToAnsi( STR0017 ) // A Data de Inicio do Periodo deve ser maior que a data de admissao
//				MsgInfo( cHelp , STR0015 )
//				lRet := .F.
//			EndIf

			nPosTab 	:= fPosTab("S019",aRH5Cols[n,nPosCodigo],"=",4)
			cCodGast	:= fTabela("S019",nPosTab,04)

			If lRet .and. !(aRH5Cols[n,nPosCodigo] $ cCodGast) // strzero(year(ddata_pgto),4)
				cHelp := OemToAnsi( STR0017 ) // "O codigo nao é Valido para a Deducao de Gastos Pessoais"
				If lGp830Auto
					AutoGrLog( cHelp )
				Else
					MsgInfo( cHelp , STR0015 )
				EndIf
				lRet := .F.
			EndIf
			If lRet .and. aRH5Cols[n,nPosValor] < 0.00
				cHelp := OemToAnsi( STR0018 ) // "O Valor tem que ser Maior que Zeros"
				If lGp830Auto
					AutoGrLog( cHelp )
				Else
					MsgInfo( cHelp , STR0015 )
				EndIf
				lRet := .F.
			EndIf

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Verifica Itens Duplicados na GetDados						   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If lRet
				aCposKey := { "RH5_ANO" , "RH5_CODIGO"}
				lRet := GdCheckKey( aCposKey , 4 )
			EndIf


		EndIf

Return( lRet )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gp830TudOk³ Autor ³Tatiane Matias         ³ Data ³27/04/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Gp830TudOk( ) 								      	        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Gp050Mnt()                                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gp830TudOk( )
	Local lRetorna  := .T.
	Continua := .F.
Return lRetorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp830VerEdit	  ³ Autor ³ Tatiane Matias        ³ Data ³27.04.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verificar se o registro poderá ser editado. So permitira efetuar  ³±±
±±³          ³manutencao nos periodos que nao foram utilizados em calculo,      ³±±
±±³          ³ou seja, quando o campo Dias Pagos for maior que zero.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp830VerEdit()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ When de todos os campos da tabela SRF SX3                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function gp830VerEdit()

Local lEdit 		:= .T.
Local aRH5Cols  	:= (oGet:aCols)
Local nPosDiasPg  	:= GdFieldPos( "RH5_VALOR", aHeader )

	If aRH5Cols[n, nPosDiasPg] > 0
		lEdit := .F.
	EndIf

Return (lEdit)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³gp830ChkDel   ³Autor³Tatiane Matias       ³ Data ³27/04/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica se o registro pode ser excluido.                   ³
³          ³O registro so podera ser excluido se o Dias Pagos for zero. ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³No bDelOk da oGet     .				                        ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function gp830ChkDel()

Local nPosDiasPg := GdFieldPos( "RH5_VALOR", aHeader )

lRet :=	!( aCols[n, nPosDiasPg] > 0 )

Return ( lRet )


/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³gp830DescPD   ³Autor³Reginaldo            ³ Data ³28/11/2005³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Preenche o Campo Descricao da Verba                         ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function GP830DescPd(cPd)

Local cDescPd
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Carrega a Descricao da Verba                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cDescPd := fDesc( "SRV" , cPd , "RV_DESC" )
GdFieldPut( "RF_DESCPD" , cDescPd )

Return ( .t. )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³03/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA830                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina := { 	{ STR0004 , "PesqBrw"  , 0 , 1},;  //"Pesquisar"
						{ STR0005 , "gp830Mnt" , 0 , 2},;  //"Visualizar"
						{ STR0011 , "gp830Mnt" , 0 , 6}	,;  //"Incluir"
						{ STR0006 , "gp830Mnt" , 0 , 4},;  //"Atualizar"
						{ STR0010 , "GPER600"  , 0 , 6}}   //"Imprimir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³valDtFimPerºAutor  ³Emerson Campos      º Data ³ 28/02/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a data final do periodo deve ser maior que a data º±±
±±º          ³ de inicio do periodo.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA830                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function valDtFimPer()
Local lRet	:= .T.
Local cHelp := OemToAnsi( STR0016 ) // "A Data Final do Periodo deve ser maior que a Data de Inicio do Periodo"

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If M->RH5_ANO < strzero(year(date()),4)
	If lGp830Auto
		AutoGrLog( cHelp )
	Else
		MsgInfo( cHelp , STR0015 )
	EndIf
	lRet := .F.
EndIf
Return lRet
