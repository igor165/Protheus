#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAA130.CH"

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA130   ЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala/Grau de Importancia                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё
цддддддддддддбддддддддддбдддддддддддбддддддддддддддддддддддддддддддддддд╢
ЁProgramador ЁData      ЁBOPS       ЁMotivo da Alteracao                Ё
цддддддддддддеддддддддддедддддддддддеддддддддддддддддддддддддддддддддддд╢
ЁCecilia Car.Ё07/07/2014ЁTPZVTW     ЁIncluido o fonte da 11 para a 12   Ё
Ё            Ё          Ё           Ёe efetuada a limpeza.              Ё
ЁAllyson M   Ё16/10/2015ЁTTJLKJ     ЁAjuste em Cs130F3Rbl() p/ filtro daЁ
Ё            Ё          Ё           Ёconsulta padrao.             	    Ё
юддддддддддддаддддддддддадддддддддддаддддддддддддддддддддддддддддддддддды/*/
Function CSAA130( cAlias , nReg , nOpc , lExecAuto , nTipo )

Local aArea 		:= GetArea()
Local aAreaRbk		:= RBK->( GetArea() )
Local aAreaRbl		:= RBL->( GetArea() )
Local aRbkIndex		:= {}
Local cRbkFilter	:= ""
Local lExistOpc		:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos

DEFAULT nTipo	:= 0	//Sem Filtro

Begin Sequence

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁVerifica se o Modo de Acesso do RBK e RBL sao Iguais          Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( xRetModo( "RBK" , "RBL" , .T. ) )
		Break
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRedefine o Alias                                              Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cAlias	:= "RBK"

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define Array contendo as Rotinas a executar do programa      Ё
	Ё ----------- Elementos contidos por dimensao ------------     Ё
	Ё 1. Nome a aparecer no cabecalho                              Ё
	Ё 2. Nome da Rotina associada                                  Ё
	Ё 3. Usado pela rotina                                         Ё
	Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
	Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
	Ё    2 - Simplesmente Mostra os Campos                         Ё
	Ё    3 - Inclui registros no Bancos de Dados                   Ё
	Ё    4 - Altera o registro corrente                            Ё
	Ё    5 - Remove o registro corrente do Banco de Dados          Ё
	Ё    6 - Copiar                                                Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	Private cCadastro
	Private cRbkTipoInit

	IF ( nTipo == 1 )
		cCadastro		:= OemToAnsi( STR0006 )	//"Cadastro de Escala"
		cRbkTipoInit	:= "1"
	ElseIF ( nTipo == 2 )
		cCadastro	:= OemToAnsi( STR0007 )	//"Cadastro de Grau de Importancia*
		cRbkTipoInit	:= "2"
	Else
		cCadastro		:= OemToAnsi( STR0020 )	//"Cadastro de Escala / Grau de Importancia"
		cRbkTipoInit    := Space( 1 )
	EndIF

	IF ( lExistOpc )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁGarante o Posicinamento do Recno                              Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
			Eval( bBlock , cAlias , nReg , nPos )
		
		Else

			CSAA130Mnt( cAlias , nReg , nOpc , .T. )
		
		EndIF	

	Else
    	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nTipo == 1 )
			cRbkFilter	:= "RBK->RBK_TIPO == '1'"
		ElseIF ( nTipo == 2 )
			cRbkFilter	:= "RBK->RBK_TIPO == '2'"
		EndIF
	
		Private bFiltraBrw	:= { || FilBrowse( "RBK" , @aRbkIndex , @cRbkFilter ) }
		Eval( bFiltraBrw )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Chama a Funcao de Montagem do Browse                                   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		mBrowse( 6 , 1 , 22 , 75 , cAlias )

    	/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Deleta o filtro utilizando a funcao FilBrowse                     	 Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		EndFilBrw( "RBK" , @aRbkIndex )

	EndIF

End Sequence
		
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura os Dados de Entrada 											 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestArea( aAreaRbl )
RestArea( aAreaRbk )
RestArea( aArea	   )

Return( NIL )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA130VisЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala/Grau de Importancia ( Visualizar )		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA130Vis( cAlias , nReg )
Return( CSAA130( cAlias , nReg , 2 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA130IncЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala/Grau de Importancia ( Incluir )			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA130Inc( cAlias , nReg )
Return( CSAA130( cAlias , nReg , 3 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA130AltЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala/Grau de Importancia ( Alterar )			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA130Alt( cAlias , nReg )
Return( CSAA130( cAlias , nReg , 4 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA130DelЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala/Grau de Importancia ( Excluir )			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA130Del( cAlias , nReg )
Return( CSAA130( cAlias , nReg , 5 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA131   ЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala	(Manutencao)							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA131( cAlias , nReg , nOpc )

Return( CSAA130( cAlias , nReg , nOpc , NIL ,  1 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA131VisЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala ( Visualizar )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA131Vis( cAlias , nReg )
Return( CSAA131( cAlias , nReg , 2 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA131IncЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala ( Incluir )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA131Inc( cAlias , nReg )
Return( CSAA131( cAlias , nReg , 3 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA131AltЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala ( Alterar )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA131Alt( cAlias , nReg )
Return( CSAA131( cAlias , nReg , 4 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA131DelЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala ( Excluir )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA131Del( cAlias , nReg )
Return( CSAA131( cAlias , nReg , 5 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA132   ЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro Grau de Importancia ( Manutencao )				    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё
цддддддддддддбддддддддддбдддддддддддбддддддддддддддддддддддддддддддддддд╢
ЁProgramador ЁData      ЁBOPS 	    ЁMotivo da Alteracao                Ё
цддддддддддддеддддддддддедддддддддддеддддддддддддддддддддддддддддддддддд╢
Ё            Ё          Ё           Ё                                   Ё
юддддддддддддаддддддддддадддддддддддаддддддддддддддддддддддддддддддддддды/*/
Function CSAA132( cAlias , nReg , nOpc )
	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Return( CSAA130( cAlias , nReg , nOpc , NIL ,  2 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA132VisЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro Grau de Importancia (Visualizar)				    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA132Vis( cAlias , nReg )
Return( CSAA132( cAlias , nReg , 2 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA132IncЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro Grau de Importancia (Incluir)					    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA132Inc( cAlias , nReg )
Return( CSAA132( cAlias , nReg , 3 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA132AltЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro Grau de Importancia (Alterar)					    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA132Alt( cAlias , nReg )
Return( CSAA132( cAlias , nReg , 4 ) )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCSAA132DelЁAutorЁMarinaldo de Jesus       Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro Grau de Importancia ( Excluir )				    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA132Del( cAlias , nReg )
Return( CSAA132( cAlias , nReg , 5 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁCSAA130MntЁ Autor ЁMarinaldo de Jesus     Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Escala/Grau de Importancia (Manutencao)			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁCSAA130Mnt( cAlias , nReg , nOpc , lDlgPadSiga )			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcAlias 		= Alias do arquivo                          	Ё
Ё          ЁnReg  		= Numero do registro                        	Ё
Ё          ЁnOpc   		= Numero da opcao selecionada               	Ё
Ё          ЁlDlgPadSiga	= Dialog no Padrao Siga                     	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCSAA130()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function CSAA130Mnt( cAlias , nReg , nOpc , lDlgPadSiga )

Local aArea			:= GetArea(Alias())
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRbkHeader	:= {}
Local aRbkCols		:= {}
Local aSvRbkCols	:= {}
Local aRbkFields	:= {}
Local aRbkAltera	:= {}
Local aRbkNaoAlt	:= {}
Local aRbkVirtEn	:= {}
Local aRbkNotFields	:= {}
Local aRbkRecnos	:= {}
Local aRbkKeys		:= {}
Local aRbkVisuEn	:= {}
Local aRblGdAltera  := {}
Local aRblGdNaoAlt	:= {}
Local aRblRecnos	:= {}
Local aRblKeys		:= {}
Local aRblNotFields	:= {}
Local aRblVirtGd	:= {}
Local aRblVisuGd	:= {}
Local aRblHeader	:= {}
Local aRblCols		:= {}
Local aSvRblCols	:= {}
Local aRblQuery		:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local aButtons		:= {}
Local aFreeLocks	:= {}
Local bRblGdDelOk	:= { |lDelOk| CursorWait() , lDelOk := RblGdDelOk( "RBL" , NIL , nOpc , cCodRBK ) , CursorArrow() , lDelOk }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bDialogInit	:= { || NIL }
Local bGetRbk		:= { || NIL } 
Local bGetRbl		:= { || NIL }
Local bRblSort		:= { || NIL }
Local cRBKKeySeek	:= ""
Local cFilRBK		:= ""
Local cCodRBK		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local lLocks		:= .F.
Local lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nRbkUsado		:= 0
Local nRblUsado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nOpcNewGd		:= IF( ( ( nOpc == 2 ) .or. ( nOpc == 5 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)
Local nRblPosItem	:= 0
Local nRblItemOrd	:= RetOrdem( "RBL" , "RBL_FILIAL+RBL_ESCALA+RBL_ITEM" )
Local nRblMaxLocks	:= 50
Local nRblGhostCol	:= 0
Local oDlg			:= NIL
Local oEnRbk		:= NIL	
Local oGdRbl		:= NIL

Private nGetSX8Len	:= GetSX8Len()
Private nAlter		:= nOpc
Private aGets
Private aTela

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Coloca o ponteiro do Cursor do Mouse em Estado de Espera     Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

Begin Sequence

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁCheca a Opcao Selecionada									   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aRotSetOpc( cAlias , @nReg , nOpc )

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta os Dados para a Enchoice							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aRbkNotFields	:= { "RBK_FILIAL" }
	bGetRbk			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aRbkKeys := NIL ),;
										aRbkCols := RBK->(;
															GdBuildCols(	@aRbkHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																			@nRbkUsado		,;	//02 -> Numero de Campos em Uso
																			@aRbkVirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																			@aRbkVisuEn		,;	//04 -> [@]Array com os Campos Visuais
																			"RBK"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																			aRbkNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																			@aRbkRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																			"RBK"		   	,;	//08 -> Alias do Arquivo Pai
																			NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																			NIL				,;	//10 -> Bloco para condicao de Loop While
																			NIL				,;	//11 -> Bloco para Skip no Loop While
																			NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																			NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
																			NIL				,;	//15 -> Opcional, Carregar Todos os Campos
																			NIL				,;	//16 -> Opcional, Nao Carregar os Campos Virtuais
																			NIL				,;	//17 -> Opcional, Utilizacao de Query para Selecao de Dados
																			NIL				,;	//18 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																			NIL				,;	//19 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																			NIL				,;	//20 -> Carregar Coluna Fantasma
																			NIL				,;	//21 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																			NIL				,;	//22 -> Verifica se Deve Checar se o campo eh usado
																			NIL				,;	//23 -> Verifica se Deve Checar o nivel do usuario
																			NIL				,;	//24 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																			@aRbkKeys		,;	//25 -> [@]Array que contera as chaves conforme recnos
																			@lLock			,;	//26 -> [@]Se devera efetuar o Lock dos Registros
																			@lExclu			 ;	//27 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																	    );
														  ),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  					} 
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁLock do Registro do RBK									   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( lLocks := WhileNoLock( "RBK" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRbk ) )
		Break
	EndIF
	CursorWait()
	aSvRbkCols		:= aClone( aRbkCols )
	cFilRBK			:= RBK->RBK_FILIAL
	cCodRBK			:= RBK->RBK_ESCALA
	cRBKKeySeek		:= ( cFilRBK + cCodRBK )

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
	Ё quivo														   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	For nLoop := 1 To nRbkUsado
		aAdd( aRbkFields , aRbkHeader[ nLoop , 02 ] )
		IF ( aRbkHeader[ nLoop , 02 ] == "RBK_TIPO" )
			IF ( Empty( aRbkCols[ 01 , nLoop ] ) )
				aRbkCols[ 01 , nLoop ] := cRbkTipoInit
			EndIF
		EndIF
		SetMemVar( aRbkHeader[ nLoop , 02 ] , aRbkCols[ 01 , nLoop ] , .T. )
	Next nLoop
	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁDefine os Campos Editaveis na Enchoice Apenas na Inclusao( 3 )Ё
	Ёou Alteracao(4)											   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define os Campos Editaveis								   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		nLoops := Len( aRbkVisuEn )
		For nLoop := 1 To nLoops
			aAdd( aRbkNaoAlt , aRbkVisuEn[ nLoop ] )
		Next nLoop
		IF ( nOpc == 4 )
			aAdd( aRbkNaoAlt , "RBK_ESCALA" )
			aAdd( aRbkNaoAlt , "RBK_TIPO"   )
		ElseIF !Empty( cRbkTipoInit )
			aAdd( aRbkNaoAlt , "RBK_TIPO"   )
		EndIF
		nLoops := Len( aRbkFields )
		For nLoop := 1 To nLoops
			IF ( aScan( aRbkNaoAlt , { |cNaoA| cNaoA == aRbkFields[ nLoop ] } ) == 0 )
				aAdd( aRbkAltera , aRbkFields[ nLoop ] )
			EndIF
		Next nLoop
	
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta os Dados para a GetDados							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aAdd( aRblNotFields , "RBL_FILIAL"  )
	aAdd( aRblNotFields , "RBL_ESCALA"	)
	aRblQuery		:= Array( 05 )
	aRblQuery[01]	:= "RBL_FILIAL='"+cFilRBK+"'"
	aRblQuery[02]	:= " AND "
	aRblQuery[03]	:= "RBL_ESCALA='"+cCodRBK+"'"
	aRblQuery[04]	:= " AND "
	aRblQuery[05]	:= "D_E_L_E_T_=' ' "
   /*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Quando For Inclusao Posiciona o RBL No Final do Arquivo	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( nOpc == 3  ) //Inclusao
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Garante que na Inclusao o Ponteiro do RBL estara em Eof()    Ё 
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		PutFileInEof( "RBL" )
	EndIF
	RBL->( dbSetOrder( nRblItemOrd ) )
	bGetRbl	:= { |lLock,lExclu| IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aRblKeys := NIL ),;
						 			aRblCols := RBL->(;
														GdBuildCols(	@aRblHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nRblUsado		,;	//02 -> Numero de Campos em Uso
																		@aRblVirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aRblVisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"RBL"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aRblNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aRblRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"RBK"		   	,;	//08 -> Alias do Arquivo Pai
																		cRBKKeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																		.F.				,;	//14 -> Opcional, Carregar Todos os Campos
																		.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																		aRblQuery		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		Altera			,;	//19 -> Carregar Coluna Fantasma
																		.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		.F.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
																		.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
																		.F.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aRblKeys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		nRblMaxLocks   	,;	//27 -> Numero maximo de Locks a ser efetuado
																		Altera			 ;	//28 -> Utiliza Numeracao na GhostCol
																    );
														  ),;
									IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  		    }
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁLock do Registro do RBL									   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( lLocks := WhileNoLock( "RBL" , NIL , NIL , 1 , 1 , .T. , NIL , 5 , bGetRbl ) )
		Break
	EndIF
	CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁMonta Bloco para Sort antes da Gravacao					   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( ( nRblGhostCol := GdFieldPos( "GHOSTCOL" , aRblHeader ) ) > 0 )
		bRblSort := { |x,y| ( x[ nRblGhostCol ] < y[ nRblGhostCol ] ) }
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Salva o Conteudo do RblaCols para comparacao na saida		   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

	aSvRblCols	:= aClone( aRblCols )
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega os Campos Editaveis para a GetDados				   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	For nLoop := 1	To nRblUsado
		SetMemVar( aRblHeader[ nLoop , 02 ] , GetValType( aRblHeader[ nLoop , 08 ] , aRblHeader[ nLoop , 04 ] ) , .T. )
		IF (;
				( aScan( aRblVirtGd		, aRblHeader[ nLoop , 02 ] ) == 0 ) .and.	;
		   		( aScan( aRblVisuGd		, aRblHeader[ nLoop , 02 ] ) == 0 ) .and.	;
		   		( aScan( aRblNotFields	, aRblHeader[ nLoop , 02 ] ) == 0 ) .and.	;
		   		( aScan( aRblGdNaoAlt	, aRblHeader[ nLoop , 02 ] ) == 0 )			;
		  	)
			aAdd( aRblGdAltera , aRblHeader[ nLoop , 02 ] )
		EndIF
	Next nLoop
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRedefine aRblCols na Inclusao ou se vazio para que a numeracaoЁ
	Ёautomatica do campo RBL_ITEM seja feita corretamente na  GetDaЁ
	Ёdos. 														   Ё
	ЁUma outra opcao seria utilizar a funcao   GdNumItem("RBL_ITEM)Ё
	Ёno Inicializador padrao do campo RBL_ITEM e nao efetuar o ajusЁ
	Ёte abaixo ( Reinicializar aRblaCols )						   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( ( Inclui ) .or. Empty( aRblRecnos ) )
		aRblCols := {}
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁVerifica se Pode Efetuar a Delecao dos Registros			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( nOpc == 5 )
		cMsgYesNo	:= OemToAnsi(;
									STR0008 + ;	//"O sistema ir═ efetuar a verifica┤└o para ver se o registro selecionado"
									CRLF	+ ;	
									STR0009 + ;	//"para exclus└o est═ sendo utilizado. A verifica┤└o pode ser demorada." 
									CRLF	+ ;
									CRLF	+ ;
									STR0010	  ;	//"Confirma a exclus└o?"
								 )
		cTitLog		:= OemToAnsi( STR0011  )	//"Log de verifica┤└o de exclus└o"
		CursorArrow()
		IF MsgYesNo( OemToAnsi( cMsgYesNo ) , cCadastro + " - " + OemToAnsi( cTitLog ) )
			CursorWait()
			nRblPosItem := GdFieldPos( "RBL_ITEM" , aRblHeader )
			nLoops := Len( aRblRecnos )
			//Verificando os Itens
			For nLoop := 1 To nLoops
				IF !( ApdChkDel( "RBL" , NIL , nOpc , ( cCodRBK + aRblCols[ nLoop , nRblPosItem ] ) , .F. , @aLog , @aLogTitle ) )
					IF !( Empty( aLogGer ) )
						aAdd( aLogGer , aClone( aLog ) )
						aAdd( aLogGerTitle , aLogTitle[1] )
					EndIf
				EndIF
			Next nLoop
			//Verificando o Cabecalho
			IF !( lExcGeraLog := !Empty( aLogGer ) )
				IF !( ApdChkDel( cAlias , nReg , nOpc , cCodRBK , @lExcGeraLog , @aLog , @aLogTitle , { "RBL" } ) )
					aAdd( aLogGer , aClone( aLog ) )
					aAdd( aLogGerTitle , aLogTitle[1] )
				EndIF
			EndIF
			IF ( lExcGeraLog := !Empty( aLogGer ) )
				cTitLog := STR0012	//"Log de Inconsistencia na Exclusao de "
				IF ( FunName() == "CSAA130" )
					cTitLog += STR0013	//"Escala"
				Else
					cTitLog += STR0014	//"Grau de Importancia"
				EndIF
				CursorArrow()
				IF ( lExcGeraLog := MsgNoYes( STR0023 , cCadastro + " " + cTitLog ) ) //"Deseja gerar Log?" 
					CursorWait()
						fMakeLog( aLogGer , aLogGerTitle , NIL , NIL , FunName() , cTitLog )
					CursorArrow()
				Else
					//"A chave a ser excluida est═ sendo utilizada."
					//"At┌ que as refer┬ncias a ela sejam eliminadas a mesma n└o pode ser excluida."
					MsgInfo( OemToAnsi( STR0024 + CRLF + STR0025 ) , cCadastro + " " + cTitLog )
				EndIF
				Break
			EndIF	
		Else
			Break
		EndIF
		CursorWait()
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta as Dimensoes dos Objetos         					   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	DEFAULT lDlgPadSiga	:= .F.
	aAdvSize		:= MsAdvSize( NIL , lDlgPadSiga )
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 050 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define o Botao de Pesquisa na GetDados					   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	bGdPesq := { ||	Csaa130GdSeek( oGdRbl )		,;
					SetKey( VK_F4 , bGdPesq )	 ;
			   }
	aAdd(;
			aButtons	,;
							{;
								"BMPCONS"							,;
	   							bGdPesq								,;
	       	   					OemToAnsi( STR0001 + "...<F4>"  )	,;
	       	   					OemtoAnsi( STR0001 )	 			 ;	//"Pesquisar"
	           				};
	     )

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define o Bloco para a Tecla <CTRL-O> 						   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	bSet15		:= { || IF(; 
								( ( nOpc == 3 ) .or. ( nOpc == 4 ) );					//Inclusao ou Alteracao
								.and.;
								CSAA130TEncOk( nOpc , oEnRbk );							//Valida Todos os Campos da Enchoice
								.and.;
								oGdRbl:TudoOk(),;										//Valida as Informacoes da GetDados
								(;
									nOpcAlt 	:= 1 ,;
									aRblCols	:= oGdRbl:aCols,;						//Redireciona o Ponteiro do aRblCols
									RestKeys( aSvKeys , .T. ),;
									oDlg:End();
							 	),;
							 	IF(; 
							 		( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) ,;				//Inclusao ou Visualizacao
							 			(;
							 				nOpcAlt := 0 ,;
							 				.F.;
							 			 ),;
									(;
										nOpcAlt := IF( nOpc == 2 , 0 , 1 ) ,;		//Visualizacao ou Exclusao
										RestKeys( aSvKeys , .T. ),;
										oDlg:End();
							 		);
							 	  );
						   );
					 }
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define o Bloco para a Teclas <CTRL-X>     	   			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define o Bloco para o Init do Dialog						   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	bDialogInit := { ||;
							EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
							SetKey( VK_F4 , bGdPesq  ),;
					}
	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta o Dialogo Principal para a Manutencao das Formulas	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto Enchoice para o RBK                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oEnRbk	:= MsmGet():New(	cAlias		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRbkFields	,;
									aObjSize[1] ,;
									aRbkAltera	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.F.			,;
									NIL			,;
									.F.			 ;
								)
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto GetDados para o RBL						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oGdRbl	:= MsNewGetDados():New(	aObjSize[2,1]								,;
										aObjSize[2,2]								,;
										aObjSize[2,3]								,;
										aObjSize[2,4]								,;
										nOpcNewGd									,;
										"RblGdLinOk"								,;
										"RblGdTudOk"								,;
										"+RBL_ITEM"									,;
										aRblGdAltera								,;
										0											,;
										Val(Replicate("9",TamSx3("RBL_ITEM")[1]))	,;
										NIL											,;
										NIL											,;
										bRblGdDelOk									,;
										oDlg										,;
										aRblHeader									,;
										aRblCols		 							 ;
									  )
	ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

	/*/                   			
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   ExЁ
	Ёclui as Informacoes do RBK e RBL							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF( nOpcAlt == 1 )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Apenas se nao For Visualizacao              				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 		IF ( nOpc != 2 )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Gravando/Incluido ou Excluindo Informacoes do SRY/RBL        Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			MsAguarde(;
						{ ||;
								aSort( aRblCols , NIL , NIL , bRblSort ),;	//Sorteia as Informacoes do RBL para Comparacao Antes da Gravacao
								CSAA130Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 					nReg		,;	//Numero do Registro do Arquivo Pai ( RBK )
							 					aRbkHeader	,;	//Campos do Arquivo Pai ( RBK )
							 					aRbkCols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RBK )
							 					aSvRbkCols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RBK )
							 					aRbkVirtEn	,;	//Campos Virtuais do Arquivo Pai ( RBK )
							 					aRblHeader	,;	//Campos do Arquivo Filho ( RBL )
							 					aRblCols	,;	//Itens Atual do Arquivo Filho ( RBL )
							 					aSvRblCols	,;	//Itens Anterior do Arquivo Filho ( RD2 )
							 					aRblVirtGd	,;	//Campos Virtuais do Arquivo Filho ( RBL )
							 					aRblRecnos	 ;	//Recnos do Arquivo Filho ( RBL )
							  				);
						};
					)
		EndIF
	Else
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё RollBack da Numeracao Automatica            				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		While ( GetSX8Len() > nGetSX8Len )
			RollBackSX8()
		End While
	EndIF

End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁLibera os Locks             								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aAdd( aFreeLocks , { "RBK" , aRbkRecnos , aRbkKeys } )
aAdd( aFreeLocks , { "RBL" , aRblRecnos , aRblKeys } )
ApdFreeLocks( aFreeLocks )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura os Dados de Entrada								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestArea( aArea )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura as Teclas de Atalho                				   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestKeys( aSvKeys , .T. )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Ponteiro do Cursor do Mouse                  	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( nOpcAlt )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁCsaa130GdSeekЁAutorЁMarinaldo de Jesus    Ё Data Ё08/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁEftuar Pesquisa na GetDados                               	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPesquisa na GetDados                                   		Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function Csaa130GdSeek( oGdRbl )

Local aSvKeys		:= GetKeys()
Local cProcName3	:= Upper( Alltrim( ProcName( 3 ) ) )
Local cProcName5	:= Upper( AllTrim( ProcName( 5 ) ) )

Begin Sequence

	IF !( "CSAA130MNT" $ ( cProcName3 + cProcName5 ) )
		Break
	EndIF

	GdSeek( oGdRbl , OemToAnsi( STR0001 ) )	//"Pesquisar"

End Sequence	

RestKeys( aSvKeys , .T. )

Return( NIL )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁCSAA130TEncOkЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTudoOk para a Enchoice                                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁCSAA130TEncOk( nOpc , oEnRbk )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCSAA130()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function CSAA130TEncOk( nOpc , oEnRbk )

Local lTudoOk := .T.
                
IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )
	lTudoOk := EnchoTudOk( oEnRbk )
EndIF

Return( lTudoOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblGdLinOk	ЁAutorЁMarinaldo de Jesus     Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRblGdLinOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCSAA130()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RblGdLinOk( oBrowse )

Local aCposKey	:= {}
Local lLinOk	:= .T.
Local nX
Local nLoop
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Evitar que os Inicializadores padroes sejam carregados indeviЁ
	Ё damente													   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	PutFileInEof( "RBL" )
	
	Begin Sequence
    	If(!RblDescriVld( aCols[ n , 2 ] ))
    		lLinOk := .F. 
    		MsgAlert(OemToAnsi(STR0026))
    		Break
    	Else	
			For nX := 1 To Len( aCols )
				If nX <> 1  
					For nLoop:=1 To Len(aCols) 
						If (nLoop <> n) .And. (aCols[n, 2] == aCols[nLoop , 2] .And. aCols[n, 3] == aCols[nLoop , 3])
							lLinOk := .F.
							MsgAlert(OemToAnsi(STR0027))
							Break
				 		Endif
					Next
		   		EndIf
			Next 
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Se a Linha da GetDados Nao Estiver Deletada				   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			IF !( GdDeleted() ) 
		    	
				/*/
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Verifica Itens Duplicados na GetDados						   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				aCposKey := GetArrUniqe( "RBL" )
				IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
					Break
				EndIF
			
				/*/
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Verifica Se o Campos Estao Devidamente Preenchidos		   Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				aCposKey := GdObrigat( aHeader )
				IF !( lLinOk := GdNoEmpty( aCposKey ) )
			    	Break
				EndIF
				
			EndIF
        EndIf
	End Sequence

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁSe Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( lLinOk )
		oBrowse:SetFocus()
	EndIF

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lLinOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblGdTudOk	ЁAutorЁMarinaldo de Jesus     Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRblGdTudOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCSAA130()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RblGdTudOk( oBrowse )

Local lTudoOk 	:= .T.

Local nLoop

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	Begin Sequence
	
	    /*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Percorre Todas as Linhas para verificar se Esta Tudo OK      Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To Len( aCols )
			n := nLoop
			IF !( lTudoOk := RblGdLinOk( oBrowse ) )
				oBrowse:Refresh()
				Break
			EndIF
		Next nLoop
	
	End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lTudoOk  )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblGdDelOk  ЁAutorЁMarinaldo de Jesus     Ё Data Ё06/01/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidar a Delecao na GetDados                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCSAA130()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function RblGdDelOk( cAlias , nRecno , nOpc , cCodigo )
         
Local cItem			:= GdFieldGet( "RBL_ITEM" )
Local lDelOk 		:= .T.
Local lStatusDel	:= .F.

Static lFirstDelOk
Static lLstDelOk

DEFAULT lFirstDelOk	:= .T.
DEFAULT lLstDelOk	:= .T.

Begin Sequence

	//Quando for Visualizacao ou Exclusao Abandona
	IF (;
			( nOpc == 2 ) .or. ;	//Visualizacao
			( nOpc == 5 );			//Exclusao
		)
		Break
	EndIF

	//Apenas se for a primeira vez
	IF !( lFirstDelOk )
		lFirstDelOk	:= .T.
		lDelOk 		:= lLstDelOk
		lLstDelOk	:= .T.
		Break
	EndIF

	lStatusDel	:= !( GdDeleted() ) //Inverte o Estado
	
	IF ( lStatusDel )	//Deletar
    	IF !( nOpc == 3  )	//Quando nao for Inclusao
   			IF !( lDelOk := ApdChkDel( cAlias , nRecno , nOpc , ( cCodigo + cItem ) , .F. , NIL , NIL , NIL , NIL , .T. ) )
				CursorArrow()
				//"A chave a ser excluida est═ sendo utilizada."
				//"At┌ que as refer┬ncias a ela sejam eliminadas a mesma n└o pode ser excluida."
				MsgInfo( OemToAnsi( STR0024 + CRLF + STR0025 ) , cCadastro )
   				lLstDelOk := lDelOk
  				//Ja Passou pela funcao
				lFirstDelOk := .F.
   				Break
   			EndIF
    	EndIF
	Else				//Restaurar
   		lLstDelOk := lDelOk
   		//Ja Passou pela funcao
		lFirstDelOk := .F.
   		Break
	EndIF

	//Ja Passou pela funcao
	lFirstDelOk := .F.

End Sequence
	
Return( lDelOk )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁCSAA130Grava ЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCSAA130()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function CSAA130Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RBK )
							 	aRbkHeader	,;	//Campos do Arquivo Pai ( RBK )
							 	aRbkCols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RBK )
							 	aSvRbkCols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RBK )
							 	aRbkVirtEn	,;	//Campos Virtuais do Arquivo Pai ( RBK )
							 	aRblHeader	,;	//Campos do Arquivo Filho ( RBL )
							 	aRblCols	,;	//Itens Atual do Arquivo Filho ( RBL )
							 	aSvRblCols	,;	//Itens Anterior do Arquivo Filho ( RD2 )
							 	aRblVirtGd	,;	//Campos Virtuais do Arquivo Filho ( RBL )
							 	aRblRecnos	 ;	//Recnos do Arquivo Filho ( RBL )
							  )

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicializacao Obrigatoria					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
Local cOpcao	:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
Local lAllModif	:= .F.
Local lRbkModif	:= .F.
Local lRblModif	:= .F.
Local lRblDelet	:= .F.

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis que serao inicializadas no Corpo da Funcao		  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aRblColDel
Local aRblRecDel
Local nLoop
Local nLoops

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	IF ( cOpcao <> "DELETE" )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Verifica se Houveram Modificacoes no RDV					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( lRblModif := !ArrayCompare( aRblCols , aSvRblCols ) )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Deleto todos os Itens que nao Estao OK					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			GdSuperDel( aRblHeader , @aRblCols , NIL , .T. , GdGetBlock( "RBL" , aRblHeader , .F. ) ) 
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Separa os Itens que foram Deletados     					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			lRblDelet := GdSplitDel( aRblHeader , @aRblCols , @aRblRecnos , @aRblColDel , @aRblRecDel  )
		EndIF
	Else
		lRblModif := .T.
		lRbkModif := .T.
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega os Itens Apenas se Houveram Alteracoes ou na ExclusaoЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( lRblModif )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega as Informacoes deletadas RD4                   	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( lRblDelet )

			aAdd( aItens , GdPutIStrItens() )
			nItens := Len( aItens )
		
			aItens[ nItens , 01 ] := "RBL"
			aItens[ nItens , 02 ] := NIL
			aItens[ nItens , 03 ] := aClone( aRblHeader )
			aItens[ nItens , 04 ] := aClone( aRblColDel )
			aItens[ nItens , 05 ] := aClone( aRblVirtGd )
			aItens[ nItens , 06 ] := aClone( aRblRecDel )

		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega as Informacoes do RD4                   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aItens , GdPutIStrItens() )
		nItens := Len( aItens )

		aItens[ nItens , 01 ] := "RBL"
		aItens[ nItens , 02 ] := {;
									{ "FILIAL" , xFilial( "RBL" , xFilial( "RBK" ) ) },;
									{ "ESCALA" , GetMemVar( "RBK_ESCALA" ) };
							 	 }
		aItens[ nItens , 03 ] := aClone( aRblHeader )
		aItens[ nItens , 04 ] := aClone( aRblCols   )
		aItens[ nItens , 05 ] := aClone( aRblVirtGd )
		aItens[ nItens , 06 ] := aClone( aRblRecnos )

	EndIF

	IF !( lRbkModif )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Atualiza aRbkCols para Verificar se Houveram Alteracoes	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		nLoops := Len( aRbkHeader )
		For nLoop := 1 To nLoops
			aRbkCols[ 01 , nLoop ] := GetMemVar( aRbkHeader[ nLoop , 02 ] )
		Next nLoop
		lRbkModif := !( ArrayCompare( aRbkCols , aSvRbkCols ) )
	EndIF	

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
	Ё se foi Selecionada a Exclusao								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 	lAllModif := ( ( lRblModif ) .or. ( lRbkModif ) )


	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Se Houveram Alteracoes, ou Exclusao efetua a Gravacao        Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( lAllModif )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
		Ё se foi Selecionada a Exclusao								   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aMestre[ 01 , 01 ]	:= "RBK"
		aMestre[ 01 , 02 ]	:= nReg
		aMestre[ 01 , 03 ]	:= ( ( nOpc == 5 ) .or. !( fCompArray( aRbkCols , aSvRbkCols ) ) )
		aMestre[ 01 , 04 ]	:= aClone( aRbkHeader )
		aMestre[ 01 , 05 ]	:= aClone( aRbkVirtEn )
		aMestre[ 01 , 06 ]	:= {}
		aMestre[ 01 , 07 ]	:= aClone( aItens )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Grava as Informacoes                        				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		GdPutInfoData( aMestre , cOpcao , .F. , .F. )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Confirmando a Numeracao Automatica          				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		While ( GetSX8Len() > nGetSX8Len )
			ConfirmSX8()
		End While

	EndIF
	
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( NIL )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbkEscalaVld ЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RBK_ESCALA          Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RBK_ESCALA                         	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbkEscalaVld()

Local cRBKEscala 	:= GetMemVar( "RBK_ESCALA" )
Local lRbkEscalaVld	:= .F.

Begin Sequence

	IF !( lRbkEscalaVld := RbkGetCodigo( @cRbkEscala , .F. , .T. ) )
		Break
	EndIF

	SetMemVar( "RBK_ESCALA" , cRBKEscala )

End Sequence

Return( lRbkEscalaVld )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbkGetCodigo ЁAutorЁMarinaldo de Jesus    Ё Data Ё26/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁObtem Numeracao Valida para o RBK_ESCALA                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁObter Numeracao valida para o RBK_ESCALA                 	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbkGetCodigo( cRbkEscala , lExistChav , lShowHelp )
Return(;
			GetNrExclOk(	@cRBKEscala				,;
							"RBK"					,;
							"RBK_ESCALA"			,;
							"RBK_FILIAL+RBK_ESCALA" ,;
							NIL						,;
							lExistChav				,;
							lShowHelp				 ;
						);
		)

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbkEscalaInitЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁInicializador padrao para o Campo RBK_ESCALA          		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_RELACAO para o campo RBK_ESCALA                         	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbkEscalaInit()
Local cRbkEscala
RbkGetCodigo( @cRbkEscala , .F. )
Return( cRbkEscala )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblEscalaVld ЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RBL_ESCALA          Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RBL_ESCALA                         	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RblEscalaVld()

Local lRblEscalaOk := .T.

Begin Sequence

	IF !( lRblEscalaOk := NaoVazio() )
		Break
	EndIF

	IF !( lRblEscalaOk := ExistCpo( "RBK" ) )
    	Break
    EndIF

End Sequence

Return( lRblEscalaOk )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblItemVld 	 ЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RBL_ITEM 	        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RBL_ITEM                      	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RblItemVld()

Local lRblItemOk := .T.

Begin Sequence

	IF !( lRblItemOk := NaoVazio() )
		Break
	EndIF

	IF !( lRblItemOk := ExistChav( "RBL" , ( GetMemVar( "RBL_ESCALA" ) + GetMemVar( "RBL_ITEM" ) ) ) )
    	Break
    EndIF

End Sequence

Return( lRblItemOk )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblDescriVld ЁAutorЁMarinaldo de Jesus    Ё Data Ё06/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RBL_DESCRI 	        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RBL_DESCRI                      	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RblDescriVld(cDesc)

Local lRblDescriOk := .T.

Begin Sequence

	IF !( lRblDescriOk := !Empty( cDesc )  )
		Break
	EndIF
   
End Sequence

Return( lRblDescriOk )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRblValorVld  ЁAutorЁEmerson Grassi Rocha  Ё Data Ё12/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RBL_VALOR 	        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RBL_VALOR                      	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RblValorVld()

Local lRblValorVld := .T.

Begin Sequence

	IF !( lRblValorVld := Positivo() )
		Break
	EndIF

End Sequence

Return( lRblValorVld )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbkTipoVld   ЁAutorЁEmerson Grassi Rocha  Ё Data Ё12/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para mostrar ComboBox do campo RBK_TIPO.		        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RBK_TIPO		                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbkTipoVld()

Local lRbkTipoVld

Begin Sequence

 IF !( lRbkTipoVld := Pertence("12") )
 	Break
 EndIF
 
End Sequence

Return( lRbkTipoVld )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRbkTipoBox   ЁAutorЁEmerson Grassi Rocha  Ё Data Ё12/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para mostrar ComboBox do campo RBK_TIPO.		        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_CBOX para o campo RBK_TIPO		                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RbkTipoBox()
  
Local cRbkTipoBox

cRbkTipoBox := "1="+STR0013	//"Escala"
cRbkTipoBox += ";"
cRbkTipoBox += "2="+STR0014	//"Grau de Importancia"

Return( cRbkTipoBox )

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁCs130F3RblЁAutorЁEmerson Grassi Rocha v.I   ЁDataЁ12/01/2004Ё
Ё          Ё          Ё     ЁMarinaldo de Jesus   v.II  ЁDataЁ18/02/2004Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддддаддддадддддддддд╢
ЁDescri┤┘o ЁFiltro de Consulta Padrao									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁConsulta Padrao (SXB)				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Cs130F3Rbl()
         
Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
Local cEscala	:= ""
Local cRet		:= "@#.T.@#"

//RBI = Escala do Funcionario
IF ( "RBI_ITESCA" $ cReadVar ) 
	IF ( IsInGetDados( { "RBI_ESCALA" } ) )
		cEscala	:= GdFieldGet("RBI_ESCALA")
	ElseIF ( IsMemVar( "RBI_ESCALA" ) )
		cEscala := GetMemVar("RBI_ESCALA")
	EndIF
//RBH = Escala do Cargo
ElseIF ( "RBH_ITESCA" $ cReadVar )
	IF ( IsInGetDados( { "RBH_ESCALA" } ) )
		cEscala	:= GdFieldGet("RBH_ESCALA")
	ElseIF ( IsMemVar( "RBH_ESCALA" ) )
		cEscala	:= GetMemVar("RBH_ESCALA")
	EndIF
//RBH = Grau de Importancia do Cargo
ElseIF ( "RBH_ITIMPO" $ cReadVar )
	IF ( IsInGetDados( { "RBH_IMPORT" } ) )
		cEscala	:= GdFieldGet("RBH_IMPORT")
	ElseIF ( IsMemVar( "RBH_IMPORT" ) )
		cEscala	:= GetMemVar("RBH_IMPORT")
	EndIF
//RD7 = Definicao da Avaliacao
ElseIF ( "RD7_ITEESC" $ cReadVar )
	IF ( IsInGetDados( { "RD7_ESCALA" } ) )
		cEscala	:= GdFieldGet("RD7_ESCALA")
	ElseIF ( IsMemVar( "RD7_ESCALA" ) )
		cEscala	:= GetMemVar("RD7_ESCALA")
	EndIF
//RD8 = Itens do Modelo de Avaliacao
ElseIF ( "RD8_ITEESC" $ cReadVar )
	IF ( IsInGetDados( { "RD8_ESCALA" } ) )
		cEscala	:= GdFieldGet("RD8_ESCALA")
	ElseIF ( IsMemVar( "RD8_ESCALA" ) )
		cEscala	:= GetMemVar("RD8_ESCALA")
	EndIF
//RDB = Resultado Geral
ElseIF ( "RDB_ITEESC" $ cReadVar )
	IF ( IsInGetDados( { "RDB_ESCALA" } ) )
		cEscala	:= GdFieldGet("RDB_ESCALA")
	ElseIF ( IsMemVar( "RDB_ESCALA" ) )
		cEscala	:= GetMemVar("RDB_ESCALA")
	EndIF
//RDB = Resultado Geral
ElseIF ( "RDB_CODALT" $ cReadVar )
		fQuestEscala(@cEscala)
//RDO = Valores das Competencias
ElseIF ( "RDO_ITEESC" $ cReadVar )
	IF ( IsInGetDados( { "RDO_ESCALA" } ) )
		cEscala	:= GdFieldGet("RDO_ESCALA")
	ElseIF ( IsMemVar( "RDO_ESCALA" ) )
		cEscala	:= GetMemVar("RDO_ESCALA")
	EndIF
//RDJ = Escala de Realizacao
ElseIF ( "RDJ_ITESCR" $ cReadVar )
	IF ( IsInGetDados( { "RDJ_ESCREA" } ) )
		cEscala	:= GdFieldGet("RDJ_ESCREA")
	ElseIF ( IsMemVar( "RDJ_ESCREA" ) )
		cEscala	:= GetMemVar("RDJ_ESCREA")
	EndIF
//RDJ = Escala de Atingimento (1)
ElseIF ( "RDJ_ITESAT" $ cReadVar )
	IF ( IsInGetDados( { "RDJ_ESCATG" } ) )
		cEscala	:= GdFieldGet("RDJ_ESCATG")
	ElseIF ( IsMemVar( "RDJ_ESCATG" ) )
		cEscala	:= GetMemVar("RDJ_ESCATG")
	EndIF
//RDJ = Escala de Atingimento (2)
ElseIF ( "RDJ_ITATCN" $ cReadVar )
	IF ( IsInGetDados( { "RDJ_ESCCON" } ) )
		cEscala	:= GdFieldGet("RDJ_ESCCON") 
	ElseIF ( IsMemVar( "RDJ_ESCCON" ) )
		cEscala	:= GetMemVar("RDJ_ESCCON") 
	EndIF
//RDJ = Escala de Conhecimento (1)
ElseIF ( "RDJ_ITECOA" $ cReadVar )
	IF ( IsInGetDados( { "RDJ_ESCCON" } ) )
		cEscala	:= GdFieldGet("RDJ_ESCCON")
	ElseIF ( IsMemVar( "RDJ_ESCCON" ) )
		cEscala	:= GetMemVar("RDJ_ESCCON")
	EndIF
//RDJ = Escala de Conhecimento (2)
ElseIF ( "RDJ_ITECOP" $ cReadVar )
	IF ( IsInGetDados( { "RDJ_ESCCON" } ) )
		cEscala	:= GdFieldGet("RDJ_ESCCON")
	ElseIF ( IsMemVar( "RDJ_ESCCON" ) )
		cEscala	:= GetMemVar("RDJ_ESCCON")
	EndIF

// SQM = Nivel do Curso do curriculo
ElseIF ( "QM_NIVEL" $ cReadVar )
	cEscala	:= Rs010Nivel()      
	
//SQT = Escala de Grupo de Curso
ElseIF ( "QT_GRUPO" $ cReadVar )
	cEscala	:= FDesc("SQX",GetMemVar( "QT_TIPO" ),"QX_GRUPO")
	

//RA1 = Escala de Grupo de Curso
ElseIF ( "RA1_GRUPO" $ cReadVar )
	cEscala	:= FDesc("SQX",GetMemVar( "RA1_TIPOPP" ),"QX_GRUPO")   
	
//RBQ = Habilidades do Participante
ElseIF ( "RBQ_ITEESC" $ cReadVar )
	If IsInGetDados( { "RBQ_ESCALA" } )
		cEscala	:= GDFieldGet("RBQ_ESCALA", n)
	Else
		cEscala := M->RBQ_ESCALA
	EndIf
EndIF

IF !Empty( cEscala )
	cRet := "@#RBL->RBL_ESCALA=='"+cEscala+"'@#"   
EndIF

Return( cRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё28/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁCSAA130                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function MenuDef()

 Local aRotina :=   {;
							{ STR0001 , "AxPesqui"	 , 0 , 01,,.F.} ,; //"Pesquisar"
							{ STR0002 , "CSAA130Mnt" , 0 , 02 } ,; //"Visualizar"
							{ STR0003 , "CSAA130Mnt" , 0 , 03 } ,; //"Incluir"
							{ STR0004 , "CSAA130Mnt" , 0 , 04 } ,; //"Alterar"
							{ STR0005 , "CSAA130Mnt" , 0 , 05 }  ; //"Excluir"
						}
Return aRotina
