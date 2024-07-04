#INCLUDE "protheus.ch"           		
#INCLUDE "apta130.ch" 

Static cIdiom := FWRetIdiom()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma     ³APTA130   º Autor ³ TANIA BRONZERI                º Data ³ 22/04/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao    ³ Cadastro de Siglas de Registros de Classe                             º±±
±±º             ³                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Cadastro de Siglas de Registros de Classe                             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv.³04/08/2014³TQEQ39³Incluido o fonte da 11 para a 12 e efetuda a limpeza.³±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Í±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function APTA130 ( cAlias , nReg , nOpc , lExecAuto , lMaximized )

Local aArea			:= GetArea()
Local aIndexRE8		:= {}						
Local aBrowse		:= {}			
Local lExistOpc		:= ( ValType( nOpc ) == "N" )
Local uRet
Local lValida

Private cCadastro	:= OemToAnsi(STR0001)				//"Cadastro de Siglas Registros de Classe"    

Re8Testem()
 
Begin Sequence

	cAlias	:= "RE8"
	dbSelectArea("RE8")

	
    Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
		
	IF ( lExistOpc )
	
		DEFAULT nReg	:= ( cAlias )->( Recno() )
		IF !Empty( nReg )
			( cAlias )->( MsGoto( nReg ) )
		EndIF
	
		DEFAULT lExecAuto := .F.
		IF ( lExecAuto )
	
			nPos := aScan( aRotina , { |x| x[4] == nOpc } )
			IF ( nPos == 0 )
				Break
			EndIF
			bBlock := &( "{ |a,b,c,d| " + aRotina[ nPos , 2 ] + "(a,b,c,d) }" )
			uRet := Eval( bBlock , cAlias , nReg , nPos )
			
		Else
			
			DEFAULT lMaximized := .F.
			uRet := Apta130Mnt( cAlias , nReg , nOpc , lMaximized )
			
		EndIF
	
	Else
		IF cIdiom == "es"    
			aAdd(aBrowse,{"Identific.","RE8_IDENT" })
			aAdd(aBrowse,{"Descripcion","RE8_IDSCSP"})
			aAdd(aBrowse,{"Sigla","RE8_SIGLA" })
			aAdd(aBrowse,{"Des.Sigla","RE8_DSCSPA"})
			mBrowse( 6,1,22,75,"RE8",aBrowse) 
		ELSEIF cIdiom == "en" 
			aAdd(aBrowse,{"Identific.","RE8_IDENT" })
			aAdd(aBrowse,{"Ident.Descr.","RE8_IDSCEN"})
			aAdd(aBrowse,{"Sigla","RE8_SIGLA" })
			aAdd(aBrowse,{"Description","RE8_DSCENG" })
			mBrowse( 6,1,22,75,"RE8",aBrowse) 
		ELSE                                          
			aAdd(aBrowse,{"Identific.","RE8_IDENT" })
			aAdd(aBrowse,{"Descricao" ,"RE8_IDESCR"})
			aAdd(aBrowse,{"Sigla","RE8_SIGLA" })
			aAdd(aBrowse,{"Des.Sigla","RE8_DESCR" })
			mBrowse( 6,1,22,75,"RE8",aBrowse)          
		ENDIF
	EndIF

End Sequence

RestArea( aArea )

Return( uRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³APTA130Vis³Autor³Tania Bronzeri           ³ Data ³22/04/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Cadastro de Siglas de Registros de Classe ( Visualizar ) 	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>          							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>          							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico  	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function APTA130Vis ( cAlias , nReg )
Return( Apta130Mnt( cAlias , nReg , 2 , .F. ) )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³APTA130Inc³Autor³Tania Bronzeri           ³ Data ³22/04/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Cadastro de Siglas de Registros de Classe ( Incluir )	   	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>          							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>          							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico  	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function APTA130Inc( cAlias , nReg )
Return( Apta130Mnt( cAlias , nReg , 3 , .F. ) )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Apta130Mnt³Autor³Tania Bronzeri           ³ Data ³22/04/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Cadastro de Siglas de Registros de Classe ( Manutencao )	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>          							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>          							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico  	                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function Apta130Mnt( cAlias , nReg , nOpc , lMaximized )

Local uRet
Local aCposIdioma	:= {}

cAlias				:= "RE8"
DEFAULT nReg		:= ( cAlias )->( Recno() )
DEFAULT nOpc 		:= 2
DEFAULT lMaximized	:= .T.
     
Begin Sequence
dbSelectArea("RE8")
	IF cIdiom == "es"
		aCposIdioma	:=	{ "RE8_IDENT" , "RE8_IDSCSP" , "RE8_SIGLA" , "RE8_DSCSPA" }
	ELSEIF cIdiom == "en"              
		aCposIdioma	:=	{ "RE8_IDENT" , "RE8_IDSCEN" , "RE8_SIGLA" , "RE8_DSCENG" }
	ELSE                                          
		aCposIdioma	:=	{ "RE8_IDENT" , "RE8_IDESCR" , "RE8_SIGLA" , "RE8_DESCR" }
	ENDIF
	IF ( nOpc == 1 )
		uRet := PesqBrw( cAlias , nReg )
	ElseIF ( nOpc == 2 )
		uRet := AxVisual( cAlias , nReg , nOpc , aCposIdioma , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 3 )
		uRet := AxInclui( cAlias , nReg , nOpc , aCposIdioma , NIL , NIL , NIL , If( IsInCallStack("APTA120"),.T., NIL ), NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 4 )
		uRet := AxAltera( cAlias , nReg , nOpc , aCposIdioma , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 5 )   
	    IF !( Val ( RE8->RE8_IDENT ) == 0 )
			IF ChkDelRegs("RE8")
				uRet := AxDeleta( cAlias , nReg , nOpc , NIL , aCposIdioma , NIL , NIL , NIL , lMaximized )
			EndIF
		Else
			MsgInfo( OemToAnsi( STR0007 + CRLF + STR0008 ) , cCadastro ) //"A chave a ser excluida ‚ de uso exclusivo da Microsiga." // "A mesma n„o pode ser excluida."
	    EndIF
 	EndIF

End Sequence
	
Return( uRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³19/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA130                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Array contendo as Rotinas a executar do programa      ³
³ ----------- Elementos contidos por dimensao ------------     ³
³ 1. Nome a aparecer no cabecalho                              ³
³ 2. Nome da Rotina associada                                  ³
³ 3. Usado pela rotina                                         ³
³ 4. Tipo de Transa‡„o a ser efetuada                          ³
³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
³    2 - Simplesmente Mostra os Campos                         ³
³    3 - Inclui registros no Bancos de Dados                   ³
³    4 - Altera o registro corrente                            ³
³    5 - Remove o registro corrente do Banco de Dados          ³
³ 5.                                                           ³
³ 6. Visualiza opcao no menu funcional(default .T.)            ³
³ 7. Habilita pesquisa antes de executar a opcao selecionada   ³
³    (utilizado como .T. apenas nos casos em que a pesquisa    ³
³    nao eh realizada via PesqBrw ou AxPesqui).                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Local aRotina := {			{ STR0002 ,	"AxPesqui"		,	0	,	1	,,	.F.	} ,;	//"Pesquisar"
	             			{ STR0003 ,	"Apta130Mnt"	,	0	,	2	,,	   	} ,;	//"Visualizar"
	             			{ STR0004 ,	"Apta130Mnt"	,	0	,	3	,, 	   	} ,;	//"Incluir"
	             			{ STR0005 ,	"Apta130Mnt"	,	0	,	4	,,	   	} ,;	//"Alterar"
	             			{ STR0006 ,	"Apta130Mnt"	,	0	,	5	,,	   	} ;		//"Excluir"
	               		}
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FA130IDENT    º Autor ³ IP RH Inovacao    º Data ³ 21/01/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Validacado campo RE8_IDENT para não aceitar 000               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SX3 Cadastro de Reg. Classe                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA130IDENT()
Local lRet := .F.
Local cVarID := &(ReadVar())

If cVarID > "000" .And. cVarID <= "999"   
	lRet := .T.
Else
	Aviso(STR0009,STR0010,{"Ok"},2,STR0001) // "Atenção" ### "Cadastro de Siglas de Registros de Classe" ### "Conteudo invalido, digite entre 001 e 999"
Endif

Return lRet
