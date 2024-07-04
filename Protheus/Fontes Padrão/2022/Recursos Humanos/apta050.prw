#INCLUDE "protheus.ch"
#INCLUDE "apta050.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁAPTA050   ╨ Autor Ё TANIA BRONZERI     ╨ Data Ё  24/03/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Cadastro de Comarca / Forum                                ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Cadastro de Comarca / Forum                                ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             ╨╠╠
╠╠лддддддддддддбддддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд╧╠╠
╠╠╨Programador Ё Data     Ё BOPS Ё  Motivo da Alteracao                   ╨╠╠ 
╠╠лддддддддддддбддддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд╧╠╠
╠╠ЁCecilia Car.Ё04/08/2014ЁTQEQ39ЁIncluido o fonte da 11 para a 12 e efetuЁ╠╠  
╠╠Ё            Ё          Ё      Ёada a limpeza.                          Ё╠╠ 
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function APTA050( cAlias , nReg , nOpc , lExecAuto , lMaximized )

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de Variaveis                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aArea			:= GetArea()
LOCAL cFiltraREC	:= ""					
LOCAL aIndexREC		:= {}					
Local lExistOpc		:= ( ValType( nOpc ) == "N" )
Local uRet

Private cCadastro	:= OemToAnsi(STR0001)	//"Cadastro de Comarcas / Foruns" 
Private bFiltraBrw 	:= {|| Nil}				


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta um aRotina proprio                                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina


cAlias				:= "REC"
dbSelectArea("REC")      
Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

IF ( lExistOpc )      
/*	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁGarante o Posicinamento do Recno                              Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
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
		uRet := Apta050Mnt( cAlias , nReg , nOpc , lMaximized )
	EndIF
Else             
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFiltraRh := CHKRH("APTA050","REC","1")
	bFiltraBrw 	:= {|| FilBrowse("REC",@aIndexREC,@cFiltraRH) }
	Eval(bFiltraBrw)

	dbSelectArea("REC")
	dbSetOrder(1)
	mBrowse( 6,1,22,75,"REC")

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Deleta o filtro utilizando a funcao FilBrowse                     	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	EndFilBrw("REC",aIndexREC)
EndIf

RestArea( aArea )

Return( uRet )


/*
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁApta050MntЁAutorЁTania Bronzeri           Ё Data Ё14/04/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Comarcas e FСruns ( Manutencao )	        	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Apta050Mnt( cAlias , nReg , nOpc , lMaximized )

Local uRet
cAlias				:= "REC"
DEFAULT nReg		:= ( cAlias )->( Recno() )
DEFAULT nOpc 		:= 2
DEFAULT lMaximized	:= .T.
     
Begin Sequence

	IF ( nOpc == 1 )
		uRet := PesqBrw( cAlias , nReg )
	ElseIF ( nOpc == 2 )
		uRet := AxVisual( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 3 )
		uRet := AxInclui( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 4 )
		uRet := AxAltera( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 5 )   
		If (ChkDelRegs("REC"))
			RecLock("REC",.F.)
			uRet := AxDeleta( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , lMaximized )
			MSUnlock()
		Endif
	EndIF

End Sequence
	
Return( uRet )


                 
/*/ Material para cСpia

/*
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁAPTA120VisЁAutorЁTania Bronzeri           Ё Data Ё07/04/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe ( Visualizar )	        	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/
Function APTA120Vis ( cAlias , nReg )
Return( Apta120Mnt( cAlias , nReg , 2 , .F. ) )

/*
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁAPTA120IncЁAutorЁTania Bronzeri           Ё Data Ё07/04/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe ( Incluir )		        	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/
Function APTA120Inc( cAlias , nReg )
Return( Apta120Mnt( cAlias , nReg , 3 , .F. ) )

/*

/*
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁReuSxbFilterЁAutorЁMarinaldo de Jesus       ЁDataЁ08/04/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддддаддддадддддддддд╢
ЁDescri┤┘o ЁFiltro de Consulta Padrao para o REU						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁConsulta Padrao (SXB)				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/
Function ReuSxbFilter()
         
Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
Local cRet		:= ""

//RE2 = Advogados
IF ( "RE2_TP_REG" $ cReadVar )
	IF ( IsInGetDados( { "RE2_CODPES" , "RE2_TP_REG" } ) )
		cRet := "@#REU->REU_CODPES=='"+GdFieldGet("RE2_CODPES")+"'@#"
	ElseIF ( IsMemVar( "RE2_CODPES" ) .and. IsMemVar( "RE2_TP_REG" )  )
		cRet := "@#REU->REU_CODPES=='"+GetMemVar("RE2_CODPES")+"'@#"
	EndIF
Else
//...codigo semelhante ao acima...
EndIF

Return( cRet )


/*/

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё19/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁAPTA050                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function MenuDef()

Local aRotina :=	{ 	{ STR0002 ,"AxPesqui"	,	0	,1,,.F. } ,;
             			{ STR0003 ,"AxVisual"	,	0	,2 } ,;
            			{ STR0004 ,"AxInclui"	,	0	,3 } ,;
             			{ STR0005 ,"AxAltera"	,	0	,4 } ,;
             			{ STR0006 ,"Apta050Mnt"	,	0	,5 } }
Return aRotina