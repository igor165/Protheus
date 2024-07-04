#INCLUDE "PROTHEUS.CH"
#INCLUDE "APDA270.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "shell.ch"
#INCLUDE "fwcommand.ch"

#DEFINE APDA270_ELEMENTOS_FOLDER			04

#DEFINE APDA270_FOLDER_PRINCIPAL			01
#DEFINE APDA270_FOLDER_AGENDA				02
#DEFINE APDA270_FOLDER_AVALIADOS           	03
#DEFINE APDA270_FOLDER_AVALIADORES         	04

#DEFINE APDA270_ELEMENTOS_OBJ_FOLDER		03

#DEFINE APDA270_FOLDER_OBJ_TITLE			01
#DEFINE APDA270_FOLDER_OBJ_NUMBER			02
#DEFINE APDA270_FOLDER_OBJECTS				03
#DEFINE APDA270_OBJ_ELEMENTOS				27

#DEFINE APDA270_ALIAS						01
#DEFINE APDA270_ACOLS						02
#DEFINE APDA270_ASVCOLS						03
#DEFINE APDA270_ALSTCOLS					04
#DEFINE APDA270_ACOLSDEL					05
#DEFINE APDA270_AHEADER						06
#DEFINE APDA270_AHEADERALL					07
#DEFINE APDA270_ARECNOS						08
#DEFINE APDA270_ARECNOSDEL					09
#DEFINE APDA270_AKEYS						10
#DEFINE APDA270_NUSADO						11
#DEFINE APDA270_AVIRTUAL					12
#DEFINE APDA270_AVISUAL	    				13
#DEFINE APDA270_AALTERA						14
#DEFINE APDA270_ANAOALTERA					15
#DEFINE APDA270_ANOTFIELDS					16
#DEFINE APDA270_AFIELDS						17
#DEFINE APDA270_AGETS						18
#DEFINE APDA270_ATELA						19
#DEFINE APDA270_OBJ							20
#DEFINE APDA270_TIPO_OBJ					21
#DEFINE APDA270_BVALID						22
#DEFINE APDA270_BINIT						23
#DEFINE APDA270_LGRAVA						24
#DEFINE APDA270_BEXIT						25
#DEFINE APDA270_BSORT						26
#DEFINE APDA270_BDELEMPTY					27

Static __aRd6Header__	:= {}
Static __aRd6Virtual__	:= {}
Static __aRd6Visual__	:= {}

Static __aRd6aHeader__	:= {}
Static __aRd6aVirtual__	:= {}
Static __aRd6aVisual__	:= {}

Static __aRd9Header__	:= {}
Static __aRd9Virtual__	:= {}
Static __aRd9Visual__	:= {}

Static __aRdaHeader__	:= {}
Static __aRdaVirtual__	:= {}
Static __aRdaVisual__	:= {}

Static __aRdhHeader__	:= {}
Static __aRdhVirtual__	:= {}
Static __aRdhVisual__	:= {}

Static __aRdcHeader__	:= {}
Static __aRdcVirtual__	:= {}
Static __aRdcVisual__	:= {}

Static __aRdpHeader__	:= {}
Static __aRdpVirtual__	:= {}
Static __aRdpVisual__	:= {}

Static nAPDA270Seed		:= 1000
/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270   �Autor�Marinaldo de Jesus       � Data �29/10/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Avaliacoes                                      �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�����������������������������������������������������������������������Ĵ
�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           �
�����������������������������������������������������������������������Ĵ
�Programador � Data   � BOPS �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
�Cecilia Car.�03/07/14�TPZWBQ�Incluido o fonte da 11 para a 12 e efetua-�
�            �        �      �da a limpeza.                             �
�Allyson M.  �24/07/14�TQEBW2�Adicionado mensagem de validacao referente�
�            �        �      �preenchimento do projeto. 				�
�Flavio C.   �26/08/14�TQKHEG�Corre��es referente a montagem da avalia�ao�
�Wag Mobile  �05/11/14|TQXQK4|Ajuste para realizar a montagem da avalia-�
�            �        |      |��o mesmo que n�o haja um projeto.    	�
�Renan Borges�05/06/15|TSMWAR|Ajuste para ao gerar a agenda da avalia��o�
�            �        |      |as datas respeitem as informa��es do Per�-�
�            �        |      |odo.                                      �
�Renan Borges�04/11/15|TTNHQK|Ajuste para carregar os avaliadores seguin�
�            �        |      |do a hierarquia corretamente, e ajustar a �
�            �        |      |mensagem da 3� pasta.                     �
�Renan Borges�18/03/16|TUTWT2|Ajuste para gravar corretamente a avalia- �
�            �        |      |��o ap�s mudar o periodo, ou posicionar no�
�            �        |      |campo de data, sem passar pelas abas de   �
�            �        |      |avaliados e avaliadores.                  �
�Isabel N.   �16/12/16|TWJFFO|Ajuste na valida��o de vari�veis na fun��o�
�            �        |MRH-875|Rd9Rdh2RdaChg p/ correto posicionamento e�
�            �        |      |grava��o dos avaliadores devido � primeira�
�            �        |      |linha ser deletada nos registros.         �
�Isabel N.   �31/01/17|MRH-5068|Ajustes nas fun��es Rd9Rdh2RdaChg (aviso �
�            �        |        |indevido ao incluir nova avalia��o),     �
�            �        |        |GdRdpRd9Chg (salvar saindo da aba de ava-�
�            �        |        |liados),Rd9Lbx2Rd9Gd e RdaLbx2RdaGd (tra-�
�            �        |        |zer corretamente os nomes dos avaliados e�
�            �        |        |avaliadores existentes na primeira linha �
�            �        |        |ao incluir/deletar participantes).       �
�������������������������������������������������������������������������/*/
Function APDA270( cAlias , nReg , nOpc , lExecAuto , lBldAuto , dPerIni , dPerFim )

Local aAreas		:= {}
Local aIndex		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RDA_NOME", "RD6_NOMRSP", "RD9_NOME", "RD0_NOME"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Local cFiltroPers	:= AllTrim( SuperGetMv( "MV_AVALFLT" , NIL , "0" ) )
Local cKeyFilter	:= ""
Local lExistOpc		:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos
Local nLoop
Local nLoops

n	:= NIL

/*/
��������������������������������������������������������������Ŀ
�Verificacao do parametro MV_AVALFLT						   �
����������������������������������������������������������������/*/
If !( cFiltroPers == "1" )
	cFiltroPers := "0"
EndIf

/*/
��������������������������������������������������������������Ŀ
�Salva as areas de Entrada									   �
����������������������������������������������������������������/*/
aAdd( aAreas , RD0->( GetArea() ) )
aAdd( aAreas , RD6->( GetArea() ) )
aAdd( aAreas , RD9->( GetArea() ) )
aAdd( aAreas , RDA->( GetArea() ) )
aAdd( aAreas , RDB->( GetArea() ) )
aAdd( aAreas , RDC->( GetArea() ) )
aAdd( aAreas , RDD->( GetArea() ) )
aAdd( aAreas , RDH->( GetArea() ) )
aAdd( aAreas , RDP->( GetArea() ) )
aAdd( aAreas , GetArea() )

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	�So Executa se o Modo de Acesso dos Arquivos do Modulo APD esti�
	�verem OK													   �
	����������������������������������������������������������������/*/
	IF ( !ApdRelationFile() )
		Return
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	�Redefine o Alias                                              �
	����������������������������������������������������������������/*/
	cAlias	:= "RD6"

	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	Private cCadastro	:= OemToAnsi( STR0001 ) //'Avalia��o'

	DEFAULT lBldAuto	:= .F.
	Private lBldAvaAuto	:= lBldAuto

	IF ( lExistOpc )

		/*/
		��������������������������������������������������������������Ŀ
		�Garante o Posicinamento do Recno                              �
		����������������������������������������������������������������/*/
		DEFAULT nReg	:= ( cAlias )->( Recno() )
		IF !Empty( nReg )
			( cAlias )->( MsGoto( nReg ) )
		EndIF

		DEFAULT lExecAuto	:= .F.
		DEFAULT dPerIni		:= dDataBase
		DEFAULT dPerFim		:= dDataBase

		IF ( !( lBldAvaAuto ) .and. ( lExecAuto ) )

			nPos := aScan( aRotina , { |x| x[4] == nOpc } )
			IF ( nPos == 0 )
				Break
			EndIF
			bBlock := &( "{ |a,b,c,d| " + aRotina[ nPos , 2 ] + "(a,b,c,d) }" )
			Eval( bBlock , cAlias , nReg , nPos )

		Else

			APDA270Mnt( cAlias , nReg , nOpc , .T. , dPerIni , dPerFim )

		EndIF

	Else
		//Tratamento de acesso a Dados Sens�veis
		If lBlqAcesso
			//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
			Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
			Break
		EndIf

		If cFiltroPers == "0"//Param == 0 usa filtro padrao | Param == 1 sem filtro e permite uso de filtro personalizado

			Private bFiltraBrw	:= { || NIL }

			/*/
			������������������������������������������������������������������������Ŀ
			� Monta o Filtro de Acordo com o Usuario para uso na FilBrowse           �
			��������������������������������������������������������������������������/*/
			cKeyFilter	:= Rd6RetUsrFilter()

			/*/
			������������������������������������������������������������������������Ŀ
			� Inicializa o filtro utilizando a funcao FilBrowse                      �
			��������������������������������������������������������������������������/*/
			bFiltraBrw 	:= { || FilBrowse( cAlias , @aIndex , @cKeyFilter ) }
			Eval( bFiltraBrw )

			Mbrowse( 006 , 001 , 022 , 075 , cAlias , NIL , NIL , NIL , NIL , NIL , APDA270MarksRD6() )

			/*/
			������������������������������������������������������������������������Ŀ
			� Finaliza e Deleta o filtro utilizando a funcao FilBrowse               �
			��������������������������������������������������������������������������/*/
			EndFilBrw( cAlias , aIndex )

		Else

			Mbrowse( 006 , 001 , 022 , 075 , cAlias , NIL , NIL , NIL , NIL , NIL , APDA270MarksRD6() )

		EndIf

	EndIF

End Sequence

/*/
��������������������������������������������������������������Ŀ
�Coloca o Ponteiro do Mouse em Estado de Espera			   	   �
����������������������������������������������������������������/*/
MyCursorWait()
/*/
��������������������������������������������������������������Ŀ
�Limpa o Cache dos Cabecalhos de Dados                         �
����������������������������������������������������������������/*/
CacheClear()

/*/
������������������������������������������������������������������������Ŀ
� Restaura os Dados de Entrada                                      	 �
��������������������������������������������������������������������������/*/
nLoops := Len( aAreas )
For nLoop := 1 To nLoops
	RestArea( aAreas[ nLoop ] )
Next nLoop

/*/
��������������������������������������������������������������Ŀ
�Restaura o Cursor do Mouse                				   	   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( NIL )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �InAPDA270Exec �Autor �Marinaldo de Jesus   � Data �24/08/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Executar Funcoes Dentro de APDA270                           �
������������������������������������������������������������������������Ĵ
�Sintaxe   �InAPDA270Exec( cExecIn , aFormParam )						 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �uRet                                                 	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �Generico 													 �
��������������������������������������������������������������������������/*/
Function InAPDA270Exec( cExecIn , aFormParam )

Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= &( cExecIn )
EndIF

Return( uRet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Vis� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Avaliacoes (Visualizar)           				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function APDA270Vis( cAlias , nReg )
Return( APDA270( cAlias , nReg , 2 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Inc� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Avaliacoes (Incluir)	           				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function APDA270Inc( cAlias , nReg )
Return( APDA270( cAlias , nReg , 3 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Alt� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Avaliacoes (Alterar)	           				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function APDA270Alt( cAlias , nReg )
Return( APDA270( cAlias , nReg , 4 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Del� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Avaliacoes (Excluir)	           				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function APDA270Del( cAlias , nReg )
Return( APDA270( cAlias , nReg , 5 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �MyCursorWait�Autor�Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Chamada a CursorWait() com tratamento na Geracao Automatica	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function MyCursorWait()

IF !( lBldAvaAuto )
	CursorWait()
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �MyCursorArrow�Autor�Marinaldo de Jesus    � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Chamada a CursorArrow() com tratamento na Geracao Automatica�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function MyCursorArrow()

IF !( lBldAvaAuto )
	CursorArrow()
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �CacheClear� Autor �Marinaldo de Jesus     � Data �16/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Limpa as Variaveis em Cache     	           				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function CacheClear()

Begin Sequence

	IF !( lBldAvaAuto )
		Break
	EndIF

	__aRd6Header__	:= NIL
	__aRd6Virtual__	:= NIL
	__aRd6Visual__	:= NIL

	__aRd6aHeader__	:= NIL
	__aRd6aVirtual__:= NIL
	__aRd6aVisual__	:= NIL

	__aRd9Header__	:= NIL
	__aRd9Virtual__	:= NIL
	__aRd9Visual__	:= NIL

	__aRdaHeader__	:= NIL
	__aRdaVirtual__	:= NIL
	__aRdaVisual__	:= NIL

	__aRdhHeader__	:= NIL
	__aRdhVirtual__	:= NIL
	__aRdhVisual__	:= NIL

	__aRdcHeader__	:= NIL
	__aRdcVirtual__	:= NIL
	__aRdcVisual__	:= NIL

	__aRdpHeader__	:= NIL
	__aRdpVirtual__	:= NIL
	__aRdpVisual__	:= NIL

End Sequence

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Mnt� Autor �Marinaldo de Jesus     � Data �17/05/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Avaliacoes (Manutencao)           				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �APDA270Mnt( cAlias , nReg , nOpc , lDlgPadSiga )			�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias 		= Alias do arquivo                              �
�          �nReg   		= Numero do registro                            �
�          �nOpc   		= Numero da opcao selecionada                   �
�          �lDlgPadSiga = Numero da opcao selecionada                   �
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function APDA270Mnt( cAlias , nReg , nOpc , lDlgPadSiga , dPerIni , dPerFim )

Local aArea				:= GetArea(Alias())
Local aAreaRD6			:= RD6->( GetArea() )
Local aSvKeys			:= GetKeys()
Local aAdvSize			:= {}
Local aObjCoords		:= {}
Local aObjSize			:= {}
Local aGdsCoords		:= {}
Local aGdCoords1		:= {}
Local aGdCoords2		:= {}
Local aGdCoords3		:= {}
Local aCols				:= {}
Local aColsF2			:= {}
Local aNotFields		:= {}
Local aRecnos			:= {}
Local aKeys				:= {}
Local aAltera			:= {}
Local aAlterF2			:= {}
Local aNaoAltera		:= {}
Local aFields			:= {}
Local aFieldF2			:= {}
Local aFieldsAux		:= {}
Local aTitles			:= Array( APDA270_ELEMENTOS_FOLDER )
Local aPages			:= Array( APDA270_ELEMENTOS_FOLDER )
Local aInfoAdvSize		:= {}
Local aButtons			:= {}
Local aRd6Keys			:= {}
Local aLogAux			:= {}
Local aLogTitAux		:= {}
Local aLogChkDel		:= {}
Local aLogTitChkDel		:= {}
Local aChkDelOk			:= {}
Local aRd9Query			:= {}
Local aRdaQuery			:= {}
Local aRdpQuery			:= {}

Local bSet15			:= { || NIL }
Local bSet24			:= { || NIL }
Local bTreeAloca		:= { || NIL }
Local bAPDA270GdSeek	:= { || NIL }
Local bBuildAva			:= { || NIL }
Local bCalcAva			:= { || NIL }
Local bAPDA270Leg		:= { || NIL }
Local bCalend			:= { || NIL }
Local bSkip				:= { || .F. }
Local bRd9GdDelOk		:= { |lDelOk| MyCursorWait() , lDelOk := Rd9GdDelOk( IF( lRd6Status , nOpc , 2 ) ) , MyCursorArrow() , lDelOk }
Local bRdaGdDelOk		:= { |lDelOk| MyCursorWait() , lDelOk := RdaGdDelOk( IF( lRd6Status , nOpc , 2 ) ) , MyCursorArrow() , lDelOk }
Local bRdpGdDelOk		:= { |lDelOk| MyCursorWait() , lDelOk := RdpGdDelOk( IF( lRd6Status , nOpc , 2 ) ) , MyCursorArrow() , lDelOk }
Local bAPDA270Grava		:= { || NIL }
Local bKey				:= NIL
Local bDialogInit		:= { || NIL }
Local bGetRd6			:= { || NIL }
Local bGetRdp			:= { || NIL }
Local bObjValid			:= { | cTipo , oObjValid | IF( ( cTipo == "G" ) , oObjValid:LinhaOk() , IF( ( cTipo == "E" ) , APDA270EnTOk( nOpc , oObjValid ) , .T. ) ) }

Local cTitLogDel		:= NIL
Local cMsgLogDel		:= NIL
Local cKey				:= "__cKey__"
Local cAliasNoLock		:= ""

Local lGdSeek			:= .F.
Local lLocks			:= .F.
Local lExecLock			:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local lRd6Status		:= .T.
Local lChkDelShwLog		:= .T.
Local lChkDelSoft		:= .F.
Local lChkDelOk			:= .T.

Local nOpcAlt			:= 0
Local nObjNumber		:= 0
Local nObj				:= 0
Local nActFolder		:= 0
Local nFolder			:= 0
Local nFolders			:= 0
Local nUsado			:= 0
Local nLoop				:= 0
Local nRdpGhostCol		:= 0
Local nRd9GhostCol		:= 0
Local nRdaGhostCol		:= 0
Local nOpcNewGd			:= 0

Local oDlg				:= NIL
Local aBtn80			:= {}					//Array para retorno do PE APD80B01

Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords 	:= {}
Local aObj2Size		:= {}
Local aObj2Coords 	:= {}
Local aObj3Size		:= {}
Local aObj3Coords 	:= {}
Local aAdv4Size		:= {}
Local aInfo4AdvSize	:= {}
Local aObj4Size		:= {}
Local aObj4Coords 	:= {}
Local aAdv5Size		:= {}
Local aInfo5AdvSize	:= {}
Local aObj5Size		:= {}
Local aObj5Coords 	:= {}
Local aObj6Size		:= {}
Local aObj6Coords 	:= {}
Local aAdv7Size		:= {}
Local aInfo7AdvSize	:= {}
Local aObj7Size		:= {}
Local aObj7Coords 	:= {}
Local aAdv8Size		:= {}
Local aInfo8AdvSize	:= {}
Local aObj8Size		:= {}
Local aObj8Coords 	:= {}
Local aAdv9Size		:= {}
Local aInfo9AdvSize	:= {}
Local aObj9Size		:= {}
Local aObj9Coords 	:= {}

Private cGdRdpRd9Chg	:= "__cGdRdpRd9Chg__"

Private nGetSX8Len		:= GetSX8Len()
Private __nRd9AtAnt		:= 0
Private __nRdhAtAnt		:= 0

Private oFolders		:= NIL

Private aGets
Private aTela
Private aFolders
Private aMarksCollor
Private aRd9LstColsAll
Private aColsRDA

Private cCdTipRd6Lst
Private cRdpNumGhostCol
Private cRd9NumGhostCol
Private cRdaNumGhostCol

DEFAULT cAlias		:= "RD6"
DEFAULT nReg		:= 0
DEFAULT nOpc		:= 1
DEFAULT dPerIni		:= dDataBase
DEFAULT dPerFim		:= dDataBase

/*/
��������������������������������������������������������������Ŀ
�Poe o Cursor do Mouse em Estado de Espera					   �
����������������������������������������������������������������/*/
MyCursorWait()

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	�Checa a Opcao Selecionada									   �
	����������������������������������������������������������������/*/
	aRotSetOpc( cAlias , @nReg , nOpc )

	/*/
	��������������������������������������������������������������Ŀ
	�Define as Opcoes para a NewGetDados						   �
	����������������������������������������������������������������/*/
	nOpcNewGd	:= IF( ( ( Visual ) .or. ( Exclui ) ) , 0 , ( GD_INSERT + GD_UPDATE + GD_DELETE ) )

	/*/
	��������������������������������������������������������������Ŀ
	� Define o Array que ira armazenar as cores das Legendas	   �
	����������������������������������������������������������������/*/
	aMarksCollor := { Array( 02 , 03 ) , Array( 07 , 03 ) }

	/*/
	��������������������������������������������������������������Ŀ
	� Avaliados                             					   �
	����������������������������������������������������������������/*/
	aMarksCollor[ 1 , 1 , 1 ]	:= "BR_VERMELHO"	; aMarksCollor[ 1 , 1 , 2 ]	:= OemToAnsi( STR0036 )	//"Pendente"
	aMarksCollor[ 1 , 2 , 1 ]	:= "BR_VERDE"		; aMarksCollor[ 1 , 2 , 2 ]	:= OemToAnsi( STR0037 )	//"OK"

	/*/
	��������������������������������������������������������������Ŀ
	� Avaliadores                           					   �
	����������������������������������������������������������������/*/
	aMarksCollor[ 2 , 1 , 1 ]	:= "BR_VERMELHO"	; aMarksCollor[ 2 , 1 , 2 ]	:= OemToAnsi( STR0038 )	//"Avalia��o n�o enviada"
	aMarksCollor[ 2 , 2 , 1 ]	:= "BR_AMARELO"		; aMarksCollor[ 2 , 2 , 2 ] := OemToAnsi( STR0039 )	//"Avalia��o n�o retornada"
	aMarksCollor[ 2 , 3 , 1 ]	:= "PMSTASK1"  		; aMarksCollor[ 2 , 3 , 2 ] := OemToAnsi( STR0043 )	//"Auto-avalia��o n�o enviada"
	aMarksCollor[ 2 , 4 , 1 ]	:= "PMSTASK2"  		; aMarksCollor[ 2 , 4 , 2 ] := OemToAnsi( STR0044 )	//"Auto-avalia��o n�o retornada"
	aMarksCollor[ 2 , 5 , 1 ]	:= "BPMSEDT1"		; aMarksCollor[ 2 , 5 , 2 ] := OemToAnsi( STR0050 )	//"Avalia��o de Consenso n�o enviada"
	aMarksCollor[ 2 , 6 , 1 ]	:= "BPMSEDT2"		; aMarksCollor[ 2 , 6 , 2 ] := OemToAnsi( STR0051 )	//"Avalia��o de Consenso n�o retornada"
	aMarksCollor[ 2 , 7 , 1 ]	:= "BR_VERDE"		; aMarksCollor[ 2 , 7 , 2 ]	:= OemToAnsi( STR0037 )	//"OK"

	/*/
	��������������������������������������������������������������Ŀ
	� Quanto nao for Montagem Automatica     					   �
	����������������������������������������������������������������/*/
	IF !( lBldAvaAuto )

		/*/
		��������������������������������������������������������������Ŀ
		� Verifica o Usuario 										   �
		����������������������������������������������������������������/*/
		IF !( APDA270UsrChk( nOpc , cAlias , nReg , Inclui ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Obtendo os Resources para os Avaliados					   �
		����������������������������������������������������������������/*/
		aMarksCollor[ 1 , 1 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 1 , 1 , 1 ] )
		aMarksCollor[ 1 , 2 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 1 , 2 , 1 ] )

		/*/
		��������������������������������������������������������������Ŀ
		� Obtendo os Resources para os Avaliadores					   �
		����������������������������������������������������������������/*/
		aMarksCollor[ 2 , 1 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 2 , 1 , 1 ] )
		aMarksCollor[ 2 , 2 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 2 , 2 , 1 ] )
		aMarksCollor[ 2 , 3 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 2 , 3 , 1 ] )
		aMarksCollor[ 2 , 4 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 2 , 4 , 1 ] )
		aMarksCollor[ 2 , 5 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 2 , 5 , 1 ] )
		aMarksCollor[ 2 , 6 , 3 ]	:= LoadBitmap( GetResources() , aMarksCollor[ 2 , 6 , 1 ] )

		/*/
		��������������������������������������������������������������Ŀ
		�Se For Inclusao ou Alteracao Define Tecla de Atalho e Botao pa�
		�ra Alocacao de Participantes nas Visoes					   �
		����������������������������������������������������������������/*/
		IF (;
				( Inclui );
				.or.;
				( Altera );
				.or.;
				( Visual );
			)

			IF !( Visual )

				/*/
				��������������������������������������������������������������Ŀ
				�Define a Tecla de Atalho para Alocacao <F4>            	   �
				����������������������������������������������������������������/*/
				bTreeAloca	:= { || (;
						  				 APDA270Aloca( nOpc ),;
						  				 SetKey( VK_F4 , bTreeAloca );
						  			);
						  		}

				/*/
				��������������������������������������������������������������Ŀ
				�Define o Botao de Alocacao para a EnchoiceBar				   �
				����������������������������������������������������������������/*/
				aAdd( aButtons ,;
									{	"relacionamento_direita",;
				       					bTreeAloca,;
				    					OemToAnsi( STR0016 );	//'Alocacao...<F4>'
				       				};
					)

			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Define o Botao de Pesquisa na GetDados					   �
			����������������������������������������������������������������/*/
			bAPDA270GdSeek := { ||	APDA270GdSeek( lGdSeek , nActFolder , aPages ),;
									SetKey( VK_F5 , bAPDA270GdSeek );
						   }
			aAdd(;
					aButtons	,;
									{;
										"pesquisa",;
			   							bAPDA270GdSeek,;
			       	   					OemToAnsi( STR0002 + "...<F5>"  ),;	//"Pesquisar"
			       	   					OemToAnsi( STR0002 );				//"Pesquisar"
			           				};
			     )

			IF !( Visual )

				/*/
				��������������������������������������������������������������Ŀ
				� Define o Botao Construcao do Calendario					   �
				����������������������������������������������������������������/*/
				bCalend := { ||	BldCalend( nActFolder , @aFolders , aPages ),;
								SetKey( VK_F6 , bCalend );
						   }
				aAdd(;
						aButtons	,;
										{;
											"clock01",;
				   							bCalend,;
				       	   					OemToAnsi( STR0123 + "...<F6>"  ),;	//"Calend�rio"
				       	   					OemToAnsi( STR0123 );				//"Calend�rio"
				           				};
				     )
				/*/
				��������������������������������������������������������������Ŀ
				� Define o Botao de a Construcao da Avaliacao 	 		 	   �
				����������������������������������������������������������������/*/
				bBuildAva := { || BldCalend( nActFolder , @aFolders , aPages, .F.), APDA270AvaBld( nActFolder , aPages ),;
								 	SetKey( VK_F7 , bBuildAva );
						   	 }
				aAdd(;
						aButtons	,;
										{;
											"MSGREPLY",;
				   							bBuildAva,;
				       	   					OemToAnsi( STR0154 + "...<F7>"  ),;	//"Gerar Agenda"
				       	   					OemToAnsi( STR0154 );				//"Gerar Agenda"
				           				};
				     )

				/*/
				��������������������������������������������������������������Ŀ
				� Define o Botao de Calcular Avaliacao      	 		 	   �
				����������������������������������������������������������������/*/
				bCalcAva := { ||	APDA270BotCal( nActFolder , aPages,aCols),;
									SetKey( VK_F10 , bCalcAva );
							 }

				aAdd(;
						aButtons	,;
										{;
											"BPMSDOCI",;
				   							bCalcAva,;
				       	   					OemToAnsi( STR0142 + STR0143  ),;	//"Calcular Avaliacao do Avaliado" # "...<F10>"
				       	   					OemToAnsi( STR0141 );				//"Calcular"
				           				};
				     )

			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Define o Botao de Legenda             					   �
			����������������������������������������������������������������/*/
			bAPDA270Leg := { ||	APDA270Leg( aMarksCollor , NIL , .T. , nActFolder , aPages ),;
								SetKey( VK_F8 , bAPDA270Leg );
						   }
			aAdd(;
					aButtons	,;
									{;
										"PMSCOLOR",;
			   							bAPDA270Leg,;
			       	   					OemToAnsi( STR0035 + "...<F8>" ),; //'Legenda'
			       	   					OemToAnsi( STR0035 ) ; //'Legenda'
			           				};
			     )

		EndIF
		//Ponto de entrada para inclusao de botoes na TOOBAR.
		If ExistBlock("APD80B01")
			aBtn80:=ExecBlock("APD80B01",.F.,.F.)
			If Valtype(aBtn80)="A".AND.Len(aBtn80)>=2 //Garante que tenha o icone do botao e a fun��o a ser executada
				aadd(aButtons,aBtn80)
			EndIf
		EndIf
		/*/
		��������������������������������������������������������������Ŀ
		� Monta as Dimensoes dos Objetos         					   �
		����������������������������������������������������������������/*/
		DEFAULT lDlgPadSiga	:= .F.
		aAdvSize		:= MsAdvSize( NIL , lDlgPadSiga )
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }

	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Carrega os Titulos dos Folders   							   �
	����������������������������������������������������������������/*/
	aTitles[ APDA270_FOLDER_PRINCIPAL		] := OemToAnsi( STR0012 )	//'&Principal'
	aTitles[ APDA270_FOLDER_AGENDA			] := OemToAnsi( STR0101 )	//'A&genda'
	aTitles[ APDA270_FOLDER_AVALIADOS		] := OemToAnsi( STR0015	)	//'&Avaliados'
	aTitles[ APDA270_FOLDER_AVALIADORES		] := OemToAnsi( STR0017	)	//'A&validadores'

	/*/
	��������������������������������������������������������������Ŀ
	� Inicializa aPages											   �
	����������������������������������������������������������������/*/
	aPages[ APDA270_FOLDER_PRINCIPAL		] := StrTran( OemToAnsi( STR0012 ) , "&" , "" ) //'&Principal'
	aPages[ APDA270_FOLDER_AGENDA			] := StrTran( OemToAnsi( STR0101 ) , "&" , "" ) //'A&genda'
	aPages[ APDA270_FOLDER_AVALIADOS		] := StrTran( OemToAnsi( STR0015 ) , "&" , "" ) //'&Avaliados'
	aPages[ APDA270_FOLDER_AVALIADORES		] := StrTran( OemToAnsi( STR0017 ) , "&" , "" ) //'A&validadores'

	/*/
	��������������������������������������������������������������Ŀ
	� Monta o Array aFolders Com Todos os Objetos				   �
	����������������������������������������������������������������/*/
	aFolders := Array( APDA270_ELEMENTOS_FOLDER , APDA270_ELEMENTOS_OBJ_FOLDER )
	nFolders := Len( aFolders )
	For nFolder := 1 To nFolders
		IF ( nFolder == APDA270_FOLDER_PRINCIPAL )
			nObjNumber		:= 1
			aFolders[ nFolder , APDA270_FOLDER_OBJ_TITLE	]	:= aTitles[ APDA270_FOLDER_PRINCIPAL ]
			aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]	:= nObjNumber
	    	aFolders[ nFolder , APDA270_FOLDER_OBJECTS		]	:= Array( nObjNumber )
	    	For nObj := 1 To nObjNumber
				/*/
				��������������������������������������������������������������Ŀ
				� Carrega Array com os Numeros de Elementos					   �
				����������������������������������������������������������������/*/
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj ]	:= Array( APDA270_OBJ_ELEMENTOS )
				IF ( nObj == 1 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS ]	:= cAlias
					/*/
					��������������������������������������������������������������Ŀ
					� Reinicializa as Variaveis									   �
					����������������������������������������������������������������/*/
					aCols		    := {}
					aAltera			:= {}

					IF !( Inclui )
						aNaoAltera		:= { "RD6_CODIGO" , "RD6_CODTIP" , "RD6_CODVIS" , "RD6_CODMOD" , "RD6_CODCOM" }
					Else
						aNaoAltera		:= {}
					EndIF
					aNotFields		:= { "RD6_FILIAL", "RD6_PERIOD", "RD6_INTMES", "RD6_INIGER", "RD6_INIRSP", "RD6_RSPADO", "RD6_RSPDOR", "RD6_RSPCON", "RD6_AGDSCH", "RD6_AGDENV"}
					aRecnos			:= {}
					aFields			:= {}
					aGets			:= {}
					aTela			:= {}
					bSkip			:= { || .F. }
					bKey			:= NIL
					cKey			:= "__cKey__"
					bGetRd6			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aKeys := NIL ),;
														aCols := RD6->(;
																			GDBuildCols(	@__aRd6Header__	,;	//01 -> Array com os Campos do Cabecalho da GetDados
																							@nUsado			,;	//02 -> Numero de Campos em Uso
																							@__aRd6Virtual__,;	//03 -> [@]Array com os Campos Virtuais
																							@__aRd6Visual__	,;	//04 -> [@]Array com os Campos Visuais
																							cAlias			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																							aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																							@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																							cAlias		   	,;	//08 -> Alias do Arquivo Pai
																							NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																							NIL				,;	//10 -> Bloco para condicao de Loop While
																							NIL				,;	//11 -> Bloco para Skip no Loop While
																							NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols
																							NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																							NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																							NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																							NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																							NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																							NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																							.F.				,;	//19-> Carregar Coluna Fantasma
																							NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																							NIL				,;	//21 -> Verifica se Deve Checar se o campo eh usado
																							NIL				,;	//22 -> Verifica se Deve Checar o nivel do usuario
																							NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																							@aKeys			,;	//24 -> [@]Array que contera as chaves conforme recnos
																							@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																							@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																							NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
																							NIL				,;	//28 -> Utiliza Numeracao na GhostCol
																							NIL				,;	//29 ->
																							NIL				,;	//30 ->
																							nOpc			 ;	//31 ->
																	    				);
														  				),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  					}
					/*/
					��������������������������������������������������������������Ŀ
					�Lock do Registro do RD6									   �
					����������������������������������������������������������������/*/
					IF !( lLocks := WhileNoLock( "RD6" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRd6 , !( lBldAvaAuto ) ) )
						cAliasNoLock := "RD6"
						Break
					EndIF
					MyCursorWait()
					/*/
					��������������������������������������������������������������Ŀ
					� Reposiciona no Registro para a Carga das Variaveis de Memoria�
					����������������������������������������������������������������/*/
					IF ( nReg > 0 )
						RD6->( MsGoto( nReg ) )
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica se Pode Haver Exclusao                       	   �
					����������������������������������������������������������������/*/
					IF ( Exclui )
						/*/
						��������������������������������������������������������������Ŀ
						�Esta primeira a Chamada a ApdChkDel() serve apenas para verifi�
						�car se a Checagem sera Soft ou nao e para obter as Mensagens  �
						����������������������������������������������������������������/*/
						ApdChkDel(cAlias,nReg,nOpc,NIL,@lChkDelShwLog,NIL,NIL,NIL,.F.,.T.,NIL,NIL,@cTitLogDel,@cMsgLogDel,NIL,NIL,NIL,NIL)
						IF !( lChkDelShwLog )
							lChkDelSoft := .T.
						EndIF
						IF !( lChkDelOk := ApdChkDel(;
														cAlias								,;	//01 -> Alias de Dominio
														nReg								,;	//02 -> Registro do Dominio
														nOpc								,;	//03 -> Opcao para a AxDeleta
														NIL									,;	//04 -> Chave para Exclusao (Sem a Filial)
														.F.									,;	//05 -> Se deve Mostrar o Log
														@aLogAux							,;	//06 -> Array com os Logs
														@aLogTitAux							,;	//07 -> Array com os Titulos do Log
														{ "RD9" , "RDA" , "RDP" , "RDC" }	,;	//08 -> Array com os arquivos Alias que nao deverao ser verificados
														NIL									,;	//09 -> Verifica os Relacionamentos no SX9
														lChkDelSoft							,;	//10 -> Se faz uma checagem soft
														NIL 								,;	//11 -> Array contendo informacoes dos arquivos a serem pesquisados
														NIL           						,;	//12 -> Mensagem para MsgYesNo
														NIL        							,;	//13 -> Titulo do Log de Delecao
														NIL        							,;	//14 -> Mensagem para o corpo do Log
														NIL									,;	//15 -> Se executa AxDeleta
														NIL									,;	//16 -> Bloco para Posicionamento no Arquivo
														NIL									,;	//17 -> Bloco para a Condicao While
														NIL		 							 ;	//18 -> Bloco para Skip/Loop no While
													);
							)
							aAdd( aChkDelOk , lChkDelOk )
							IF !( lChkDelSoft )
								aAdd( aLogChkDel	, aClone( aLogAux ) )
								aLogAux		:= {}
								aAdd( aLogTitChkDel	, aLogTitAux[1] )
								aLogTitAux	:= {}
							EndIF
						EndIF
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar�
					� quivo														   �
					����������������������������������������������������������������/*/
					For nLoop := 1 To nUsado
						SetMemVar( __aRd6Header__[ nLoop , 02 ] , aCols[ 01 , nLoop ] , .T. )
					Next nLoop
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica o Status da Avaliacao                               �
					����������������������������������������������������������������/*/
					lRd6Status	:= ( GetMemVar( "RD6_STATUS" ) == "1" )
					/*/
					��������������������������������������������������������������Ŀ
					� Modifica a opcao de Alteracao das GetDados conforme Status   �
					����������������������������������������������������������������/*/
					nOpcNewGd	:= IF( !( lRd6Status ) , 0 , nOpcNewGd )
					/*/
					��������������������������������������������������������������Ŀ
					� Carregando campos Alteraveis e Editavies					   �
					����������������������������������������������������������������/*/
					MkArrEdFlds( nOpc , __aRd6Header__ , __aRd6Visual__ , __aRd6Virtual__ , @aNaoAltera , @aAltera , @aFields )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALSTCOLS	]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= __aRd6Virtual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= __aRd6Visual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aClone( aAltera		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aClone( aNaoAltera	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aClone( aNotFields	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= __aRd6Header__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= nUsado
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aClone( aRecnos		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AKEYS		]	:= aClone( aKeys		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aClone( aFields		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aClone( aGets		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aClone( aTela		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "E"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { | oObjValid | ( oObjValid:SetFocus() , .T. ) }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .T.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || .T. }
				EndIF
			Next nObj
		ElseIF ( nFolder == APDA270_FOLDER_AGENDA )
			nObjNumber		:= 3
			aFolders[ nFolder , APDA270_FOLDER_OBJ_TITLE	]	:= aTitles[ APDA270_FOLDER_AGENDA ]
			aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]	:= nObjNumber
	    	aFolders[ nFolder , APDA270_FOLDER_OBJECTS		]	:= Array( nObjNumber )
			aNotFields := { "RD6_FILIAL", "RD6_PERIOD", "RD6_INTMES", "RD6_INIGER", "RD6_INIRSP", "RD6_RSPADO", "RD6_RSPDOR", "RD6_RSPCON"}
	    	For nObj := 1 To nObjNumber
				/*/
				��������������������������������������������������������������Ŀ
				� Carrega Array com os Numeros de Elementos					   �
				����������������������������������������������������������������/*/
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj ]	:= Array( APDA270_OBJ_ELEMENTOS )

				/*/
				��������������������������������������������������������������Ŀ
				� Carrega Array com os Numeros de Elementos					   �
				����������������������������������������������������������������/*/

				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj ]	:= Array( APDA270_OBJ_ELEMENTOS )
				IF ( nObj == 1 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS ]	:= cAlias
					/*/
					��������������������������������������������������������������Ŀ
					� Reinicializa as Variaveis									   �
					����������������������������������������������������������������/*/
					aColsF2		    := {}
					aAlterF2		:= {}
					aNaoAltera		:= {}
					aRecnos			:= {}
					aFieldF2		:= {}
					aGets			:= {}
					aTela			:= {}
					bSkip			:= { || .F. }
					bKey			:= NIL
					cKey			:= "__cKey__"
					bGetRd6			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aKeys := NIL ),;
														aColsF2 := RD6->(;
																			GDBuildCols(	@__aRd6aHeader__,;	//01 -> Array com os Campos do Cabecalho da GetDados
																							@nUsado			,;	//02 -> Numero de Campos em Uso
																							@__aRd6aVirtual__,;	//03 -> [@]Array com os Campos Virtuais
																							@__aRd6aVisual__,;	//04 -> [@]Array com os Campos Visuais
																							cAlias			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																							aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																							@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																							cAlias		   	,;	//08 -> Alias do Arquivo Pai
																							NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																							NIL				,;	//10 -> Bloco para condicao de Loop While
																							NIL				,;	//11 -> Bloco para Skip no Loop While
																							NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols
																							NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																							NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																							NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																							NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																							NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																							NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																							.F.				,;	//19-> Carregar Coluna Fantasma
																						    .T.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																							.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
																							.T.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
																							NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																							@aKeys			,;	//24 -> [@]Array que contera as chaves conforme recnos
																							@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																							@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																							NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
																							NIL				,;	//28 -> Utiliza Numeracao na GhostCol
																							NIL				,;	//29 ->
																							NIL				,;	//30 ->
																							nOpc			 ;	//31 ->
																	    				);
														  				),;
										IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  					}
					/*/
					��������������������������������������������������������������Ŀ
					�Lock do Registro do RD6									   �
					����������������������������������������������������������������/*/
					IF !( lLocks := WhileNoLock( "RD6" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRd6 , !( lBldAvaAuto ) ) )
						cAliasNoLock := "RD6"
						Break
					EndIF
					MyCursorWait()
					/*/
					��������������������������������������������������������������Ŀ
					� Reposiciona no Registro para a Carga das Variaveis de Memoria�
					����������������������������������������������������������������/*/
					IF ( nReg > 0 )
						RD6->( MsGoto( nReg ) )
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica se Pode Haver Exclusao                       	   �
					����������������������������������������������������������������/*/
					IF ( Exclui )
						/*/
						��������������������������������������������������������������Ŀ
						�Esta primeira a Chamada a ApdChkDel() serve apenas para verifi�
						�car se a Checagem sera Soft ou nao e para obter as Mensagens  �
						����������������������������������������������������������������/*/
						ApdChkDel(cAlias,nReg,nOpc,NIL,@lChkDelShwLog,NIL,NIL,NIL,.F.,.T.,NIL,NIL,@cTitLogDel,@cMsgLogDel,NIL,NIL,NIL,NIL)
						IF !( lChkDelShwLog )
							lChkDelSoft := .T.
						EndIF
						IF !( lChkDelOk := ApdChkDel(;
														cAlias								,;	//01 -> Alias de Dominio
														nReg								,;	//02 -> Registro do Dominio
														nOpc								,;	//03 -> Opcao para a AxDeleta
														NIL									,;	//04 -> Chave para Exclusao (Sem a Filial)
														.F.									,;	//05 -> Se deve Mostrar o Log
														@aLogAux							,;	//06 -> Array com os Logs
														@aLogTitAux							,;	//07 -> Array com os Titulos do Log
														{ "RD9" , "RDA" , "RDP" , "RDC" }	,;	//08 -> Array com os arquivos Alias que nao deverao ser verificados
														NIL									,;	//09 -> Verifica os Relacionamentos no SX9
														lChkDelSoft							,;	//10 -> Se faz uma checagem soft
														NIL 								,;	//11 -> Array contendo informacoes dos arquivos a serem pesquisados
														NIL           						,;	//12 -> Mensagem para MsgYesNo
														NIL        							,;	//13 -> Titulo do Log de Delecao
														NIL        							,;	//14 -> Mensagem para o corpo do Log
														NIL									,;	//15 -> Se executa AxDeleta
														NIL									,;	//16 -> Bloco para Posicionamento no Arquivo
														NIL									,;	//17 -> Bloco para a Condicao While
														NIL		 							 ;	//18 -> Bloco para Skip/Loop no While
													);
							)
							aAdd( aChkDelOk , lChkDelOk )
							IF !( lChkDelSoft )
								aAdd( aLogChkDel	, aClone( aLogAux ) )
								aLogAux		:= {}
								aAdd( aLogTitChkDel	, aLogTitAux[1] )
								aLogTitAux	:= {}
							EndIF
						EndIF
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar�
					� quivo														   �
					����������������������������������������������������������������/*/
					For nLoop := 1 To nUsado
						SetMemVar( __aRd6aHeader__[ nLoop , 02 ] , aColsF2[ 01 , nLoop ] , .T. )
					Next nLoop
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica o Status da Avaliacao                               �
					����������������������������������������������������������������/*/
					lRd6Status	:= ( GetMemVar( "RD6_STATUS" ) == "1" )
					/*/
					��������������������������������������������������������������Ŀ
					� Modifica a opcao de Alteracao das GetDados conforme Status   �
					����������������������������������������������������������������/*/
					nOpcNewGd	:= IF( !( lRd6Status ) , 0 , nOpcNewGd )
					/*/
					��������������������������������������������������������������Ŀ
					� Carregando campos Alteraveis e Editavies					   �
					����������������������������������������������������������������/*/
					MkArrEdFlds( nOpc , __aRd6aHeader__ , __aRd6aVisual__ , __aRd6aVirtual__ , @aNaoAltera , @aAlterF2 , @aFieldF2 )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= aClone( aColsF2 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= aClone( aColsF2 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALSTCOLS	]	:= aClone( aColsF2 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= __aRd6aVirtual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= __aRd6aVisual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aClone( aAlterF2		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aClone( aNaoAltera	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aClone( aNotFields	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= __aRd6aHeader__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= nUsado
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aClone( aRecnos		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AKEYS		]	:= aClone( aKeys		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aClone( aFieldF2		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aClone( aGets		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aClone( aTela		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "E"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { | oObjValid | ( oObjValid:SetFocus() , .T. ) }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .F.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || MyCursorWait() , Rd6bExit( @aFolders ) , MyCursorArrow() , .T. }

				ElseIF ( nObj == 2 )

					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS	]	:= ""
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= 0
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "B"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { || .T. }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .F.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || .T. }

				ElseIF ( nObj == 3 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS ]	:= "RDP"
					/*/
					��������������������������������������������������������������Ŀ
					� Reinicializa as Variaveis									   �
					����������������������������������������������������������������/*/
					aCols		    := {}
					aAltera			:= {}
					IF !( Inclui )
						aNaoAltera	:= {}
					Else
						aNaoAltera	:= {}
					EndIF
					aNotFields		:= { "RDP_FILIAL" }
					aRecnos			:= {}
					aKeys			:= {}
					aFields			:= {}
					IF !( lBldAvaAuto )
						aFieldsAux		:= { { "COLBMP" , "APDA270Leg( aMarksCollor , 1 , NIL , " + Str( APDA270_FOLDER_AGENDA ) + " ) " } }
					EndIF
					aGets			:= {}
					aTela			:= {}
					bSkip			:= { || .F. }
					bKey			:= NIL
					cKey			:= ( xFilial( "RDP" ) + GetMemVar( "RD6_CODIGO" ) )

					aRdpQuery		:= Array( 05 )
					aRdpQuery[01]	:= "RDP_FILIAL='"+ xFilial( "RDP" ) +"'"
					aRdpQuery[02]	:= " AND "
					aRdpQuery[03]	:= "RDP_CODAVA='"+ GetMemVar( "RD6_CODIGO" ) +"'"
					aRdpQuery[04]	:= " AND "
					aRdpQuery[05]	:= "D_E_L_E_T_=' ' "

					bGetRdp			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aKeys := NIL ),;
															aCols := RDP->(;
																			GDBuildCols(	@__aRdpHeader__	,;	//01 -> Array com os Campos do Cabecalho da GetDados
																							@nUsado			,;	//02 -> Numero de Campos em Uso
																							@__aRdpVirtual__,;	//03 -> [@]Array com os Campos Virtuais
																							@__aRdpVisual__ ,;	//04 -> [@]Array com os Campos Visuais
																							"RDP"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																							aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																							@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																							"RDP"		   	,;	//08 -> Alias do Arquivo Pai
																							cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
																							NIL				,;	//10 -> Bloco para condicao de Loop While
																							NIL				,;	//11 -> Bloco para Skip no Loop While
																							NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols
																							NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																							NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																							NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																							aRdpQuery		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																							NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																							NIL				,;	//18-> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																							aFieldsAux		,;	//19-> Carregar Coluna Fantasma
																							NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																							NIL				,;	//21 -> Verifica se Deve Checar se o campo eh usado
																							NIL				,;	//22 -> Verifica se Deve Checar o nivel do usuario
																							NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																							@aKeys			,;	//24 -> [@]Array que contera as chaves conforme recnos
																							@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																							@lExclu    		,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																							1				,;	//27 -> Numero maximo de Locks a ser efetuado
																							.F.				,;	//28 -> Utiliza Numeracao na GhostCol
																							NIL				,;	//29 ->
																							NIL				,;	//30 ->
																							nOpc			 ;	//31 ->
																    					);
													  					),;
														IF( lExecLock , ( lLock .and. lExclu ) , .T. );
	  					}
					/*/
					��������������������������������������������������������������Ŀ
					�Lock do Registro do RDP									   �
					����������������������������������������������������������������/*/
					IF !( lLocks := WhileNoLock( "RDP" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRdp , !( lBldAvaAuto ) ) )
						cAliasNoLock := "RDP"
						Break
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica se Pode Haver Exclusao                       	   �
					����������������������������������������������������������������/*/
					IF (;
							( Exclui );
							.and.;
							(;
								( lChkDelOk );
								.or.;
								!( lChkDelSoft );
							);
						)
						nLoops := Len( aRecnos )
						For nLoop := 1 To nLoops
							IF !( lChkDelOk := ApdChkDel(;
															"RDP" 						,;	//01 -> Alias de Dominio
															aRecnos[ nLoop ]			,;	//02 -> Registro do Dominio
															nOpc						,;	//03 -> Opcao para a AxDeleta
															NIL							,;	//04 -> Chave para Exclusao (Sem a Filial)
															.F.							,;	//05 -> Se deve Mostrar o Log
															@aLogAux					,;	//06 -> Array com os Logs
															@aLogTitAux					,;	//07 -> Array com os Titulos do Log
															{ "RD9" , "RDA" , "RDC" }	,;	//08 -> Array com os arquivos Alias que nao deverao ser verificados
															NIL							,;	//09 -> Verifica os Relacionamentos no SX9
															lChkDelSoft					,;	//10 -> Se faz uma checagem soft
															NIL 						,;	//11 -> Array contendo informacoes dos arquivos a serem pesquisados
															NIL          				,;	//12 -> Mensagem para MsgYesNo
															NIL        					,;	//13 -> Titulo do Log de Delecao
															NIL        					,;	//14 -> Mensagem para o corpo do Log
															NIL							,;	//15 -> Se executa AxDeleta
															NIL							,;	//16 -> Bloco para Posicionamento no Arquivo
															NIL							,;	//17 -> Bloco para a Condicao While
															NIL		 					 ;	//18 -> Bloco para Skip/Loop no While
														);
								)
								IF ( lChkDelSoft )
									Exit
								Else
									aAdd( aChkDelOk , lChkDelOk )
									aAdd( aLogChkDel , aClone( aLogAux ) )
									aLogAux		:= {}
									aAdd( aLogTitChkDel	, aLogTitAux[1] )
									aLogTitAux	:= {}
								EndIF
							EndIF
						Next nLoop
						aLogAux		:= {}
						aLogTitAux	:= {}
					EndIF
					MyCursorWait()
					/*/
					��������������������������������������������������������������Ŀ
					� Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar�
					� quivo														   �
					����������������������������������������������������������������/*/
					For nLoop := 1 To nUsado
						SetMemVar( __aRdpHeader__[ nLoop , 02 ] , aCols[ 01 , nLoop ] , .T. )
					Next nLoop
					/*/
					��������������������������������������������������������������Ŀ
					� Carregando campos Alteraveis e Editavies					   �
					����������������������������������������������������������������/*/
					MkArrEdFlds( nOpc , __aRdpHeader__ , __aRdpVisual__ , __aRdpVirtual__ , @aNaoAltera , @aAltera , @aFields )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALSTCOLS	]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= __aRdpVirtual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= __aRdpVisual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aClone( aAltera		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aClone( aNaoAltera	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aClone( aNotFields	)
					nRdpGhostCol	:= GdFieldPos( "RDP_REC_WT" , __aRdpHeader__ )

					IF ( nRdpGhostCol > 0 )
						//cRdpNumGhostCol	:= aCols[ Len( aCols ) , nRdpGhostCol ]
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BSORT	]	:= { |x,y| ( x[ nRdpGhostCol ] < y[ nRdpGhostCol ] ) }
					EndIF

					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= __aRdpHeader__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= nUsado
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aClone( aRecnos		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AKEYS		]	:= aClone( aKeys		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aClone( aFields		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aClone( aGets		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aClone( aTela		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "G"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { | oObjValid | ( MyCursorWait() , oObjValid:oBrowse:SetFocus() , MyCursorArrow() , .T. ) }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .T.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { | oGdRdp | MyCursorWait() , RdpChkChange( oGdRdp , .T. ) , Rd6bExit( @aFolders ) , MyCursorArrow() , .T. }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BDELEMPTY	]	:= GdGetBlock( "RDP" , __aRdpHeader__ )
				EndIF
			Next nObj
		ElseIF ( nFolder == APDA270_FOLDER_AVALIADOS	)
			nObjNumber		:= 2
			aFolders[ nFolder , APDA270_FOLDER_OBJ_TITLE	]	:= aTitles[ APDA270_FOLDER_AVALIADOS ]
			aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]	:= nObjNumber
	    	aFolders[ nFolder , APDA270_FOLDER_OBJECTS		]	:= Array( nObjNumber )

	    	For nObj := 1 To nObjNumber
				/*/
				��������������������������������������������������������������Ŀ
				� Carrega Array com os Numeros de Elementos					   �
				����������������������������������������������������������������/*/
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj ]	:= Array( APDA270_OBJ_ELEMENTOS )
				IF ( nObj == 1 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS	]	:= ""
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= 0
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "B"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { || MyCursorWait() , Rd9RdaBtnED() , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .F.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || .T. }
				ElseIF ( nObj == 2 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS		]	:= "RD9"
					/*/
					��������������������������������������������������������������Ŀ
					� Reinicializa as Variaveis									   �
					����������������������������������������������������������������/*/
					aCols		    := {}
					aAltera			:= {}
					aNaoAltera		:= {"RD9_CODAVA"}
					aNotFields		:= {"RD9_FILIAL"}
					aRecnos			:= {}
					aFields			:= {}
					IF !( lBldAvaAuto )
						aFieldsAux		:= { { "COLBMP" , "APDA270Leg( aMarksCollor , 1  )" } }
					EndIF
					aGets			:= {}
					aTela			:= {}
					bSkip			:= { || .F. }
					bKey			:= NIL
					cKey			:= ( xFilial( "RD9" ) + GetMemVar( "RD6_CODIGO" ) )

					aRd9Query		:= Array( 05 )
					aRd9Query[01]	:= "RD9_FILIAL='"+ xFilial( "RD9" ) +"'"
					aRd9Query[02]	:= " AND "
					aRd9Query[03]	:= "RD9_CODAVA='"+ GetMemVar( "RD6_CODIGO" ) +"'"
					aRd9Query[04]	:= " AND "
					aRd9Query[05]	:= "D_E_L_E_T_=' ' "

					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes   									   �
					����������������������������������������������������������������/*/
					aCols := GDBuildCols(	@__aRd9Header__	,;	//01 -> Array com os Campos do Cabecalho da GetDados
											@nUsado			,;	//02 -> Numero de Campos em Uso
											@__aRd9Virtual__,;	//03 -> [@]Array com os Campos Virtuais
											@__aRd9Visual__	,;	//04 -> [@]Array com os Campos Visuais
											"RD9"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
											@aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
											@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
											"RD9"			,;	//08 -> Alias do Arquivo Pai
											cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
											NIL				,;	//10 -> Bloco para condicao de Loop While
											NIL				,;	//11 -> Bloco para Skip no Loop While
											.T.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
											.T.				,;	//13 -> Se Sera considerado o Inicializador Padrao
											.F.				,;	//14 -> Opcional, Carregar Todos os Campos
											.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
											aRd9Query		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
											.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
											.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
											aFieldsAux		,;	//19 -> Carregar Coluna Fantasma
											.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
											.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
											.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
											.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
											NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
											NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
											NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
											NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
											.F.				,;	//28 -> Utiliza Numeracao na GhostCol
											NIL				,;	//29 ->
											NIL				,;	//30 ->
											nOpc			;	//31 ->
										 )
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica se Pode Haver Exclusao                       	   �
					����������������������������������������������������������������/*/
					IF (;
							( Exclui );
							.and.;
							(;
								( lChkDelOk );
								.or.;
								!( lChkDelSoft );
							);
						)
						nLoops := Len( aRecnos )
						For nLoop := 1 To nLoops
							IF !( lChkDelOk := ApdChkDel(;
															"RD9" 				,;	//01 -> Alias de Dominio
															aRecnos[ nLoop ]	,;	//02 -> Registro do Dominio
															nOpc				,;	//03 -> Opcao para a AxDeleta
															NIL					,;	//04 -> Chave para Exclusao (Sem a Filial)
															.F.					,;	//05 -> Se deve Mostrar o Log
															@aLogAux			,;	//06 -> Array com os Logs
															@aLogTitAux			,;	//07 -> Array com os Titulos do Log
															{ "RDA" , "RDC" }	,;	//08 -> Array com os arquivos Alias que nao deverao ser verificados
															NIL					,;	//09 -> Verifica os Relacionamentos no SX9
															lChkDelSoft			,;	//10 -> Se faz uma checagem soft
															NIL 				,;	//11 -> Array contendo informacoes dos arquivos a serem pesquisados
															NIL          		,;	//12 -> Mensagem para MsgYesNo
															NIL        			,;	//13 -> Titulo do Log de Delecao
															NIL         		,;	//14 -> Mensagem para o corpo do Log
															NIL					,;	//15 -> Se executa AxDeleta
															NIL					,;	//16 -> Bloco para Posicionamento no Arquivo
															NIL					,;	//17 -> Bloco para a Condicao While
															NIL		 			 ;	//18 -> Bloco para Skip/Loop no While
														);
								)
								IF ( lChkDelSoft )
									Exit
								Else
									aAdd( aChkDelOk , lChkDelOk )
									aAdd( aLogChkDel , aClone( aLogAux ) )
									aLogAux		:= {}
									aAdd( aLogTitChkDel	, aLogTitAux[1] )
									aLogTitAux	:= {}
								EndIF
							EndIF
						Next nLoop
						aLogAux		:= {}
						aLogTitAux	:= {}
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega os Campos Editaveis para a GetDados				   �
					����������������������������������������������������������������/*/
					For nLoop := 1	To nUsado
						SetMemVar( __aRd9Header__[ nLoop , 02 ] , GetValType( __aRd9Header__[ nLoop , 08 ] , __aRd9Header__[ nLoop , 04 ] ) , .T. )
					Next nLoop
					/*/
					��������������������������������������������������������������Ŀ
					� Carregando campos Alteraveis e Editavies					   �
					����������������������������������������������������������������/*/
					MkArrEdFlds( nOpc , __aRd9Header__ , __aRd9Visual__ , __aRd9Virtual__ , @aNaoAltera , @aAltera , @aFields )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= __aRd9Virtual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= __aRd9Visual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aClone( aAltera		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aClone( aNaoAltera	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aClone( aNotFields	)
					nRd9GhostCol	:= GdFieldPos( "RD9_REC_WT" , __aRd9Header__ )
					IF ( nRd9GhostCol > 0 )
						//cRd9NumGhostCol	:= aCols[ Len( aCols ) , nRd9GhostCol ]
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BSORT	]	:= { |x,y| ( x[ nRd9GhostCol ] < y[ nRd9GhostCol ] ) }
					EndIF
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= __aRd9Header__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= nUsado
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aClone( aRecnos		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aClone( aFields		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aClone( aGets		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aClone( aTela		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "G"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { | oGdRd9 | MyCursorWait() , GdRd9Init( oGdRd9 ) , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .T.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { | oGdRd9 | MyCursorWait() , Rd9bExit( oGdRd9 ) , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BDELEMPTY	]	:= GdGetBlock( "RD9" , __aRd9Header__ )
				EndIF
			Next nObj
		ElseIF ( nFolder == APDA270_FOLDER_AVALIADORES	)
			nObjNumber		:= 4
			aFolders[ nFolder , APDA270_FOLDER_OBJ_TITLE	]	:= aTitles[ APDA270_FOLDER_AVALIADORES	]
			aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]	:= nObjNumber
	    	aFolders[ nFolder , APDA270_FOLDER_OBJECTS		]	:= Array( nObjNumber )
			/*/
			��������������������������������������������������������������Ŀ
			� Monta as Dimensoes dos Objetos         					   �
			����������������������������������������������������������������/*/
	    	For nObj := 1 To nObjNumber
				/*/
				��������������������������������������������������������������Ŀ
				� Carrega Array com os Numeros de Elementos					   �
				����������������������������������������������������������������/*/
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj ]	:= Array( APDA270_OBJ_ELEMENTOS )
				IF ( nObj == 1 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS		]	:= "RD9"
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_AVIRTUAL	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_AVISUAL	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_AALTERA	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_ANAOALTERA	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_ANOTFIELDS	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_AHEADER	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_NUSADO		]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_ARECNOS	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_AFIELDS	]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_AGETS		]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_ATELA		]
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "G"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { || MyCursorWait() , GdRdpRd9Chg( .T. , .F. ) , GdRdhRdaInit( oGdRd9Get( APDA270_FOLDER_AVALIADORES ) , .T., NIL, NIL, NIL, nOpc) , GdRdpRd9Chg( .T. , .F. , APDA270_FOLDER_AVALIADORES ) , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .F.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || .T. }
				ElseIF ( nObj == 2 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS		]	:= "RDH"
					/*/
					��������������������������������������������������������������Ŀ
					� Reinicializa as Variaveis									   �
					����������������������������������������������������������������/*/
					aCols		    := {}
					aAltera			:= {}
					aNaoAltera		:= {}
					aNotFields		:= {"RDH_FILIAL","RDH_CODTIP"}
					aRecnos			:= {}
					aFields			:= {}
					aGets			:= {}
					aTela			:= {}
					bSkip			:= { || .F. }
					bKey			:= NIL
					cKey			:= "__cKey__"
					/*/
					��������������������������������������������������������������Ŀ
					�Posiciona No Final do Arquivo Apenas para Carregar a Estutura �
					����������������������������������������������������������������/*/
					PutFileInEof( "RDH" )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes   									   �
					����������������������������������������������������������������/*/
					aCols := GDBuildCols(	@__aRdhHeader__	,;	//01 -> Array com os Campos do Cabecalho da GetDados
											@nUsado			,;	//02 -> Numero de Campos em Uso
											@__aRdhVirtual__,;	//03 -> [@]Array com os Campos Virtuais
											@__aRdhVisual__	,;	//04 -> [@]Array com os Campos Visuais
											"RDH"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
											@aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
											@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
											"RDH"			,;	//08 -> Alias do Arquivo Pai
											cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
											NIL				,;	//10 -> Bloco para condicao de Loop While
											NIL				,;	//11 -> Bloco para Skip no Loop While
											.T.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
											.F.				,;	//13 -> Se Sera considerado o Inicializador Padrao
											.F.				,;	//14 -> Opcional, Carregar Todos os Campos
											.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
											NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
											.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
											.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
											.F.				,;	//19 -> Carregar Coluna Fantasma
											.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
											.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
											.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
											.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
											NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
											NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
											NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
											NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
											NIL				,;	//28 -> Utiliza Numeracao na GhostCol
											NIL				,;	//29 ->
											NIL				,;	//30 ->
											nOpc			;	//31 ->
										 )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega os Campos Editaveis para a GetDados				   �
					����������������������������������������������������������������/*/
					For nLoop := 1	To nUsado
						SetMemVar( __aRdhHeader__[ nLoop , 02 ] , GetValType( __aRdhHeader__[ nLoop , 08 ] , __aRdhHeader__[ nLoop , 04 ] ) , .T. )
					Next nLoop
					/*/
					��������������������������������������������������������������Ŀ
					� Carregando campos Alteraveis e Editavies					   �
					����������������������������������������������������������������/*/
					MkArrEdFlds( nOpc , __aRdhHeader__ , __aRdhVisual__ , __aRdhVirtual__ , @aNaoAltera , @aAltera , @aFields )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= __aRdhVirtual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= __aRdhVisual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aClone( aAltera		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aClone( aNaoAltera	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aClone( aNotFields	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= __aRdhHeader__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= nUsado
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aClone( aRecnos		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aClone( aFields		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aClone( aGets		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aClone( aTela		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "G"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= { | cTipo , oGdRede | GdRdhRdaInit( oGdRede , .F. , .F., NIL, NIL, nOpc) , .T. }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { | oGdRede | MyCursorWait() , GdRdhRdaInit( oGdRede , .F., NIL, NIL, NIL, nOpc ) , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .F.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || .T. }
				ElseIF ( nObj == 3 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS		]	:= ""
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= 0
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= {}
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "B"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { || .T. }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .F.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || .T. }
				ElseIF ( nObj == 4 )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS		]	:= "RDA"
					/*/
					��������������������������������������������������������������Ŀ
					� Reinicializa as Variaveis									   �
					����������������������������������������������������������������/*/
					aCols		    := {}
					aAltera			:= {}
					aNaoAltera		:= { "RDA_CODAVA" , "RDA_CODADO" , "RDA_DTIAVA" , "RDA_DTFAVA" , "RDA_CODTIP" , "RDA_CODNET" , "RDA_NIVEL" }
					aNotFields		:= { "RDA_FILIAL" }
					aRecnos			:= {}
					aFields			:= {}
					IF !( lBldAvaAuto )
						aFieldsAux		:= { { "COLBMP" , "APDA270Leg( aMarksCollor , 2 )" } }
					EndIF
					aGets			:= {}
					aTela			:= {}
					bSkip			:= { || .F. }
					bKey			:= NIL
					cKey			:= ( xFilial( "RDA" ) + GetMemVar( "RD6_CODIGO" ) )

					aRdaQuery		:= Array( 05 )
					aRdaQuery[01]	:= "RDA_FILIAL='"+ xFilial( "RDA" ) +"'"
					aRdaQuery[02]	:= " AND "
					aRdaQuery[03]	:= "RDA_CODAVA='"+ GetMemVar( "RD6_CODIGO" ) +"'"
					aRdaQuery[04]	:= " AND "
					aRdaQuery[05]	:= "D_E_L_E_T_=' ' "

					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes   									   �
					����������������������������������������������������������������/*/
					aCols := GDBuildCols(	@__aRdaHeader__	,;	//01 -> Array com os Campos do Cabecalho da GetDados
											@nUsado			,;	//02 -> Numero de Campos em Uso
											@__aRdaVirtual__,;	//03 -> [@]Array com os Campos Virtuais
											@__aRdaVisual__	,;	//04 -> [@]Array com os Campos Visuais
											"RDA"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
											@aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
											@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
											"RDA"			,;	//08 -> Alias do Arquivo Pai
											cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
											NIL				,;	//10 -> Bloco para condicao de Loop While
											NIL				,;	//11 -> Bloco para Skip no Loop While
											.T.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
											.T.				,;	//13 -> Se Sera considerado o Inicializador Padrao
											.F.				,;	//14 -> Opcional, Carregar Todos os Campos
											.F.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
											aRdaQuery		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
											.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
											.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
											aFieldsAux		,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
											.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
											.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
											.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
											.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
											NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
											NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
											NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
											NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
											.F.				,;	//28 -> Utiliza Numeracao na GhostCol
											NIL				,;	//29 ->
											NIL				,;	//30 ->
											nOpc			;	//31 ->
										 )
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica se Pode Haver Exclusao                       	   �
					����������������������������������������������������������������/*/
					/*/
					��������������������������������������������������������������Ŀ
					� Verifica se Pode Haver Exclusao                       	   �
					����������������������������������������������������������������/*/
					IF (;
							( Exclui );
							.and.;
							(;
								( lChkDelOk );
								.or.;
								!( lChkDelSoft );
							);
						)
						nLoops := Len( aRecnos )
						For nLoop := 1 To nLoops
							IF !( lChkDelOk := ApdChkDel(;
															"RDA" 				,;	//01 -> Alias de Dominio
															aRecnos[ nLoop ]	,;	//02 -> Registro do Dominio
															nOpc				,;	//03 -> Opcao para a AxDeleta
															NIL					,;	//04 -> Chave para Exclusao (Sem a Filial)
															.F.					,;	//05 -> Se deve Mostrar o Log
															@aLogAux			,;	//06 -> Array com os Logs
															@aLogTitAux			,;	//07 -> Array com os Titulos do Log
															{ "RDC" }			,;	//08 -> Array com os arquivos Alias que nao deverao ser verificados
															NIL					,;	//09 -> Verifica os Relacionamentos no SX9
															lChkDelSoft			,;	//10 -> Se faz uma checagem soft
															NIL 				,;	//11 -> Array contendo informacoes dos arquivos a serem pesquisados
															NIL          		,;	//12 -> Mensagem para MsgYesNo
															NIL        			,;	//13 -> Titulo do Log de Delecao
															NIL        			,;	//14 -> Mensagem para o corpo do Log
															NIL					,;	//15 -> Se executa AxDeleta
															NIL					,;	//16 -> Bloco para Posicionamento no Arquivo
															NIL					,;	//17 -> Bloco para a Condicao While
															NIL		 			 ;	//18 -> Bloco para Skip/Loop no While
														);
								)
								IF ( lChkDelSoft )
									Exit
								Else
									aAdd( aChkDelOk , lChkDelOk )
									aAdd( aLogChkDel , aClone( aLogAux ) )
									aLogAux		:= {}
									aAdd( aLogTitChkDel	, aLogTitAux[1] )
									aLogTitAux	:= {}
								EndIF
							EndIF
						Next nLoop
						aLogAux		:= {}
						aLogTitAux	:= {}
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega os Campos Editaveis para a GetDados				   �
					����������������������������������������������������������������/*/
					For nLoop := 1	To nUsado
						SetMemVar( __aRdaHeader__[ nLoop , 02 ] , GetValType( __aRdaHeader__[ nLoop , 08 ] , __aRdaHeader__[ nLoop , 04 ] ) , .T. )
					Next nLoop
					/*/
					��������������������������������������������������������������Ŀ
					� Carregando campos Alteraveis e Editavies					   �
					����������������������������������������������������������������/*/
					MkArrEdFlds( nOpc , __aRdaHeader__ , __aRdaVisual__ , __aRdaVirtual__ , @aNaoAltera , @aAltera , @aFields )
					/*/
					��������������������������������������������������������������Ŀ
					� Carrega as Informacoes no aFolders						   �
					����������������������������������������������������������������/*/
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS		]	:= aClone( aCols )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS		]	:= aClone( aCols )

					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVIRTUAL	]	:= __aRdaVirtual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AVISUAL		]	:= __aRdaVisual__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA		]	:= aClone( aAltera		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANAOALTERA	]	:= aClone( aNaoAltera	)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ANOTFIELDS	]	:= aClone( aNotFields	)
					nRdaGhostCol := GdFieldPos( "RDA_REC_WT" , __aRdaHeader__ )
					IF ( nRdaGhostCol > 0 )
						//cRdaNumGhostCol	:= aCols[ Len( aCols ) , nRdaGhostCol ]
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BSORT	]	:= { |x,y| ( x[ nRdaGhostCol ] < y[ nRdaGhostCol ] ) }
					EndIF
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER		]	:= __aRdaHeader__
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_NUSADO		]	:= nUsado
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS		]	:= aClone( aRecnos		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS		]	:= aClone( aFields		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AGETS		]	:= aClone( aGets		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ATELA		]	:= aClone( aTela		)
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ			]	:= NIL
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	]	:= "G"
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		]	:= bObjValid
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		]	:= { | oGdRda | MyCursorWait() , GdRdaInit( oGdRda ) , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA		]	:= .T.
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT		]	:= { || MyCursorWait() , Rd9Rdh2RdaChg( NIL , .T. ) , MyCursorArrow() }
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BDELEMPTY	]	:= GdGetBlock( "RDA" , __aRdaHeader__ )
				EndIF
			Next nObj
	    EndIF
	Next nFolder

	/*/
	��������������������������������������������������������������Ŀ
	� Retorna o Conteudo de cAlias                          	   �
	����������������������������������������������������������������/*/
	cAlias := "RD6"

	/*/
	��������������������������������������������������������������Ŀ
	� Verifica Se ocorreram Inconsistencia na Exclusao da Avaliacao�
	����������������������������������������������������������������/*/
	lChkDelOk := .T.
	IF (;
			( Exclui );
			.and.;
			!( lChkDelOk := ( aScan( aChkDelOk , { |x| !( x ) } ) == 0 ) );
		)
		Break
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Lock dos Registros                                    	   �
	����������������������������������������������������������������/*/
	IF !( lLocks := APDA270Locks( nOpc , aFolders ) )
		Break
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Quanto nao for Montagem Automatica     					   �
	����������������������������������������������������������������/*/
	IF ( lBldAvaAuto )
		IF ( Apda80BldAuto( dPerIni , dPerFim , .F., nOpc) )
			nOpcAlt := 1
		EndIf

		Break
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Define o Bloco para a Tecla <CTRL-O> da EnchoiceBar   	   �
	����������������������������������������������������������������/*/
	bSet15		:= { || IF(;
								(;
									MyCursorWait(),;
									GdRdpRd9Chg( .T. , .F. ,, .T. ) ,;
									GdRdhRdaInit( oGdRd9Get( APDA270_FOLDER_AVALIADORES ) , .T., NIL, NIL, NIL, nOpc) ,;
									GdRdpRd9Chg( .T. , .F. , APDA270_FOLDER_AVALIADORES ),;
									Rd9Rdh2RdaChg(,,.T.),;
									Rd9RdhGotFocus(),;
									APDA270TudoOk( nOpc );
								),;
								(;
									MyCursorWait(),;
									nOpcAlt := 1,;
									RestKeys( aSvKeys , .T. ),;
									oDlg:End();
								),;
								nOpcAlt := 0;
							);
					}
	/*/
	��������������������������������������������������������������Ŀ
	� Define o Bloco para a Teclas <CTRL-X> da EnchoiceBar   	   �
	����������������������������������������������������������������/*/
	bSet24		:= { || RestKeys( aSvKeys , .T. ) , oDlg:End() }

	/*/
	��������������������������������������������������������������Ŀ
	� Define o Bloco para o Init do Dialog                   	   �
	����������������������������������������������������������������/*/
	bDialogInit	:= { ||;
							APDA270SetOption( nOpc , 1 , 1 , .F. , .F. , @lGdSeek , @nActFolder ),;
							EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
		 	 				SetKey( VK_F4 , bTreeAloca	),;
				 	 		SetKey( VK_F5 , bAPDA270GdSeek ),;
				 	 		SetKey( VK_F6 , bCalend),;
				 	 		SetKey( VK_F7 , bBuildAva),;
				 	 		SetKey( VK_F8 , bAPDA270Leg ),;
				 	 		SetKey( VK_F10, bCalcAva);
					}

	/*/
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������/*/
	aObjCoords := {}
	aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

	aAdvSize		:= MsAdvSize(.f.)

	aInfo1AdvSize	:= { 5 , aObjSize[1,1]+20 , aAdvSize[3]-5 , aAdvSize[4]-15 , 5 , 5 }
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aObj1Size 		:= MsObjSize( aInfo1AdvSize , aObj1Coords ) // Abas Principal e Agenda

	aAdd( aObj2Coords , { 000 , 012 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
	aObj2Size 		:= MsObjSize( aInfo1AdvSize , aObj2Coords ) // Aba Avaliados

	aAdd( aObj3Coords , { 000 , 080 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )
	aObj3Size 		:= MsObjSize( aInfo1AdvSize , aObj3Coords ) // Aba Avaliadores

	aAdv4Size    := aClone(aObj3Size[2])
	aInfo4AdvSize    := { aAdv4Size[2] , aAdv4Size[1] , aAdv4Size[4] , aAdv4Size[3] , 0 , 0 }
	aAdd( aObj4Coords , { 030 , 000 , .T. , .T. } )
	aAdd( aObj4Coords , { 005 , 000 , .F. , .T. } )
	aAdd( aObj4Coords , { 070 , 000 , .T. , .T. } )
	aObj4Size := MsObjSize( aInfo4AdvSize , aObj4Coords, .T., .T. )

	aAdv5Size    := aClone(aObj4Size[3])
	aInfo5AdvSize    := { aAdv5Size[2] , aAdv5Size[1] , aAdv5Size[4] , aAdv5Size[3] , 0 , 0 }
	aAdd( aObj5Coords , { 000 , 017 , .T. , .F. } )
	aAdd( aObj5Coords , { 000 , 000 , .T. , .T. } )
	aObj5Size := MsObjSize( aInfo5AdvSize , aObj5Coords )

	aAdd( aObj6Coords , { 050 , 000 , .T. , .T. } )
	aAdd( aObj6Coords , { 001 , 000 , .F. , .T. } )
	aAdd( aObj6Coords , { 050 , 000 , .T. , .T. } )
	aObj6Size 		:= MsObjSize( aInfo1AdvSize , aObj6Coords, .T., .T. ) // Aba Envio/Retorno

	aAdd( aObj7Coords , { 100 , 020 , .T. , .T. } )
	aAdd( aObj7Coords , { 100 , 080 , .T. , .T. } )
	aObj7Size 		:= MsObjSize( aInfo1AdvSize , aObj7Coords, .T., .F. ) // Aba Agendas

	aAdv8Size    := aClone(aObj7Size[2])
	aInfo8AdvSize    := { aAdv8Size[2] , aAdv8Size[1] , aAdv8Size[4] , aAdv8Size[3] , 0 , 0 }
	aAdd( aObj8Coords , { 100 , 010 , .T. , .T. } )
	aAdd( aObj8Coords , { 100 , 090 , .T. , .T. } )
	aObj8Size := MsObjSize( aInfo8AdvSize , aObj8Coords, .T., .F. )

	/*/
	��������������������������������������������������������������Ŀ
	� Monta o Dialogo Principal para a Manutencao das Formulas	   �
	����������������������������������������������������������������/*/
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

		/*/
		��������������������������������������������������������������Ŀ
		� Cria o Folder Com Todas as Opcoes      					   �
		����������������������������������������������������������������/*/
		oFolders := TFolder():New(	aObjSize[ 1 , 1 ]	,;
									aObjSize[ 1 , 2 ]	,;
									aTitles				,;
									aPages				,;
									oDlg				,;
									NIL					,;
									NIL					,;
									NIL					,;
									.T.					,;
									.F.					,;
									aObjSize[ 1 , 3 ]	,;
									aObjSize[ 1 , 4 ]	 ;
								 )
		oFolders:bSetOption := { |nNewFolder| APDA270SetOption( nOpc , nNewFolder , oFolders:nOption , .T. , .F. , @lGdSeek , @nActFolder ) }

		/*/
		��������������������������������������������������������������Ŀ
		� Monta o Array aFolders Com Todos os Objetos				   �
		����������������������������������������������������������������/*/
		For nFolder := 1 To nFolders
			IF ( nFolder == APDA270_FOLDER_PRINCIPAL )
				nObjNumber	:= aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		    	For nObj := 1 To nObjNumber
					IF ( nObj == 1 )
						cAlias	:= aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS ]
						aCols	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS	] )
						aAltera	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA	] )
						aFields	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS	] )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]	:= MsmGet():New( cAlias , nReg , nOpc , NIL , NIL , NIL , aFields , aObj1Size[1] , aAltera , NIL , NIL , NIL , oFolders:aDialogs[ APDA270_FOLDER_PRINCIPAL ] , NIL , .F. , NIL , .F.)
					EndIF
				Next nObj
			ElseIF ( nFolder == APDA270_FOLDER_AGENDA )
	    		For nObj := 1 To nObjNumber
				   	nObjNumber := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		    		For nObj := 1 To nObjNumber
						IF ( nObj == 1 )
							//Limpa o aGets e o aTela para remontar a nova enchoice do mesmo alias
							aGets			:= {}
							aTela			:= {}
							cAlias		:= aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS ]
							aColsF2		:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS	] )
							aAlterF2	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA	] )
							aFieldF2	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AFIELDS	] )
							aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]	:= MsmGet():New( cAlias , nReg , nOpc , NIL , NIL , NIL , aFieldF2 , aObj7Size[1] , aAlterF2 , NIL , NIL , NIL , oFolders:aDialogs[ APDA270_FOLDER_AGENDA ] , NIL , .F. , NIL , .F.)
						ElseIF ( nObj == 2 )
							aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]	:= TButton():New( aObj8Size[1,1],aObj8Size[1,2],OemToAnsi("&"+STR0154)+"...<F7>",oDlg,{ || MyCursorWait() , Eval(bBuildAva) , MyCursorArrow() },200,15,,,.F.,.T.,.F.,,.F.,,,.F.) //'Gerar Avalia��o'
						ElseIF ( nObj == 3 )
							aCols	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS	] )
							aAltera	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA	] )
							aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] := MsNewGetDados():New(aObj8Size[2,1],aObj8Size[2,2],aObj8Size[2,3],aObj8Size[2,4],nOpcNewGd,APDA270AllWaysTrue( nOpc , "a270RdpGdLinOk"),APDA270AllWaysTrue( nOpc , "RdpGdTudOk"),"",aClone(aAltera),0,999999,NIL,NIL,bRdpGdDelOk,oDlg,__aRdpHeader__,aClone(aCols))
							aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:oBrowse:cToolTip := StrTran( STR0101 , "&" , "" )	//"A&genda"
						EndIF
					Next nObj
				Next nObj
			ElseIF ( nFolder == APDA270_FOLDER_AVALIADOS )
				/*/
				��������������������������������������������������������������Ŀ
				� Monta as Dimensoes dos Objetos         					   �
				����������������������������������������������������������������/*/
				/*aObjCoords := {}
				aAdd( aObjCoords , { 015 , 015 , .T. , .F. } )
				aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
				aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )*/
				nObjNumber := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		    	For nObj := 1 To nObjNumber
					aAltera	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA	] )
					IF ( nObj == 1 )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]	:= TButton():New( aObj2Size[1,1],aObj2Size[1,2],OemToAnsi("&"+STR0024),oDlg,{ || MyCursorWait() , BtnRd9Select( nOpc ) , MyCursorArrow() },200,15,,,.F.,.T.,.F.,,.F.,,,.F.) //'Selecionar Participantes ( Avaliados )'
					ElseIF ( nObj == 2 )
						/*/
						��������������������������������������������������������������Ŀ
						� Reinicializa aCols que sera Carregada no Change			   �
						����������������������������������������������������������������/*/
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] := MsNewGetDados():New(aObj2Size[2,1],aObj2Size[2,2],aObj2Size[2,3],aObj2Size[2,4],nOpcNewGd,APDA270AllWaysTrue( nOpc , "a270Rd9GdLinOk"),APDA270AllWaysTrue( nOpc , "a270Rd9GdTudOk"),"",aClone(aAltera),0,999999,NIL,NIL,bRd9GdDelOk,oDlg,__aRd9Header__,GdRmkaCols(__aRd9Header__))
						/*/
						��������������������������������������������������������������Ŀ
						� O Primeiro Elemento eh setado sempre como Deletado		   �
						����������������������������������������������������������������/*/
						GdFieldPut( "GDDELETED" , .T. , 1 , aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:aHeader , aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:aCols  )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:oBrowse:cToolTip := OemToAnsi( STR0034 ) //'Avaliados'
					EndIF
				Next nObj
			ElseIF ( nFolder == APDA270_FOLDER_AVALIADORES	)
				/*/
				��������������������������������������������������������������Ŀ
				� Monta as Dimensoes dos Objetos         					   �
				����������������������������������������������������������������/*/
			   /*	aObjCoords := {}
				aAdd( aObjCoords , { 000 , 080 , .T. , .F. } )
				aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
				aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
				aGdCoords1		:= { aObjSize[1,1]+15,aObjSize[1,2],aObjSize[1,3],aObjSize[1,4]}
				aGdCoords2		:= { aObjSize[2,1]+1,aObjSize[2,2],aObjSize[2,3],aObjSize[2,4]/100*30}
				aBtnCoords		:= { aObjSize[2,1],aObjSize[2,4]/100*30,(aObjSize[2,4]-(aObjSize[2,4]/100*30)),15}
				aGdCoords3		:= { aObjSize[2,1]+15,aObjSize[2,4]/100*30+1,aObjSize[2,3],aObjSize[2,4]}*/
				nObjNumber := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		    	For nObj := 1 To nObjNumber
					aAltera	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AALTERA	] )
					IF ( nObj == 1 )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS	] := aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_OBJ ]:aCols
						aCols	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS	] )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]	:= MsNewGetDados():New(aObj3Size[1,1],aObj3Size[1,2],aObj3Size[1,3],aObj3Size[1,4],0,APDA270AllWaysTrue( nOpc ),APDA270AllWaysTrue( nOpc ),"",{},0,999999,NIL,NIL,NIL,oDlg,__aRd9Header__,aClone(aCols))
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:cToolTip := OemToAnsi( STR0034 ) //'Avaliados'
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:bChange		:= { || MyCursorWait() , Rd9Rdh2RdaChg() , MyCursorArrow() }
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:bGotFocus		:= { || MyCursorWait() , Rd9RdhGotFocus() , MyCursorArrow() }
					ElseIF ( nObj == 2 )
						aCols	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS	] )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]	:= MsNewGetDados():New(aObj4Size[1,1],aObj4Size[1,2],aObj4Size[1,3],aObj4Size[1,4],0,APDA270AllWaysTrue( nOpc ),APDA270AllWaysTrue( nOpc ),"",aClone(aAltera),0,999999,NIL,NIL,NIL,oDlg,__aRdhHeader__,aClone(aCols))
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:cToolTip := OemToAnsi( STR0041 ) //'Rede'
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:bChange		:= { || MyCursorWait() , Rd9Rdh2RdaChg() , MyCursorArrow() }
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:bGotFocus		:= { || MyCursorWait() , Rd9RdhGotFocus() , MyCursorArrow() }
					ElseIF ( nObj == 3 )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]	:= TButton():New(aObj5Size[1,1],aObj5Size[1,2],OemToAnsi("&"+STR0025),oDlg,{ || MyCursorWait() , BtnRdaSelect( nOpc ) , MyCursorArrow() },200,15,,,.F.,.T.,.F.,,.F.,,,.F.) //'Selecionar Participantes ( Avaliadores )'
					ElseIF ( nObj == 4 )
						/*/
						��������������������������������������������������������������Ŀ
						� Reinicializa aCols que sera Carregada no Change			   �
						����������������������������������������������������������������/*/
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]	:= MsNewGetDados():New(aObj5Size[2,1],aObj5Size[2,2],aObj5Size[2,3],aObj5Size[2,4],nOpcNewGd,APDA270AllWaysTrue( nOpc , "a270GdLinOk"),APDA270AllWaysTrue( nOpc , "a270RdaGdTudOk"),"",aClone(aAltera),0,999999,NIL,NIL,bRdaGdDelOk,oDlg,__aRdaHeader__,GdRmkaCols(__aRdaHeader__))
						/*/
						��������������������������������������������������������������Ŀ
						� O Primeiro Elemento eh setado sempre como Deletado		   �
						����������������������������������������������������������������/*/
						GdFieldPut( "GDDELETED" , .T. , 1 , aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:aHeader , aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:aCols  )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ	]:oBrowse:cToolTip		:= OemToAnsi( STR0033 )	//'Avaliadores'
					EndIF
				Next nObj
		    EndIF
		Next nFolder

		/*/
		��������������������������������������������������������������Ŀ
		� Retorna o Conteudo de cAlias                          	   �
		����������������������������������������������������������������/*/
		cAlias := "RD6"

		/*/
		��������������������������������������������������������������Ŀ
		� Limpa o Conteudo das Variaveis Temporarias               	   �
		����������������������������������������������������������������/*/
		aCols		    := NIL
		aAltera			:= NIL
		aNaoAltera		:= NIL
		aNotFields		:= NIL
		aRecnos			:= NIL
		aKeys			:= NIL
		aFields			:= NIL
		aGets			:= NIL
		aTela			:= NIL
		aObjCoords 		:= NIL
		aObjSize		:= NIL
		aGdCoords1		:= NIL
		aGdCoords2		:= NIL
		bSkip			:= NIL
		bKey			:= NIL
		cKey			:= NIL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDialogInit )

End Sequence

/*/
��������������������������������������������������������������Ŀ
�Coloca o Ponteiro do Mouse em Estado de Espera			   	   �
����������������������������������������������������������������/*/
MyCursorWait()

/*/
��������������������������������������������������������������Ŀ
� Retorna o Conteudo de cAlias                          	   �
����������������������������������������������������������������/*/
cAlias := "RD6"

/*/
��������������������������������������������������������������Ŀ
�Quando Confirmada a Opcao e Nao for Visualizacao Grava ou   Ex�
�clui as Informacoes 										   �
����������������������������������������������������������������/*/
IF (;
		( Inclui ) .or.	;	//Inclusao
		( Altera ) .or.	;	//Alteracao
		( Exclui )		;	//Exclusao
	)
	IF ( nOpcAlt == 1 )
		bAPDA270Grava := { || APDA270Grava( nOpc , aFolders , nReg , cAlias ) }
		/*/
		��������������������������������������������������������������Ŀ
		� Gravando/Incluido ou Excluindo Informacoes 				   �
		����������������������������������������������������������������/*/
		IF !( lBldAvaAuto )
			MsAguarde( bAPDA270Grava , NIL, OemToAnsi( IF( ( nOpc == 5 ) , STR0092 /*'Excluindo Avalia��o'*/ , STR0091/*'Gravando Avalia��o'*/ ) ) )
		Else
			Eval( bAPDA270Grava )
		EndIF
		If ExistBlock("APDMONTA")
			ExecBlock("APDMONTA",.F.,.F.,{RD6->RD6_CODIGO})
		Endif
	Else
		/*/
		��������������������������������������������������������������Ŀ
		� RollBack da Numeracao Automatica            				   �
		����������������������������������������������������������������/*/
		While ( GetSX8Len() > nGetSX8Len )
			RollBackSX8()
		End While
	EndIF
EndIF

/*/
��������������������������������������������������������������Ŀ
�Coloca o Ponteiro do Mouse em Estado de Espera			   	   �
����������������������������������������������������������������/*/
MyCursorWait()

/*/
��������������������������������������������������������������Ŀ
�Libera os Locks             								   �
����������������������������������������������������������������/*/
APDA270FreeLocks( aFolders , cAliasNoLock , aRecnos , aKeys )

/*/
��������������������������������������������������������������Ŀ
�Verifica se Deve Mostrar o Log de Inconsistencia na Exclusao  �
����������������������������������������������������������������/*/
IF ( ( Exclui ) .and. !( lChkDelOk ) )
	IF ( lChkDelShwLog )
		MyCursorWait()
			fMakeLog( aLogChkDel , aLogTitChkDel , NIL , NIL , FunName() , cTitLogDel )
		MyCursorArrow()
	Else
		MsgInfo( cMsgLogDel , cCadastro + " - " + OemToAnsi( cTitLogDel ) )
	EndIF
	/*
	��������������������������������������������������������������������������������������������������Ŀ
	� Ponto de entrada para tratamento da delecao dos registros                                        �
	� das tabelas relacionadas									                                       �
	� Layout do array aLogchkdel:                                                                      �
	� RDB     0000000127 000013001244      001244200401010000070000010000040012000000000000027/  000013�
	����������������������������������������������������������������������������������������������������*/
	If ExistBlock("APD80DEL")
		ExecBlock("APD80DEL",.F.,.F.,{aAreaRD6,lChkDelShwLog,aLogChkDel})
	Endif
EndIF

/*/
��������������������������������������������������������������Ŀ
�Restaura os Dados de Entrada								   �
����������������������������������������������������������������/*/
RestArea( aAreaRD6 )
RestArea( aArea )

/*/
��������������������������������������������������������������Ŀ
�Restaura as Teclas de Atalho 								   �
����������������������������������������������������������������/*/
RestKeys( aSvKeys , .T. )

/*/
��������������������������������������������������������������Ŀ
�Restaura o Cursor do Mouse                				   	   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Fldrs  �Autor �Marinaldo de Jesus  � Data �11/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica a Existencia do aFoldes                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270Fldrs()
Return(;
		( Type( "aFolders" ) == "A" );
		.and.;
		!Empty( aFolders );
		.and.;
		( Len( aFolders ) == APDA270_ELEMENTOS_FOLDER );
	  )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6HeaderGet  �Autor �Marinaldo de Jesus  � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com o Header do Rd6				    		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd6HeaderGet( nRd6HeaderGet )

Local aRd6HeaderGet

IF APDA270Fldrs()
	DEFAULT nRd6HeaderGet	:= APDA270_AHEADER
	aRd6HeaderGet			:= aFolders[ APDA270_FOLDER_PRINCIPAL , APDA270_FOLDER_OBJECTS , 1 , nRd6HeaderGet ]
EndIF

Return( aRd6HeaderGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6FAHeaderGet�Autor �Emerson Campos      � Data �18/01/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com o Header do Rd6 no folder da agenda  		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd6FAHeaderGet( nRd6HeaderGet )

Local aRd6HeaderGet

IF APDA270Fldrs()
	DEFAULT nRd6HeaderGet	:= APDA270_AHEADER
	aRd6HeaderGet			:= aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 1 , nRd6HeaderGet ]
EndIF

Return( aRd6HeaderGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpHeaderGet  �Autor �Marinaldo de Jesus  � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com o Header da Agenda			    		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdpHeaderGet( nRdpHeaderGet )

Local aRdpHeaderGet

IF APDA270Fldrs()
	DEFAULT nRdpHeaderGet	:= APDA270_AHEADER
	aRdpHeaderGet			:= aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 3 , nRdpHeaderGet ]
EndIF

Return( aRdpHeaderGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpColsGet 	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com Todas as Informacoes da Agenda			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdpColsGet( nRdpColsGet )

Local aRdpColsGet

IF APDA270Fldrs()
	DEFAULT nRdpColsGet := APDA270_ACOLS
	aRdpColsGet		:= aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 3 , nRdpColsGet ]
EndIF

Return( aRdpColsGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpColsSet 	  �Autor �Marinaldo de Jesus  � Data �28/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Seta o Novo conteudo para a Agenda               			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdpColsSet( aRdpColsSet , nRdpColsSet )

IF APDA270Fldrs()
	DEFAULT nRdpColsSet := APDA270_ACOLS
	aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 3 , nRdpColsSet ] := aClone( aRdpColsSet )
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9HeaderGet  �Autor �Marinaldo de Jesus  � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com o Header de Avaliados		    			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd9HeaderGet( nRd9HeaderGet )

Local aRd9HeaderGet

IF APDA270Fldrs()
	DEFAULT nRd9HeaderGet	:= APDA270_AHEADER
	aRd9HeaderGet 			:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , nRd9HeaderGet ]
EndIF

Return( aRd9HeaderGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9Cols		  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com Todas as Informacoes de Avaliados		    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd9ColsGet( nRd9ColsGet )

Local aRd9ColsGet

IF APDA270Fldrs()
	DEFAULT nRd9ColsGet	:= APDA270_ACOLS
	aRd9ColsGet			:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , nRd9ColsGet ]
EndIF

Return( aRd9ColsGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdhHeaderGet  �Autor �Marinaldo de Jesus  � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com o Header da Rede				    		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdhHeaderGet( nRdhHeaderGet )

Local aRdhHeaderGet

IF APDA270Fldrs()
	DEFAULT nRdhHeaderGet	:= APDA270_AHEADER
	aRdhHeaderGet			:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , nRdhHeaderGet ]
EndIF

Return( aRdhHeaderGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdhCols		  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com Todas as Informacoes da Rede			    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdhColsGet( nRdhColsGet )

Local aRdhColsGet

IF APDA270Fldrs()
	DEFAULT nRdhColsGet	:= APDA270_ACOLS
	aRdhColsGet			:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , nRdhColsGet ]
EndIF

Return( aRdhColsGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdhColsSet 	  �Autor �Marinaldo de Jesus  � Data �28/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Seta o Array com Todas as Informacoes da Rede			    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdhColsSet( aRdhColsSet , nRdhColsSet )

IF APDA270Fldrs()
	DEFAULT nRdhColsSet	:= APDA270_ACOLS
	aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , nRdhColsSet ] := aClone( aRdhColsSet )
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdhRecnoSet	  �Autor �Marinaldo de Jesus  � Data �28/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Seta o Array com os Recnos do RDH ( Rede )					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdhRecnoSet( aRdhRecnoSet , nRdhRecnoSet )

IF APDA270Fldrs()
	DEFAULT nRdhRecnoSet := APDA270_ARECNOS
	aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , nRdhRecnoSet ]	:= aClone( aRdhRecnoSet )
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaHeaderGet  �Autor �Marinaldo de Jesus  � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com o Header de Avaliadores		    		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdaHeaderGet( nRdaHeaderGet )

Local aRdaHeaderGet

IF APDA270Fldrs()
	nRdaHeaderGet	:= APDA270_AHEADER
	aRdaHeaderGet	:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 4 , nRdaHeaderGet ]
EndIF

Return( aRdaHeaderGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCols		  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Array com Todas as Informacoes de Avaliadores	    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdaColsGet( nRdaColsGet )

Local aRdaColsGet

IF APDA270Fldrs()
	DEFAULT nRdaColsGet	:= APDA270_ACOLS
	aRdaColsGet			:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 4 , nRdaColsGet ]
EndIF

Return( aRdaColsGet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �oGdRdpGet	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Objeto GetDados Relacionado ao Calendario	        �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function oGdRdpGet()

Local oGdRdp

IF APDA270Fldrs()
	oGdRdp := aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 3 , APDA270_OBJ ]
EndIF

Return( oGdRdp )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �oGdRd9Get	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Objeto GetDados Relacionado aos Avaliados           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function oGdRd9Get( nFolder )

Local oGdRd9
Local nObj

IF APDA270Fldrs()
	DEFAULT nFolder := APDA270_FOLDER_AVALIADOS
	Do Case
		Case ( nFolder == APDA270_FOLDER_AVALIADOS )
			nObj := 2
		Case ( nFolder == APDA270_FOLDER_AVALIADORES )
			nObj := 1
		OtherWise
			nObj := 2
	End Case
	oGdRd9 := aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]
EndIF

Return( oGdRd9 )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �oGdRdaGet	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Objeto GetDados Relacionado aos Avaliadores         �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function oGdRdaGet( nFolder )

Local oGdRda
Local nObj

IF APDA270Fldrs()
	DEFAULT nFolder := APDA270_FOLDER_AVALIADORES
	Do Case
		Case ( nFolder == APDA270_FOLDER_AVALIADORES )
			nObj := 4
		OtherWise
			nObj := 4
	End Case
	oGdRda := aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]
EndIF

Return( oGdRda )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �oGdRdhGet	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Objeto GetDados Relacionado a Rede			        �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function oGdRdhGet( nFolder )

Local oGdRdh
Local nObj

IF APDA270Fldrs()
	DEFAULT nFolder := APDA270_FOLDER_AVALIADORES
	Do Case
		Case ( nFolder == APDA270_FOLDER_AVALIADORES )
			nObj := 2
		OtherWise
			nObj := 2
	End Case
	oGdRdh := aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]
EndIF

Return( oGdRdh )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �oRd9BtnGet	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Objeto GetDados Relacionado aos Avaliados           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function oRd9BtnGet()

Local oRd9Btn

IF APDA270Fldrs()
	oRd9Btn := aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 1 , APDA270_OBJ ]
EndIF

Return( oRd9Btn )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �oRdaBtnGet	  �Autor �Marinaldo de Jesus  � Data �21/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Objeto GetDados Relacionado aos Avaliados           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function oRdaBtnGet()

Local oRdaBtn

IF APDA270Fldrs()
	oRdaBtn := aFolders[ APDA270_FOLDER_AVALIADORES	, APDA270_FOLDER_OBJECTS , 3 , APDA270_OBJ ]
EndIF

Return( oRdaBtn )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Locks �Autor�Marinaldo de Jesus    � Data �21/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Lock dos Registros                                          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270Locks( nOpc , aFolders )

Local aRecnos	:= {}
Local lLocks	:= .T.

Local cAlias
Local nFolder
Local nFolders
Local nObj
Local nObjs

Begin Sequence

	nFolders := Len( aFolders )
	For nFolder := 1 To nFolders
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		For nObj := 1 To nObjs
			cAlias	:= aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS	]
			aRecnos	:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS	] )
			IF !( lLocks := WhileNoLock( cAlias , aRecnos , NIL , 1 , 1 , NIL , 100 , NIL , NIL , !( lBldAvaAuto )  ) )
				Break
			EndIF
		Next nObj
   	Next nFolder

End Sequence

MyCursorWait()

Return( lLocks )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270FreeLocks �Autor�Marinaldo de Jesus� Data �08/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Libera os Locks obtidos pela APDA270Locks					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270FreeLocks( aFolders , cAlias , aRecnos , aKeys )

Local aFreeLocks := {}

Local nFolder
Local nFolders
Local nObj
Local nObjs

IF ( Empty( cAlias ) .and. ValType( aFolders ) # "U" )//ValType para nao gerar ErrorLog
	nFolders := Len( aFolders )
	For nFolder := 1 To nFolders
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		For nObj := 1 To nObjs
			cAlias	:= aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ALIAS   ]
			aRecnos	:= aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS ]
			aKeys	:= aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AKEYS   ]
			IF !Empty( cAlias )
				aAdd( aFreeLocks , { cAlias , aRecnos , aKeys } )
			EndIF
			IF ( ValType( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] ) == "O", freeobj(aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]), )
		Next nObj
	Next nFolder
Else
	aAdd( aFreeLocks , { cAlias , aRecnos , aKeys } )
EndIF

Return( ApdFreeLocks( aFreeLocks ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270EnTOk �Autor�Marinaldo de Jesus    � Data �18/06/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �TudoOk para a Enchoice                                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �APDA270EnTOk( nOpc , oEnchoice )							�
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA050()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270EnTOk( nOpc , oEnchoice )

Local lTudoOk := .T.

IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )
	//lTudoOk := EnchoTudOk( oEnchoice )
	lTudoOk := EnchoTudOk(	oEnchoice,;                     //Objeto a validar
							NIL,;							//Array com campos a validar
                            {"RD6_IDUSUA", "RD6_CODRSP"},;	//Array com campos que nao serao validados
                            .F. )                          //Se ira ocultar a Enchoice durante a validacao
EndIF

Return( lTudoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpBldCalend	 �Autor�Marinaldo de Jesus� Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Monta a Agenda para Envio das Avaliacoes            		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function RdpBldCalend( aFolders , lForceBld , lShowMsg , lAgend )

Local aClassData
Local aColsAdd
Local aColsAux
Local aRdpNoDel

Local bAddItem

Local dRd6DtIni
Local dRd6DtFim
Local dDataIni
Local dDataFim

Local cDataAux
Local cRd6Period
Local cStatusMdf
Local cStatusNen

Local lBldAgenda
Local lDiario
Local lSemanal
Local lQuinzenal
Local lMensal

Local nRd6IntMes
Local nRd6IniGer
Local nRd6IniRsp
Local nRd6RspAdo
Local nRd6RspDor
Local nRd6RspCon
Local nRdpStatus
Local nRdpDatIni
Local nDay
Local nMonth
Local nYear
Local nPos
Local nLoop
Local nLoops

Local oGdRdp
Local nAtPos		:= 0

DEFAULT lForceBld	:= .F.
DEFAULT lShowMsg	:= .F.
DEFAULT lAgend	:= .T.

Begin Sequence

	IF !( lBldAgenda := RdpChkBldAgenda( aFolders , lForceBld , lShowMsg ) )
		Break
	EndIF

	dRd6DtIni	:= GetMemVar( "RD6_DTINI" )
	IF !( lBldAgenda := !Empty( dRd6DtIni ) )
		Break
	EndIF

	dRd6DtFim	:= GetMemVar( "RD6_DTFIM" )
	IF !( lBldAgenda := !Empty( dRd6DtFim ) )
		Break
	EndIF

	nRd6IniGer	:= GetMemVar( "RD6_INIGER" )
	nRd6IniRsp	:= GetMemVar( "RD6_INIRSP" )

	cRd6Period	:= GetMemVar( "RD6_PERIOD" )
	IF !( lBldAgenda := !Empty( cRd6Period ) )
		Break
	EndIF

	IF ( lMensal := Rd6PeriodM() )
		nRd6IntMes := GetMemVar( "RD6_INTMES" )
		IF !( lBldAgenda := !Empty( nRd6IntMes ) )
			Break
		EndIF
	EndIF

	nRd6RspAdo	:= GetMemVar( "RD6_RSPADO" )
	nRd6RspDor	:= GetMemVar( "RD6_RSPDOR" )
	nRd6RspDor	+= nRd6RspAdo
	nRd6RspCon	:= GetMemVar( "RD6_RSPCON" )
	nRd6RspCon	+= nRd6RspDor

	oGdRdp := oGdRdpGet()
	nAtPos := oGdRdp:oBrowse:nAt

	IF !( lBldAgenda := ( ValType( oGdRdp ) == "O" ) )
		Break
	EndIF

	aClassData	:= ClassDataArr( oGdRdp )
	nPos := aScan( aClassData , { |eData| ( Upper( AllTrim( eData[1] ) ) == "CCLASSNAME" ) } )
	IF !( lBldAgenda := ( nPos > 0 ) )
		Break
	EndIF

	IF !( lBldAgenda := ( aClassData[ nPos , 2 ] $ "MSNEWGETDADOS/MSGETDADOS" ) )
		Break
	EndIF

	IF !( lMensal )
		IF !( lDiario := Rd6PeriodD()  )
			IF !( lSemanal := Rd6PeriodS() )
				lQuinzenal := Rd6PeriodQ()
			EndIF
		EndIF
	EndIF

	bAddItem	:= { || aColsAux := GdRmkaCols( oGdRdp:aHeader , .F. , .T. , .T. ),;
						GdFieldPut( "RDP_DATINI" , dDataIni 										, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_DATFIM" , Min( dDataFim , dRd6DtFim )						, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_DATGER" , DaySub( dDataIni , nRd6IniGer )					, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_INIRSP" , Min(DaySum( dDataIni , nRd6IniRsp ),dDataFim)	, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_TIPCOB" , GetMemVar("RDP_TIPCOB")							, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_QTDCOB" , GetMemVar("RDP_QTDCOB")							, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_MEMCOB" , GetMemVar("RDP_MEMCOB")							, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_MEMRSP" , GetMemVar("RDP_MEMRSP")							, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_RSPADO" , Min(DaySum( dDataIni , nRd6RspAdo ),dDataFim)	, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_RSPDOR" , Min(DaySum( dDataIni , nRd6RspDor ),dDataFim)	, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_RSPCON" , Min(DaySum( dDataIni , nRd6RspCon ),dDataFim)	, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_TIPENV" , GetMemVar("RDP_TIPENV")							, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						GdFieldPut( "RDP_MSGAVA" , GetMemVar("RDP_MSGAVA")							, 1 , oGdRdp:aHeader , @aColsAux , .F. ),;
						aAdd( aColsAdd , aClone( aColsAux[1] ) );
				   }

	IF  lAgend .AND. !( GdRdpGetDet( oGdRdp:aHeader ) )
		Break
	EndIF

	MyCursorWait()
		aColsAdd	:= {}
		dDataIni	:= dRd6DtIni
		IF ( lDiario )
			dDataFim	:= dDataIni
		ElseIF ( lSemanal )
			dDataFim	:= --( DaySum( dDataIni , 7 ) )
		ElseIF ( lQuinzenal )
			dDataFim	:= --( DaySum( dDataIni , 15 ) )
		ElseIF ( lMensal )
			dDataFim	:= --( MonthSum( dDataIni , nRd6IntMes ) )
		EndIF
		Eval( bAddItem )
		nLoops 		:= ( dRd6DtFim - dRd6DtIni )
		For nLoop	:= 1 To nLoops
			IF ( lDiario )
				dDataIni	:= DaySum( dDataIni , 1 )
				dDataFim	:= dDataIni
			ElseIF ( lSemanal )
				dDataIni	:= DaySum( dDataIni , 7 )
				dDataFim	:= --( DaySum( dDataIni , 7 ) )
				nLoop		+= 7
				IF ( ( nLoops - nLoop ) < 7 )
					Exit
				EndIF
			ElseIF ( lQuinzenal )
				dDataIni	:= DaySum( dDataIni , 15 )
				dDataFim	:= --( DaySum( dDataIni , 15 ) )
				nLoop		+= 15
				IF ( ( nLoops - nLoop ) < 15 )
					Exit
				EndIF
			ElseIF ( lMensal )
				dDataIni	:= MonthSum( dDataIni , nRd6IntMes )
				dDataFim	:= --( MonthSum( dDataIni , nRd6IntMes ) )
				nLoop		:= ( dDataIni - dRd6DtIni )
			EndIF
			IF ( dDataIni > dRd6DtFim )
				Exit
			EndIF
			Eval( bAddItem )
		Next nLoop
		aRdpNoDel	:= {}
		cStatusMdf	:= SubStr( RdpStatusBox( .T. ) , 1 , 3 )
		cStatusNen	:= SubStr( RdpStatusBox( .T. ) , 3 , 1 )	//Nao Enviada
		nRdpStatus	:= GdFieldPos( "RDP_STATUS" , oGdRdp:aHeader )
		nRdpDatIni	:= GdFieldPos( "RDP_DATINI" , oGdRdp:aHeader )

		Private aHeader := oGdRdp:aHeader
		Private aCols	:= oGdRdp:aCols
		Private n

		nLoop  		:= 0
		nLoops 		:= Len( oGdRdp:aCols )
		While ( ( nLoop := aScan( oGdRdp:aCols , { |x| x[nRdpStatus] $ cStatusMdf } ) ) > 0 )
			IF ( cStatusNen == oGdRdp:aCols[ nLoop , nRdpStatus ] )
				cMsgNoYes := STR0124 //"J� existem avalia��es agendadas para o dia"
				cMsgNoYes += " "
				cMsgNoYes += Dtoc( oGdRdp:aCols[ nLoop , nRdpDatIni ] )
				cMsgNoYes += ". "
				cMsgNoYes += STR0125	//"Deseja exclu�-las?"
				oGdRdp:Goto( nLoop )
				n := nLoop
				MyCursorArrow()
				IF !(;
						MsgNoYes( cMsgNoYes );
						.and.;
						(;
							MyCursorWait(),;
							RdpGdDelOk( 4 , .T. , .F. );//Deleto as Avaliacoes
						);
					)
					aAdd( aRdpNoDel , aClone( oGdRdp:aCols[ nLoop ] ) )
				EndIF
				MyCursorWait()
			EndIF
			aDel( oGdRdp:aCols , nLoop )
			aSize( oGdRdp:aCols , --nLoops )
		End While
		nLoops := Len( aRdpNoDel )
		For nLoop := 1 To nLoops
			aAdd( oGdRdp:aCols , aClone( aRdpNoDel[ nLoop ] ) )
		Next nLoop
		nLoops := Len( aColsAdd )
		For nLoop := 1 To nLoops
			IF ( aScan( oGdRdp:aCols , { |x| x[ nRdpDatIni ] == aColsAdd[ nLoop , nRdpDatIni ] } ) == 0 )
				aAdd( oGdRdp:aCols , aClone( aColsAdd[ nLoop ] ) )
			EndIF
		Next nLoop
		aSort( oGdRdp:aCols , NIL , NIL , { |x,y| x[ nRdpDatIni ] < y[ nRdpDatIni ] } )
		oGdRdp:Goto( 1 )
		RdpChkChange( oGdRdp )
		If !lAgend .And. nAtPos > 1
			oGdRdp:Goto( nAtPos )
		EndIf
	MyCursorArrow()

End Sequence

Return( lBldAgenda )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpChkBldAgenda	 �Autor�Marinaldo de Jesus� Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se Deve Remontar Agenda                    		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �RdpBldCalend() em APDA270()									�
�������������������������������������������������������������������������/*/
Static Function RdpChkBldAgenda( aFolders , lForceBld , lShowMsg )

Local aRd6Header		:= {}
Local aRd6LstCols		:= {}
Local aRd6AgHeader		:= {}
LOcal aRd6AgLstCols		:= {}
Local bRd6ChkAlt		:= { || .F. }
Local bRd6PutAlt		:= { || NIL }
Local cMsgInfo			:= ""
Local lRdpChkBldAgenda	:= .F.

DEFAULT lShowMsg		:= .F.

Begin Sequence

	IF !( lRdpChkBldAgenda := APDA270Fldrs() )
		Break
	EndIF

	IF !( lRdpChkBldAgenda := ( GetMemVar( "RD6_STATUS" ) == "1" ) ) //Aberto
		cMsgInfo := STR0128	//"Esta Avalia��o j� foi encerrada."
		Break
	EndIF

	aRd6Header 		:= Rd6HeaderGet()
	aRd6LstCols		:= aFolders[ APDA270_FOLDER_PRINCIPAL , APDA270_FOLDER_OBJECTS , 1 , APDA270_ALSTCOLS	]
	aRd6AgHeader	:= Rd6FAHeaderGet()
	aRd6AgLstCols	:= aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 1 , APDA270_ALSTCOLS	]

	bRd6ChkAlt	:= { || ;
	 						( GetMemVar( "RD6_DTINI" ) <> GdFieldGet( "RD6_DTINI"	, 1 , .F. , aRd6Header , aRd6LstCols ) );
	 						.or.;
	 						( GetMemVar( "RD6_DTFIM" ) <> GdFieldGet( "RD6_DTFIM"	, 1 , .F. , aRd6Header , aRd6LstCols ) );
	 						.or.;
	 						( GetMemVar( "RD6_PERIOD" ) <> GdFieldGet( "RD6_PERIOD" , 1 , .F. , aRd6AgHeader , aRd6AgLstCols ) );
	 						.or.;
	 						( GetMemVar( "RD6_INTMES" ) <> GdFieldGet( "RD6_INTMES" , 1 , .F. , aRd6AgHeader , aRd6AgLstCols ) );
	 						.or.;
	 						( GetMemVar( "RD6_INIGER" ) <> GdFieldGet( "RD6_INIGER" , 1 , .F. , aRd6AgHeader , aRd6AgLstCols ) );
	 				}

	IF ( lRdpChkBldAgenda := ( ( lForceBld ) .or. Eval( bRd6ChkAlt ) ) )
		bRd6ChkAlt	:= { || ;
		 						GdFieldPut( "RD6_DTINI"		, GetMemVar( "RD6_DTINI" )	, 1 , aRd6Header , @aRd6LstCols , .F. ),;
		 						GdFieldPut( "RD6_DTFIM"		, GetMemVar( "RD6_DTFIM" )	, 1 , aRd6Header , @aRd6LstCols , .F. ),;
		 						GdFieldPut( "RD6_PERIOD"	, GetMemVar( "RD6_PERIOD" ) , 1 , aRd6AgHeader , @aRd6AgLstCols , .F. ),;
		 						GdFieldPut( "RD6_INTMES" 	, GetMemVar( "RD6_INTMES" ) , 1 , aRd6AgHeader , @aRd6AgLstCols , .F. ),;
		 						GdFieldPut( "RD6_INIGER" 	, GetMemVar( "RD6_INIGER" ) , 1 , aRd6AgHeader , @aRd6AgLstCols , .F. ),;
		 						aFolders[ APDA270_FOLDER_PRINCIPAL , APDA270_FOLDER_OBJECTS , 1 , APDA270_ALSTCOLS	] := aClone( aRd6LstCols );
		 				}
		Eval( bRd6ChkAlt )
		Break
	EndIF

End Sequence

IF ( ( lShowMsg ) .and. !Empty( cMsgInfo ) )
	//"Aviso de Inconsistencia!"
	MsgInfo( OemToAnsi( cMsgInfo ) , STR0022 )
EndIF

Return( lRdpChkBldAgenda )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270UsrChk �Autor�Marinaldo de Jesus   � Data �29/10/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Usuario Corrente Pode Consultar a Avaliacao	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270UsrChk( nOpc , cAlias , nReg , lInclui )

Local lAcessOk	:= .T.
Local lAdm		:= If( RetCodUsr() == '000000' .Or. '000000/' $ RetGrpUsr() , .T., .F.)

DEFAULT nOpc	:= 1
DEFAULT cAlias	:= Alias()
DEFAULT nReg	:= ( cAlias )->( Recno() )
DEFAULT lInclui	:= .F.

IF !( ( cAlias )->( Recno() ) == nReg )
	( cAlias )->( dbGoto( nReg ) )
EndIF
IF !( lInclui )
	IF !( lAcessOk := RD6->( ChkUsrGrp( RD6_IDUSUA , RD6_GRUUSU ,, lAdm) ) )
		MyCursorArrow()
		MsgInfo(	OemToAnsi( STR0045 )	,;	//'Usu�rio n�o autorizado a efetuar manuten��o ou consulta nesta Avalia��o'
					OemToAnsi( STR0022 )	 ; 	//'Aviso de Inconsist�ncia!'
		  	    )
		MyCursorWait()
	EndIF
EndIF

Return( lAcessOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Grava�Autor�Marinaldo de Jesus     � Data �29/10/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Grava as Informacoes										�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270Grava(	nOpc			,;	//Opcao do aRotina
								aFolders		,;	//Array com Todas as Informacoes para Gravacao/Exclusao
								nReg			,;	//Contem o Posicionamento do Alias Mestre
								cAliasMestre	 ;	//Alias Mestre
							)

/*/
�������������������������������������������������������������Ŀ
� Variaveis de Inicializacao Obrigatoria					  �
���������������������������������������������������������������/*/
Local aMestre		:= GdPutIStrMestre( 01 )
Local aMestre2		:= GdPutIStrMestre( 01 )
Local aItens		:= {}
Local aGravaObjs	:= {}
Local aRecGrv		:= {}
Local cOpcao		:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
Local lModMestre	:= .F.
Local lModItens		:= ( nOpc == 5 )
Local lDeleted		:= .F.
Local lSort			:= .F.
Local bSort			:= { || NIL }

/*/
�������������������������������������������������������������Ŀ
� Variaveis que serao inicializadas no Corpo da Funcao		  �
���������������������������������������������������������������/*/
Local aHeader
Local aCols
Local aColsAux 		:= {}
Local aColsAux2 	:= {}
Local aSvCols
Local aVirtual
Local aRecnos
Local aRdaQuery		:= {}
Local aRdaRecnos
Local aRdaRecDel
Local aJobAux  		:= {}
Local bGdDelNoEmpy
Local bGdSplitDel
Local cRd6CodAva
Local cKey
Local cJobFile 		:= ''
Local cJobAux  		:= ''
Local cStartPath 	:= GetSrvProfString("Startpath","")

Local nCont			:= 0
Local nLoop
Local nLoops
Local nFolder
Local nFolders
Local nObj
Local nObjs
Local nItens
Local nStep
Local nGravaObjs
Local nPosRdaRecno
Local nRetry_0 		:= 0
Local nRetry_1 		:= 0

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Verifica os Intens que serao Gravados       				   �
	����������������������������������������������������������������/*/
	nFolders := Len( aFolders )
	/*/
	��������������������������������������������������������������Ŀ
	� Define o Step conforme cOpcao               				   �
	����������������������������������������������������������������/*/
	IF ( cOpcao == "DELETE" )
		nStep		:= -1
		nFolder		:= nFolders
		nFolders	:= 1
	Else
		nStep	:= 1
		nFolder	:= 1
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	�Deleta Registros com Inconsistencia de Informacoes            �
	����������������������������������������������������������������/*/
	bGdDelNoEmpy := { ||;
							GdSuperDel(;
											aHeader	,;
											@aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS ],;
											NIL		,;
											.T.,;
											aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BDELEMPTY ];
									 );
					}

	/*/
	��������������������������������������������������������������Ŀ
	�Bloco para Separacao das Informacoes que foram Deletadas      �
	����������������������������������������������������������������/*/
	bGdSplitDel := { |lDeleted,lNewDeleted| lNewDeleted := GdSplitDel(;
																		aHeader,;
																		@aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS 		],;
																		@aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS 	],;
																		@aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLSDEL	],;
																		@aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOSDEL	];
			  					  					  				 ),;
											IF( !( lDeleted ) , lDeleted := lNewDeleted , NIL );
					}

	For nFolder := nFolder To nFolders Step nStep
		/*/
		��������������������������������������������������������������Ŀ
		�O Folder Principal eh uma Enchoice e Tem Tratamento diferencia�
		�do														   	   �
		����������������������������������������������������������������/*/
		IF ( nFolder == APDA270_FOLDER_PRINCIPAL )
			Loop
		EndIF
		/*/
		��������������������������������������������������������������Ŀ
		� Percorre Todos os Objetos                                    �
		����������������������������������������������������������������/*/
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER	]
		For nObj := 1 To nObjs
			IF !( lGrava := aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_LGRAVA ] )
				Loop
			EndIF
			/*/
			��������������������������������������������������������������Ŀ
			� Carrega os Objetos que serao Gravados      				   �
			����������������������������������������������������������������/*/
			aAdd( aGravaObjs , { nFolder , nObj , lModItens } )
			nGravaObjs := Len( aGravaObjs )
			/*/
			��������������������������������������������������������������Ŀ
			� Se For Exclusao                                          	   �
			����������������������������������������������������������������/*/
			IF ( cOpcao == "DELETE" )
				aGravaObjs[ nGravaObjs , 3 ] := .T.
				/*/
				��������������������������������������������������������������Ŀ
				� Obtem os Recnos dos Avaliadores que serao Gravados		   �
				����������������������������������������������������������������/*/
				IF ( nFolder == APDA270_FOLDER_AVALIADORES )
					aRdaRecnos := aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS ] )
				EndIF
				Loop
			EndIF
			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o aHeader                                              �
			����������������������������������������������������������������/*/
			aHeader		:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_AHEADER	] )
			nPosRdaRecno := aScan( aHeader , { |x| x[2] == "RDA_REC_WT" } )
			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o conteudo do aCols                                    �
			����������������������������������������������������������������/*/
			aCols := aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS 	] )
			/*/
			��������������������������������������������������������������Ŀ
			� Verifica se houveram Modificacoes                            �
			����������������������������������������������������������������/*/
			aSvCols		:= aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS	] )

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica se Deve Efetuar Ordenamento Antes de Comparar       �
			����������������������������������������������������������������/*/
			lSort	:= ( ValType( bSort := aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BSORT ] ) == "B" )
			IF ( lSort )
				aSort( aCols , NIL , NIL , bSort )
				aSort( aSvCols , NIL , NIL , bSort )
			EndIF
			//-- Com a retirada do GhostCol, foi necessario adicionar as instrucoes abaixo p/ garantir a integridade
			IF nFolder == APDA270_FOLDER_AVALIADORES
				//-- Ordena o array dos Recnos em ordem crescente
				aSort( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOS	] , NIL , NIL , { |x,y| ( x < y ) } )
				//-- Verifica se houve inclusao de novos itens de avaliacao
				If Len(aCols) > Len(aSvCols)
				   	//-- Adiciono os novos itens cadastrados em um array auxiliar
					aEval( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS 	], {|x| If(Empty(x[nPosRdaRecno]), aAdd(aColsAux, aClone(x) ), )  }  )
					//-- Adiciona os itens ja gravados em um array auxiliar
					aEval( aCols, {|x| aAdd(aColsAux2, aClone(x)) }, Len(aColsAux)+1  )
					//-- Reseta o array aCols
					aCols := aClone(aColsAux2)
					//-- Adiciona os novos itens no fim do aCols.
					For nCont := 1 To Len(aColsAux)
					    aAdd( aCols, aClone(aColsAux[nCont]) )
					Next
				EndIf
				//-- Reseta o array principal do aCols com os itens de avaliacao
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ACOLS 	] := aClone( aCols )
				//-- Ordena o array SvCols pelos recnos em ordem crescente
				aSort( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ASVCOLS	] , NIL , NIL , bSort )
			EndIf

			lModItens	:= !( ArrayCompare( aCols , aSvCols ) )
			aGravaObjs[ nGravaObjs , 3 ] := lModItens

			/*/
			��������������������������������������������������������������Ŀ
			�Deleta Registros com Inconsistencia de Informacoes            �
			����������������������������������������������������������������/*/
			Eval( bGdDelNoEmpy )
			/*/
			��������������������������������������������������������������Ŀ
			� Separa os Itens que foram Deletados     					   �
			����������������������������������������������������������������/*/
			Eval( bGdSplitDel , @lDeleted )
			/*/
			��������������������������������������������������������������Ŀ
			� Obtem os Recnos dos Avaliadores que serao Deletados		   �
			����������������������������������������������������������������/*/
			IF ( nFolder == APDA270_FOLDER_AVALIADORES )
				aRdaRecDel := aClone( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_ARECNOSDEL ] )
			EndIF
		Next nObj
	Next nFolder

	/*/
	��������������������������������������������������������������Ŀ
	� Obtem o Codigo da Avaliacao                 				   �
	����������������������������������������������������������������/*/
	cRd6CodAva := GetMemVar( "RD6_CODIGO")

	/*/
	��������������������������������������������������������������Ŀ
	� Se for Alteracao e Existirem Elementos Deletados			   �
	����������������������������������������������������������������/*/
	IF ( ( nOpc == 4 ) .and. ( lDeleted ) )
		/*/
		��������������������������������������������������������������Ŀ
		� Carrega Informacoes dos Itens para Delecao  				   �
		����������������������������������������������������������������/*/
		nObjs := Len( aGravaObjs )
		For nObj := nObjs To 1 Step -1
			IF (;
					aGravaObjs[ nObj , 03 ];
					.and.;
					!Empty( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ARECNOSDEL ] );
				)
				aAdd( aItens , GdPutIStrItens() )
				nItens := Len( aItens )
				aItens[ nItens , 01 ] := aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ALIAS ]
				aItens[ nItens , 02 ] := {}
				aItens[ nItens , 03 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_AHEADER	   ] )
				aItens[ nItens , 04 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ACOLSDEL   ] )
				aItens[ nItens , 05 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_AVIRTUAL   ] )
				aItens[ nItens , 06 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ARECNOSDEL ] )
			EndIF
		Next nObj
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Carrega Informacoes dos Itens para Gravacao 				   �
	����������������������������������������������������������������/*/
	nObjs := Len( aGravaObjs )
	For nObj := 1 To nObjs
		IF aGravaObjs[ nObj , 03 ]
			aAdd( aItens , GdPutIStrItens() )
			nItens := Len( aItens )
			aItens[ nItens , 01 ] := aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ALIAS ]
			aItens[ nItens , 02 ] := {;
										{ "FILIAL" , xFilial( aItens[ nItens , 01 ] , xFilial( cAliasMestre ) ) },;
				 				 	  	{ cRd6CodAva															};
				 				 	  }
			aItens[ nItens , 03 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_AHEADER	] )
			aItens[ nItens , 04 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ACOLS	] )
			aItens[ nItens , 05 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_AVIRTUAL] )
			aItens[ nItens , 06 ] := aClone( aFolders[ aGravaObjs[ nObj , 01 ] , APDA270_FOLDER_OBJECTS , aGravaObjs[ nObj , 02 ] , APDA270_ARECNOS	] )
		EndIF
	Next nObj

	/*/
	��������������������������������������������������������������Ŀ
	� Atualiza aCols para Verificar se Houveram Alteracoes	   	   �
	� do RD6 de acordo com o conteudo do folder principal          �
	����������������������������������������������������������������/*/
	aVirtual    := aClone( aFolders[ APDA270_FOLDER_PRINCIPAL , APDA270_FOLDER_OBJECTS , 01 , APDA270_AVIRTUAL	] )
	aCols		:= aClone( aFolders[ APDA270_FOLDER_PRINCIPAL , APDA270_FOLDER_OBJECTS , 01 , APDA270_ACOLS		] )
	aSvCols		:= aClone( aFolders[ APDA270_FOLDER_PRINCIPAL , APDA270_FOLDER_OBJECTS , 01 , APDA270_ASVCOLS	] )
	aHeader		:= aClone( Rd6HeaderGet() )
	nLoops := Len( aHeader )
	For nLoop := 1 To nLoops
		aCols[ 01 , nLoop ] := GetMemVar( aHeader[ nLoop , 02 ] )
	Next nLoop

	/*/
	��������������������������������������������������������������Ŀ
	� Se for Exclusao ou Se Houveram Alteracoes					   �
	����������������������������������������������������������������/*/
	lModMestre := (;
						( nOpc == 5 );
						.or.;
						!( ArrayCompare( aCols , aSvCols ) );
				  )

	/*/
	��������������������������������������������������������������Ŀ
	� Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ou�
	� se foi Selecionada a Exclusao								   �
	����������������������������������������������������������������/*/
	aMestre[ 01 , 01 ]	:= cAliasMestre
	aMestre[ 01 , 02 ]	:= nReg
	aMestre[ 01 , 03 ]	:= lModMestre
	aMestre[ 01 , 04 ]	:= aClone( aHeader )
	aMestre[ 01 , 05 ]	:= aClone( aVirtual )
	aMestre[ 01 , 06 ]	:= {}
	aMestre[ 01 , 07 ]	:= aClone( aItens )

	/*/
	��������������������������������������������������������������Ŀ
	� Atualiza aCols para Verificar se Houveram Alteracoes	   	   �
	� do RD6 de acordo com o conteudo do folder agenda             �
	����������������������������������������������������������������/*/
	aVirtual    := aClone( aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 01 , APDA270_AVIRTUAL	] )
	aCols		:= aClone( aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 01 , APDA270_ACOLS	] )
	aSvCols		:= aClone( aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 01 , APDA270_ASVCOLS	] )
	aHeader		:= aClone( Rd6FAHeaderGet() )
	nLoops := Len( aHeader )
	For nLoop := 1 To nLoops
		aCols[ 01 , nLoop ] := GetMemVar( aHeader[ nLoop , 02 ] )
	Next nLoop

	/*/
	��������������������������������������������������������������Ŀ
	� Seta a Gravacao Apenas se Houveram Alteracoes                �
	����������������������������������������������������������������/*/
	aMestre2[ 01 , 01 ]	:= cAliasMestre
	aMestre2[ 01 , 02 ]	:= nReg
	aMestre2[ 01 , 03 ]	:= lModMestre
	aMestre2[ 01 , 04 ]	:= aClone( aHeader )
	aMestre2[ 01 , 05 ]	:= aClone( aVirtual )
	aMestre2[ 01 , 06 ]	:= {}
	aMestre2[ 01 , 07 ]	:= {}

	/*/
	��������������������������������������������������������������Ŀ
	� Se for Delecao                               				   �
	����������������������������������������������������������������/*/
	IF ( cOpcao == "DELETE" )
		/*/
		��������������������������������������������������������������Ŀ
		� Exclui as Informacoes do RDC                 				   �
		����������������������������������������������������������������/*/
        nLoops	:= Len( aRdaRecnos )
        For nLoop := 1 To nLoops
			RDA->( dbGoto( aRdaRecnos[ nLoop ] ) )
			IF ( aRdaRecnos[ nLoop ] == RDA->( Recno() ) )
				aAdd(aRecGrv , {aRdaRecnos[nLoop],.T.} )
			EndIF
		Next nLoop
		/*/
		��������������������������������������������������������������Ŀ
		� Grava as demais Informacoes do RD6 no Folder Agenda 		   �
		����������������������������������������������������������������/*/
		//GdPutInfoData( aMestre2 , cOpcao , .F. , .F. )
		/*/
		��������������������������������������������������������������Ŀ
		� Exclui as Demais informacoes                 				   �
		����������������������������������������������������������������/*/
		GdPutInfoData( aMestre , cOpcao , .F. , .F. )
	Else
		/*/
		��������������������������������������������������������������Ŀ
		� Exclui as Informacoes do RDC se Houveram Delecoes			   �
		����������������������������������������������������������������/*/
        IF (;
        		( nOpc == 4 );
        		.and.;
        		( lDeleted );
        		.and.;
        		!Empty( aRdaRecDel );
       		 )
        	nLoops	:= Len( aRdaRecDel )
        	For nLoop := 1 To nLoops
				RDA->( dbGoto( aRdaRecDel[ nLoop ] ) )
				IF ( aRdaRecDel[ nLoop ] == RDA->( Recno() ) )
					aAdd(aRecGrv , {aRdaRecDel[nLoop],.T.} )
				EndIF
			Next nLoop
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Grava as demais Informacoes do RD6 no Folder Principal       �
		����������������������������������������������������������������/*/
		GdPutInfoData( aMestre , cOpcao , .F. , .F. , Nil , Nil , @nReg )

		/*/
		��������������������������������������������������������������Ŀ
		� Recupera o recno na insers�o das demais Informacoes do RD6   �
		� relativo ao Folder Principal                                 �
		����������������������������������������������������������������/*/
		If aMestre2[ 01 , 02 ] == 0 .OR. Empty(aMestre2[ 01 , 02 ])
			aMestre2[1][2]	:= nReg
		EndIf

		/*/
		��������������������������������������������������������������Ŀ
		� Grava as demais Informacoes do RD6 no Folder Agenda 		   �
		����������������������������������������������������������������/*/
		GdPutInfoData( aMestre2 , cOpcao , .F. , .F. )

		/*/
		��������������������������������������������������������������Ŀ
		� Grava as Informacoes no RDC em funcao do RDA				   �
		����������������������������������������������������������������/*/
		cKey 		:= ( xFilial( "RDA" ) + cRd6CodAva )
		aRdaRecnos	:= {}
		GDBuildCols(	@__aRdaHeader__	,;	//01 -> Array com os Campos do Cabecalho da GetDados
						NIL				,;	//02 -> Numero de Campos em Uso
						NIL				,;	//03 -> [@]Array com os Campos Virtuais
						NIL				,;	//04 -> [@]Array com os Campos Visuais
						"RDA"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
						NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
						@aRdaRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
						"RDA"			,;	//08 -> Alias do Arquivo Pai
						cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
						NIL				,;	//10 -> Bloco para condicao de Loop While
						NIL				,;	//11 -> Bloco para Skip no Loop While
						.F.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
						.F.				,;	//13 -> Se Sera considerado o Inicializador Padrao
						.F.				,;	//14 -> Opcional, Carregar Todos os Campos
						.T.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
						NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
						.T.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
						.T.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
						.F.				,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
						.F.				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
						.T.				,;	//21 -> Verifica se Deve Checar se o campo eh usado
						.F.				,;	//22 -> Verifica se Deve Checar o nivel do usuario
						.T.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
						NIL				,;	//24 -> [@]Array que contera as chaves conforme recnos
						NIL				,;	//25 -> [@]Se devera efetuar o Lock dos Registros
						NIL				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
						NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
						.T.				,;	//28 -> Utiliza Numeracao na GhostCol
						NIL				,;	//29 ->
						NIL				,;	//30 ->
						nOpc			;	//31 ->
				)
        nLoops	:= Len( aRdaRecnos )
        For nLoop := 1 To nLoops
			RDA->( dbGoto( aRdaRecnos[ nLoop ] ) )
			IF ( aRdaRecnos[ nLoop ] == RDA->( Recno() ) )
				aAdd(aRecGrv , {aRdaRecnos[nLoop],.F.} )
			EndIF
		Next nLoop
	EndIF

	If !Empty(aRecGrv)
		aRecGrv := MntThread(aRecGrv) //Verifica existencia de multi-threads e remonta array

		If Len(aRecGrv) > 1

			RDA->(DbCloseArea())

			For nLoop:=1 to Len(aRecGrv)

				IncProc()

				// Informacoes do semaforo
				cJobFile:= cStartPath + CriaTrab(Nil,.F.)+".job"

				// Adiciona o nome do arquivo de Job no array aJobAux
				aAdd(aJobAux,{StrZero(nLoop,2),cJobFile})

				// Inicializa variavel global de controle de thread
				cJobAux:="PD080"+cEmpAnt+cFilAnt+StrZero(nLoop,2)
				PutGlbValue(cJobAux,"0")
				GlbUnLock()

				//�������������������Ŀ
				//� Dispara thread    �
				//���������������������
				StartJob("APDA270Thread",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aRecGrv[nLoop,1],cJobFile,StrZero(nLoop,2))

			Next nLoop

			//���������������������������������������������������������������������������Ŀ
			//� Controle de Seguranca para MULTI-THREAD                                   �
			//�����������������������������������������������������������������������������
			For nLoop:=1 to Len(aRecGrv)

				nPos := aScan(aJobAux,{|x| x[1] == StrZero(nLoop,2)})

				// Informacoes do semaforo
				cJobFile:= aJobAux[nPos,2]

				// Inicializa variavel global de controle de thread
				cJobAux:="PD080"+cEmpAnt+cFilAnt+StrZero(nLoop,2)

				While .T.
					Do Case
						// TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
						Case GetGlbValue(cJobAux) == '0'
							If nRetry_0 > 50
								Conout(Replicate("-",65))				  					//"-----------------------------------------------------"
								Conout("APDA270: " + STR0147 + " " + StrZero(nLoop,2) )	//"APDA270: N�o foi possivel realizar a subida da thread"
								Conout(Replicate("-",65))  									//"-----------------------------------------------------"
								//���������������������������������������������Ŀ
								//� Atualiza o log de processamento			    �
								//�����������������������������������������������
								Final(STR0147) 	 											//"N�o foi possivel realizar a subida da thread"
							Else
								nRetry_0 ++
							EndIf
						// TRATAMENTO PARA ERRO DE CONEXAO
						Case GetGlbValue(cJobAux) == '1'
							If FCreate(cJobFile) # -1
								If nRetry_1 > 5
									Conout(Replicate("-",65)) 						//"------------------------------------------------"
									Conout("APDA270: " + STR0148 ) 					//"APDA270: Erro de conexao na thread"
									Conout(STR0149 + StrZero(nLoop,2) )				//"Thread numero : "
									Conout(STR0150)									//"Numero de tentativas excedidas"
									Conout(Replicate("-",65))  						//"------------------------------------------------"
									//���������������������������������������������Ŀ
									//� Atualiza o log de processamento			    �
									//�����������������������������������������������
									Final("APDA270: " + STR0148)   					//"APDA270: Erro de conexao na thread"
								Else
					    			// Inicializa variavel global de controle de Job
									PutGlbValue(cJobAux, "0" )
									GlbUnLock()
									// Reiniciar thread
									Conout(Replicate("-",65))				 				//"------------------------------------------------"
									Conout("APDA270: " + STR0148 ) 							//"APDA270: Erro de conexao na thread"
									Conout(STR0151	+ StrZero(nRetry_1,2))					//"Tentativa numero: "
									Conout(STR0152 + StrZero(nLoop,2))						//"Reiniciando a thread : "
									Conout(Replicate("-",65))                 				//"------------------------------------------------"
									//���������������������������������������������Ŀ
									//� Dispara thread para Stored Procedure        �
									//�����������������������������������������������
									StartJob("APDA270Thread",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aRecGrv[nLoop,1],cJobFile,StrZero(nLoop,2))
								EndIf
								nRetry_1 ++
							EndIf
						// TRATAMENTO PARA ERRO DE APLICACAO
						Case GetGlbValue(cJobAux) == '2'
							If FCreate(cJobFile) # -1
								Conout(Replicate("-",65))						//"-------------------------------------------------"
								Conout("APDA270: " + STR0153 )					//"APDA270: Erro de aplicacao na thread"
								Conout(STR0149 + StrZero(nLoop,2))				//"Thread numero : "
								Conout(Replicate("-",65))  						//"--------------------------------------------------"
								//���������������������������������������������Ŀ
								//� Atualiza o log de processamento			    �
								//�����������������������������������������������
								Final("APDA270: " + STR0153) 					//"APDA270: Erro de aplicacao na thread"
							EndIf
						// THREAD PROCESSADA CORRETAMENTE
						Case GetGlbValue(cJobAux) == '3'
							IncProc()
							Exit
					EndCase
					Sleep(2500)
				End
			Next nLoop
		Else
			nLoops  := Len(aRecGrv[1])
			For nLoop := 1 to nLoops
				RDA->( dbGoto( aRecGrv[1][nLoop][1] ) )
				If RDA->( RecLock( "RDA" , .F. ) )

					a270Rda2RdcPut(aRecGrv[1][nLoop][2])

					RDA->( MsUnLock() )

					If !aRecGrv[1][nLoop][2]
						RDA->( FkCommit() )
					EndIf
				EndIf
			Next nLoop
		EndIf
	EndIf

	// Grava ou Exclui Informacoes do SXM
	If !lBldAvaAuto .And. RDP->RDP_TIPENV != "3" // N�o envia aviso nem avaliacao
		Rd6PutSxm( ( nOpc ) )
	EndIf

	/*/
	��������������������������������������������������������������Ŀ
	� Confirmando a Numeracao Automatica          				   �
	����������������������������������������������������������������/*/
	While ( GetSX8Len() > nGetSX8Len )
		ConfirmSX8()
	End While

End Sequence

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �a270Rda2RdcPut	�Autor�Marinaldo de Jesus � Data �24/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Grava as infrormacoes no RDC com base nos dados do RD9      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270														�
�������������������������������������������������������������������������/*/
Function a270Rda2RdcPut( lDelete )

Local lRdcFound		:= .F.
Local lPutOrDelOk	:= .T.
Local lRdcInitPad	:= .F.

Local aChrDelStr
Local aRdaFields
Local aRdaFldPos
Local aRdcFields
Local aRdcFldPos

Local bInitPad

Local cInitPad
Local cIndexKey
Local cValType
Local cMsgErr
Local cRdcFil
Local cRdpFil
Local cRdpIndex
Local cTipoAv
Local cKeySeek

Local dRdcDtLimR

Local lIsInGetDados

Local nRdcOrder
Local nRdpOrder
Local nFieldPos
Local nLoop
Local nLoops

Local uCntPut

Static aRdcHeader
Static aRdaHeader

DEFAULT lDelete	:= .F.

Begin Sequence

	cRdcFil		:= xFilial( "RDC" )
	cIndexKey	:= "RDC_FILIAL+RDC_CODAVA+RDC_CODADO+RDC_CODPRO+RDC_CODDOR+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV"
	nRdcOrder	:= RetOrdem( "RDC" , cIndexKey )

	aChrDelStr	:= { "DTOS" , "STR" , "STRZERO" , "(" , ")" }

	RDC->( dbSetOrder( nRdcOrder ) )
	cIndexKey	:= StrTran( RDC->( IndexKey() ) , " " , "" )
	cIndexKey	:= StrTran( cIndexKey , "RDC_FILIAL" , "" )
	aRdcFields	:= StrToArray( cIndexKey , "+" , { | cString | StrDelChr( @cString , aChrDelStr ) , .T. } )
	nLoops		:= Len( aRdcFields )

	IF !( lPutOrDelOk := ( nLoops > 0 ) )
		Break
	EndIF

	aRdcFldPos := {}
	For nLoop := 1 To nLoops
		IF ( ( nFieldPos := RDC->( FieldPos( aRdcFields[ nLoop ] ) ) ) > 0 )
			aAdd( aRdcFldPos , {;
									aRdcFields[ nLoop ],;
									nFieldPos,;
									NIL,;
									StrTran( aRdcFields[ nLoop ] , "RDC_" , "" );
								};
				)
		EndIF
	Next nLoop

	IF Empty( aRdcHeader )
		aRdcHeader := GdMontaHeader(	NIL				,;	//01 -> Por Referencia contera o numero de campos em Uso
										NIL				,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
										NIL				,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
										"RDC"			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
										{"RDC_FILIAL"}	,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
										.F.				,;	//06 -> Opcional, Carregar Todos os Campos
										.T.			 	,;	//07 -> Nao Carrega os Campos Virtuais
										.F.				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
										NIL				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
										.F.				,;	//10 -> Verifica se Deve Checar se o campo eh usado
										.F.				,;	//11 -> Verifica se Deve Checar o nivel do usuario
										.F.				 ;	//12 -> Utiliza Numeracao na GhostCol
					  	 			)
	EndIF

	nLoops := Len( aRdcHeader )
	For nLoop := 1 To nLoops
		IF ( ( aScan( aRdcFldPos , { |x| ( x[1] == aRdcHeader[ nLoop , 2 ]  ) } ) ) == 0 )
			IF ( ( nFieldPos := RDC->( FieldPos( aRdcHeader[ nLoop , 2 ] ) ) ) > 0 )
				aAdd( aRdcFldPos , {;
										aRdcHeader[ nLoop , 2 ],;
										nFieldPos,;
										NIL,;
										StrTran( aRdcHeader[ nLoop , 2 ] , "RDC_" , "" );
									};
					)
			EndIF
		EndIF
	Next nLoop

	cIndexKey	:= StrTran( cIndexKey , "RDC_" , "RDA_" )
	cIndexKey	:= StrTran( cIndexKey , "RDA_FILIAL" , "" )
	aRdaFields	:= StrToArray( cIndexKey , "+" , { | cString | StrDelChr( @cString , aChrDelStr ) , .T. } )
	cKeySeek	:= ""

	nLoops		:= Len( aRdaFields )
	IF !( lPutOrDelOk := ( nLoops > 0 ) )
		Break
	EndIF

	aRdaFldPos	:= {}
	lIsInGetDados := IsInGetDados( { "RDA_CODADO" } )

	For nLoop := 1 To nLoops
		IF ( lIsInGetDados )
			nFieldPos := GdFieldPos( aRdaFields[ nLoop ] )
		Else
			nFieldPos := RDA->( FieldPos( aRdaFields[ nLoop ] ) )
		EndIF

		IF ( nFieldPos == 0 )
			Loop
		EndIF

		IF ( lIsInGetDados )
			uCntPut 	:= aCols[ n , nFieldPos ]
			cValType	:= aHeader[ nFieldPos , 8 ]
			nFieldPos	:= RDA->( FieldPos( aRdaFields[ nLoop ] ) )
		Else
			uCntPut		:= RDA->( FieldGet( nFieldPos ) )
			cValType	:= ValType( uCntPut )
		EndIF

		IF ( aRdaFields[ nLoop ] == "RDA_TIPOAV" )
			cTipoAv := uCntPut
		EndIF

		aAdd( aRdaFldPos , {;
								aRdaFields[ nLoop ],;
								nFieldPos,;
								uCntPut,;
								StrTran( aRdaFields[ nLoop ] , "RDA_" , "" );
							};
			)

		IF ( cValType == "C" )
			cKeySeek += uCntPut
		ElseIF ( cValType == "D" )
			cKeySeek += Dtos( uCntPut )
		EndIF
	Next nLoop

	IF Empty( cKeySeek )
		Break
	EndIF

	IF Empty( aRdaHeader )
		aRdaHeader := GdMontaHeader(	NIL				,;	//01 -> Por Referencia contera o numero de campos em Uso
										NIL				,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
										NIL				,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
										"RDA"			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
										{"RDA_FILIAL"}	,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
										.F.				,;	//06 -> Opcional, Carregar Todos os Campos
										.T.			 	,;	//07 -> Nao Carrega os Campos Virtuais
										.F.				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
										NIL				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
										.F.				,;	//10 -> Verifica se Deve Checar se o campo eh usado
										.F.				,;	//11 -> Verifica se Deve Checar o nivel do usuario
										.F.				 ;	//12 -> Utiliza Numeracao na GhostCol
					  	 			)
	EndIF

	nLoops := Len( aRdaHeader )
	For nLoop := 1 To nLoops
		IF ( ( aScan( aRdaFldPos , { |x| ( x[1] == aRdaHeader[ nLoop , 2 ]  ) } ) ) > 0 )
			Loop
		EndIF
		IF ( lIsInGetDados )
			nFieldPos := GdFieldPos( aRdaHeader[ nLoop , 2 ] )
		Else
			nFieldPos := RDA->( FieldPos( aRdaHeader[ nLoop , 2 ] ) )
		EndIF
		IF ( nFieldPos == 0 )
			Loop
		EndIF
		IF ( lIsInGetDados )
			uCntPut		:= aCols[ n , nFieldPos ]
			nFieldPos	:= RDA->( FieldPos( aRdaHeader[ nLoop , 2 ] ) )
		Else
			uCntPut	:= RDA->( FieldGet( nFieldPos ) )
		EndIF
		aAdd( aRdaFldPos , {;
								aRdaHeader[ nLoop , 2 ],;
								nFieldPos,;
								uCntPut,;
								StrTran( aRdaHeader[ nLoop , 2 ] , "RDA_" , "" );
							};
			)
	Next nLoop

	IF !( lPutOrDelOk := (;
								( Len( aRdaFields ) > 0 );
								.and.;
								( Len( aRdcFields ) > 0 );
						  );
		)
		Break
	EndIF

	cRdcFil		:= xFilial( "RDC" , xFilial( "RDA" ) )
	cKeySeek	:= ( cRdcFil + cKeySeek )

	RDC->( dbSetOrder( nRdcOrder ) )
	IF RDC->( !( lRdcFound := dbSeek( cKeySeek , .F. ) ) )
		IF ( lDelete )
			Break
		EndIF
	EndIF

	nLoops		:= Len( aRdaFields )
	IF !( lPutOrDelOk := ( nLoops > 0 ) )
		Break
	EndIF

	IF !( lDelete )

		cRdpIndex	:= "RDP_FILIAL+RDP_CODAVA+DTOS(RDP_DATINI)"
		cIndexKey	:= StrTran( cRdpIndex, "RDP_" , "RDA_" )
		cIndexKey	:= StrTran( cIndexKey , "RDA_FILIAL" , "" )
		cIndexKey	:= StrTran( cIndexKey , "DATINI" , "DTIAVA" )
		aRdaFields	:= StrToArray( cIndexKey , "+" , { | cString | StrDelChr( @cString , aChrDelStr ) , .T. } )
		cKeySeek	:= ""

		nLoops		:= Len( aRdaFields )
		IF !( lPutOrDelOk := ( nLoops > 0 ) )
			Break
		EndIF

		For nLoop := 1 To nLoops
			IF ( lIsInGetDados )
				nFieldPos := GdFieldPos( aRdaFields[ nLoop ] )
			Else
				nFieldPos := RDA->( FieldPos( aRdaFields[ nLoop ] ) )
			EndIF
			IF ( nFieldPos == 0 )
				Loop
			EndIF
			IF ( lIsInGetDados )
				uCntPut 	:= aCols[ n , nFieldPos ]
				cValType	:= aHeader[ nFieldPos , 8 ]
			Else
				uCntPut		:= RDA->( FieldGet( nFieldPos ) )
				cValType	:= ValType( uCntPut )
			EndIF
			IF ( cValType == "C" )
				cKeySeek += uCntPut
			ElseIF ( cValType == "D" )
				cKeySeek += Dtos( uCntPut )
			EndIF
		Next nLoop

		IF Empty( cKeySeek )
			Break
		EndIF

		nRdpOrder	:= RetOrdem( "RDP" , cRdpIndex )
		cRdpFil		:= xFilial( "RDP" , xFilial( "RDA" ) )
		cKeySeek	:= ( cRdpFil + cKeySeek )
		RDP->( dbSetOrder( nRdpOrder ) )
		RDP->( MsSeek( cKeySeek , .F. ) )

	EndIF

	IF RDC->( RecLock( "RDC" , !( lRdcFound ) ) )

		IF ( lDelete )
			IF !( lPutOrDelOk := RDC->( FkDelete( @cMsgErr ) ) )
				RDC->( RollBackDelTran( cMsgErr ) )
			EndIF
			RDC->( MsUnLock() )
			Break
		EndIF

		DEFAULT cTipoAv := "1"

		IF ( cTipoAv == "1" )
			dRdcDtLimR := RDP->RDP_RSPDOR
		ElseIF ( cTipoAv == "2" )
			dRdcDtLimR := RDP->RDP_RSPADO
		ElseIF ( cTipoAv == "3" )
			dRdcDtLimR := RDP->RDP_RSPCON
		EndIF

		RDC->RDC_FILIAL := cRdcFil
		nLoops := Len( aRdcFldPos )
		For nLoop := 1 To nLoops
			IF ( ( nFieldPos := aScan( aRdaFldPos , { |x| x[4] == aRdcFldPos[ nLoop , 4 ] } ) ) == 0 )
				nFieldPos := GdFieldPos( aRdcFldPos[ nLoop , 1 ] , aRdcHeader )
				IF (;
						( nFieldPos == 0 );
						.or.;
						Empty( cInitPad := aRdcHeader[ nFieldPos , 12 ] );
					)
					Loop
				EndIF
				bInitPad	:= &( " { || uCntPut := " + cInitPad + " } " )
				IF !( lRdcInitPad := CheckExecForm( bInitPad , .F. ) )
					Loop
				EndIF
			Else
				uCntPut := aRdaFldPos[ nFieldPos , 3 ]
			EndIF
			IF (;
					( lRdcFound );
					.and.;
					( lRdcInitPad );
				 )
				lRdcInitPad := .F.
				IF !Empty( RDC->( FieldGet( aRdcFldPos[ nLoop , 2 ] ) ) )
					Loop
				EndIF
			EndIF
			RDC->( FieldPut( aRdcFldPos[ nLoop , 2 ] , uCntPut ) )
		Next nLoop
		IF Empty( RDC->RDC_ID )
			RDC->( FieldPut( FieldPos( "RDC_ID" ) , RdcIdInit() ) )
		EndIF
		RDC->( FieldPut( FieldPos( "RDC_ATIVO" ) , RdcAtivoInit() ) )
		RDC->( FieldPut( FieldPos( "RDC_DTLIMR" ) , dRdcDtLimR ) )
		RDC->( MsUnLock() )
		RDC->( FkCommit() )
	EndIF

End Sequence

Return( lPutOrDelOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PutSxm       �Autor�Marinaldo de Jesus � Data �15/10/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Grava Informacoes no SXM   								    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd6PutSxm( nOpc )

	Local lDelete 		:= ( nOpc == 5 )
	Local lAltera 		:= ( nOpc == 4 )
	Local aParams		:= {}
	Local cAgdCp1
	Local cAgdCp2
	Local nI
	Local oDASchedule 	:= FWDASchedule():new()
	Local oSchedule 	:= FWVOSchedule():new()
	Local lCpoAgend		:= ( RD6->(ColumnPos( "RD6_AGDSCH" )) == 0 ) .Or. ( RD6->(ColumnPos( "RD6_AGDENV" )) == 0 )

	If ! lCpoAgend

		Begin Sequence

			aAdd( aParams, 'APDA270Sch( "' + GetMemVar( "RD6_CODIGO" ) + '", "' + DToS(GetMemVar( "RD6_DTINI" )) + '", "' + DToS(GetMemVar( "RD6_DTFIM" )) + '")')
			aAdd( aParams, 'ApdChkEnv()')

			If !( lDelete )	//Inclus�o ou Altera��o
				If lAltera		// Altera��o
					// Como n�o h� m�todo para alterarmos o Agendamento, deletamos e incluimos novamente no caso de Altera��o.
					cAgdCp1 := RD6->RD6_AGDSCH
					cAgdCp2 := RD6->RD6_AGDENV
					If !Empty(cAgdCp1) .AND. !Empty(cAgdCp2)
						FWDelSchedule( cAgdCp1 )
						FWDelSchedule( cAgdCp2 )
					EndIf
				EndIf
				For nI := 1 To Len(aParams)

					If nI == 1
						cAgdCp1 := oSchedule:cID := oDASchedule:getNextID()
					Else
						cAgdCp2 := oSchedule:cID := oDASchedule:getNextID()
					EndIf

					oSchedule:cUserID 	:= RetCodUsr()
					oSchedule:cFunction := Upper(AllTrim(aParams[ nI ]))
					oSchedule:cPeriod 	:= "D(EveryDay(.T.););Execs(01);Interval(00:00);End(" + DtoS(GetMemVar( "RD6_DTFIM" )) + ");"
					oSchedule:cTime 	:= "00:00"
					oSchedule:cParam 	:= ""
					oSchedule:cEnv 		:= Upper(AllTrim(GetEnvServer()))
					oSchedule:cEmpFil 	:= cEmpAnt + "/" + cFilAnt + ";"
					oSchedule:cStatus 	:= If( GetMemVar( "RD6_STATUS" ) == "1", "0", "1" )
					oSchedule:dDate 	:= GetMemVar( "RD6_DTINI" )
					oSchedule:nModule 	:= nModulo

					oDASchedule:insertSchedule( oSchedule )

					oSchedule:reset()

				Next

				If RD6->( RecLock( "RD6", .F. ))
					RD6->RD6_AGDSCH := cAgdCp1
					RD6->RD6_AGDENV := cAgdCp2
					RD6->( MsUnLock())
				EndIf

			Else	//Exclus�o
				cAgdCp1 := RD6->RD6_AGDSCH
				cAgdCp2 := RD6->RD6_AGDENV
				If !Empty(cAgdCp1) .AND. !Empty(cAgdCp2)
					FWDelSchedule( cAgdCp1 )
					FWDelSchedule( cAgdCp2 )
				EndIf
			EndIf

		End Sequence
	EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270SetOption�Autor�Marinaldo de Jesus � Data �29/10/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida a Mudanca de Folder								    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function APDA270SetOption(	nOpc			,;	//Opcao do aRotina
									nNewFolder		,;	//Folder Para o Qual se Vai
									nLastFolder		,;	//Folder de Onde se Vem
									lValidFolder	,;	//Se Havera Validacao dos Folders
									lAllFoldersOk	,;	//Se Todos os Folders deverao ser Validados
									lGdSeek			,;	//Se Ira Disponibilizar Pesquisa na GetDados
									nActFolder		 ;	//Folder Ativo
								 )

Local cObjType		:= ""
Local lIsObject		:= .F.
Local lExecValid	:= ( ( nOpc == 3 ) .or. ( nOpc == 4  ) )
Local lSetOption	:= .T.
Local nFolder		:= 0
Local nFolders		:= Len( aFolders )
Local nObj			:= 0
Local nObjs			:= 0
Local nSetOption	:= 0
Local cRd5Tipo		:= Posicione("RD5",1,xFilial("RD5")+GetMemVar( "RD6_CODTIP" ),"RD5_TIPO")
Local aNaoAltera    := {}
DEFAULT lValidFolder	:= .T.
DEFAULT lAllFoldersOk	:= .F.

lGdSeek	:= .F.

IF ( ( lExecValid ) .and. ( lValidFolder ) )
	For nFolder := nLastFolder To nLastFolder
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER ]
		For nObj := 1 To nObjs
			IF ( lIsObject := ( ValType( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] ) == "O" ) )
				IF !( lSetOption := Eval(;
											aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BVALID		],;
											aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ	],;
											aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ 		];
										 );
					 )
					Exit
				EndIF
			EndIF
		Next nObj

		IF !( lSetOption )
			nSetOption	:= nFolder
			Exit
		EndIF
	Next nFolder
EndIF

IF !( lSetOption )
	For nFolder := 1 To nFolders
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER ]
		For nObj := 1 To nObjs
			IF ( lIsObject := ( ValType( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] ) == "O" ) )
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:Hide()
			EndIF
		Next nObj
	Next nFolder
	For nFolder := nSetOption To nSetOption
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER ]
		For nObj := 1 To nObjs
			IF ( lIsObject := ( ValType( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] ) == "O" ) )
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:Show()
			EndIF
		Next nObj
		Exit
	Next nFolder
ElseIF !( lAllFoldersOk )
	For nFolder := 1 To nFolders
		nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER ]
		For nObj := 1 To nObjs
			IF ( lIsObject := ( ValType( aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] ) == "O" ) )
				aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:Hide()
			EndIF
			IF ( nFolder == nNewFolder )
				IF ( lIsObject )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:Show()
				EndIF
				cObjType := aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_TIPO_OBJ ]
				Eval(;
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BINIT		],;
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ 		];
					 )
				IF ( lIsObject )
					aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:Refresh()
					IF ( !( lExecValid ) .and. ( cObjType == "B" ) )
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ]:Disable()
					EndIF
				EndIF
			ElseIF ( nLastFolder == nFolder )
				IF ( lIsObject )
					Eval(;
							aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT 		],;
							aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ 		];
						 )
				EndIF
			EndIF
		Next nObj
	Next nFolder
EndIF

IF ( lExecValid )
	IF ( ( lSetOption ) .and. ( lAllFoldersOk ) )
		For nFolder := nLastFolder To nLastFolder
			nObjs := aFolders[ nFolder , APDA270_FOLDER_OBJ_NUMBER ]
			For nObj := 1 To nObjs
				Eval(;
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_BEXIT 		],;
						aFolders[ nFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ 		];
					 )
			Next nObj
		Next nFolder
	EndIF
EndIF

IF ( nSetOption == 0 )
	IF ( lSetOption )
		nSetOption	:= nNewFolder
	Else
		nSetOption	:= nLastFolder
	EndIF
EndIF
lGdSeek		:= ( aScan( aFolders[ nSetOption , APDA270_FOLDER_OBJECTS ] , { |x| ( x[ APDA270_TIPO_OBJ ] == "G" ) } ) > 0 )
nActFolder	:= nSetOption

Return( lSetOption )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRd9Init	 	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init da GetDados de Avaliados  								�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function GdRd9Init( oGdRd9 )

GdRdpRd9Chg( .T. , .F. )

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRdhRdaInit	 �Autor�Marinaldo de Jesus� Data �25/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init da GetDados de Avaliados/Rede no Folder Avaliadores	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function GdRdhRdaInit(	oObjGd		,;	//Objeto GetDados
								lGdRd9		,;	//Se o Objeto GetDados em questao refere-se aos Avaliados
								lRdhExeChg  ,;	//Se o Objeto Nao For GetDados Define se Havera a Execucao do Change da Rede
								aHeader		,;	//Array com o Cabecalho
								aCols		,;	//Array com os Itens
								nOpc		;
							  )

Local aVirtual  		:= {}
Local aVisual			:= {}
Local aNotFields		:= {}
Local aRecnos			:= {}
Local bSkip				:= { || .F. }
Local bKey				:= NIL
Local cKey				:= "__cKey__"
Local cRd6CodTip		:= ""
Local lIsObjGd			:= ( ValType( oObjGd ) == "O" )
Local lRebuildCodTip	:= .F.
Local lCodTipIsEmpty	:= .F.
Local nUsado			:= 0

DEFAULT lGdRd9			:= .T.
DEFAULT lRdhExeChg		:= .T.


IF ( lGdRd9 )
	IF ( lIsObjGd )
		oObjGd:aHeader	:= aFolders[APDA270_FOLDER_AVALIADOS,APDA270_FOLDER_OBJECTS,2,APDA270_OBJ]:aHeader
		oObjGd:aCols	:= aFolders[APDA270_FOLDER_AVALIADOS,APDA270_FOLDER_OBJECTS,2,APDA270_OBJ]:aCols
		oObjGd:oBrowse:SetFocus()
	EndIF
ElseIF !( lGdRd9 )
	cRd6CodTip := GetMemVar( "RD6_CODTIP" )
	IF ( lCodTipIsEmpty := Empty( cRd6CodTip ) )
		cRd6CodTip := "ISEMPTYRDTCCODTIP"
	EndIF
	IF ( lRebuildCodTip := ( Empty( cCdTipRd6Lst ) .or. !( cCdTipRd6Lst == cRd6CodTip ) ) )
		cCdTipRd6Lst := cRd6CodTip
	EndIF
	IF ( ( lRebuildCodTip ) .or. ( lCodTipIsEmpty ) )
		aVirtual 	:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , APDA270_AVIRTUAL		]
		aVisual 	:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , APDA270_AVISUAL		]
		aNotFields	:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , APDA270_ANOTFIELDS	]
		nUsado		:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , APDA270_NUSADO		]
		cKey		:= ( xFilial( "RDH" ) + cRd6CodTip )
		IF ( lIsObjGd )
			aHeader := oObjGd:aHeader
		Else
			aHeader := aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , APDA270_AHEADER		]
		EndIF
		/*/
		��������������������������������������������������������������Ŀ
		� Carrega as Informacoes   									   �
		����������������������������������������������������������������/*/
	 	aCols := GDBuildCols(	@aHeader	,;	//01 -> Array com os Campos do Cabecalho da GetDados
								@nUsado		,;	//02 -> Numero de Campos em Uso
								aVirtual	,;	//03 -> [@]Array com os Campos Virtuais
								aVisual		,;	//04 -> [@]Array com os Campos Visuais
								"RDH"		,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
								aNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
								@aRecnos	,;	//07 -> [@]Array unidimensional contendo os Recnos
								"RDH"		,;	//08 -> Alias do Arquivo Pai
								cKey		,;	//09 -> Chave para o Posicionamento no Alias Filho
								bKey		,;	//10 -> Bloco para condicao de Loop While
								bSkip		,;	//11 -> Bloco para Skip no Loop While
								.T.			,;	//12 -> Se Havera o Elemento de Delecao no aCols
								.T.			,;	//13 -> Se Sera considerado o Inicializador Padrao
								.F.			,;	//14 -> Opcional, Carregar Todos os Campos
								.F.			,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
								NIL			,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
								.T.			,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
								.T.			,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
								.F.			,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								.F.			,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
								.T.			,;	//21 -> Verifica se Deve Checar se o campo eh usado
								.F.			,;	//22 -> Verifica se Deve Checar o nivel do usuario
								.T.			,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
								NIL			,;	//24 -> [@]Array que contera as chaves conforme recnos
								NIL			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
								NIL			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
								NIL			,;	//27 -> Numero maximo de Locks a ser efetuado
								NIL			,;	//28 -> Utiliza Numeracao na GhostCol
								NIL			,;	//29 ->
								NIL			,;	//30 ->
								2			;	//31 ->
							 )
		IF ( lIsObjGd )
			oObjGd:aCols := aClone( aCols )
		EndIF
		RdhColsSet( aCols )
		RdhRecnoSet( aRecnos )
		IF ( lIsObjGd )
			oObjGd:Goto( 1 )
		EndIF
	EndIF
EndIF
IF ( lIsObjGd )
	IF ( !( lGdRd9 ) .and. ( lRdhExeChg ) )
		Eval( oObjGd:oBrowse:bChange )
	EndIF
	oObjGd:Goto( 1 )
	oObjGd:Refresh()
EndIF

Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9RdhGotFocus	 �Autor�Marinaldo de Jesus� Data �29/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �GotFocus para os Objetos GetDados de Avaliados e Rede    	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function Rd9RdhGotFocus( oGdRd9 , oGdRdh )

oGdRd9 := oGdRd9Get()
oGdRdh := oGdRdhGet()

IF Empty( __nRd9AtAnt )
	__nRd9AtAnt := oGdRd9:oBrowse:nAt
EndIF

IF Empty( __nRdhAtAnt )
	__nRdhAtAnt := oGdRdh:oBrowse:nAt
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9Rdh2RdaChg	 �Autor�Marinaldo de Jesus� Data �25/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Change da GetDados Avaliados/Rede no Folder Avaliadores  	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function Rd9Rdh2RdaChg( nFolder , lTransToAll , lGrava )

Local aRdaColsAll		:= RdaColsGet()

Local aRdaCposPes
Local aRdaCposSrt

Local bColsToAll
Local bAllToCols

Local nRd9SvAt
Local nRdhSvAt

Local oGdRd9
Local oGdRda
Local oGdRdh

DEFAULT nFolder		:= APDA270_FOLDER_AVALIADORES
DEFAULT lTransToAll	:= .F.
DEFAULT lGrava		:= .F.

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	�Garanto que o Ponteiro Estara no Final do Arquivo para que nao�
	�Carregue Conteudo Invalido nos Inicializadores Padroes        �
	����������������������������������������������������������������/*/
	PutFileInEof( "RDA" )

	/*/
	��������������������������������������������������������������Ŀ
	�Obtenho o Objeto com as Informacoes dos Avaliadores           �
	����������������������������������������������������������������/*/
	oGdRda := oGdRdaGet( nFolder )

	/*/
	��������������������������������������������������������������Ŀ
	�Verifica se Deve Transferir para do aCols para o aColsAll     �
	����������������������������������������������������������������/*/


	oGdRd9		:= oGdRd9Get( nFolder )
	nRd9SvAt	:= oGdRd9:oBrowse:nAt
	oGdRdh		:= oGdRdhGet( nFolder )
	nRdhSvAt	:= oGdRdh:oBrowse:nAt

	IF (;
			!Empty( __nRd9AtAnt );
			.and.;
			!Empty( __nRdhAtAnt );
		)

		IF (;
				( __nRd9AtAnt <> nRd9SvAt );
				.or.;
				( __nRdhAtAnt <> nRdhSvAt );
				.or.;
				lGrava;
			)

			oGdRd9:Goto( __nRd9AtAnt )
			oGdRdh:Goto( __nRdhAtAnt )

			IF !( oGdRda:LinhaOk() )
				oGdRda:oBrowse:SetFocus()
				oGdRd9:Refresh()
				oGdRdh:Refresh()
				Break
			EndIF

			If !ArrayCompare( oGdRda:aCols , aColsRDA )
				lTransToAll	:= .T.
			EndIf

		EndIF

	EndIF

	IF ( lTransToAll )

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem as Informacoes para o GdColsExChange para o RDA         �
		����������������������������������������������������������������/*/
		RdaInfTrf(	nFolder,;
					@aRdaCposPes,;
					@aRdaCposSrt,;
					@bColsToAll,;
					@bAllToCols,;
					.T.,;
					.F.,;
					.F.;
				  )

		/*/
		��������������������������������������������������������������Ŀ
		�Transfiro os Dados do aCols para o aColsAll				   �
		����������������������������������������������������������������/*/
		If !IsInCallStack("APDA270TudoOk")
			GdColsExChange(	@aRdaColsAll	,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
							@oGdRda:aCols 	,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
							oGdRda:aHeader	,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
							NIL				,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
							NIL				,;	//05 -> Chave para Busca no aColsAll para Carga do aCols
							aRdaCposSrt		,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
							aRdaCposPes		,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
							NIL				,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
							.T.				,;	//09 -> Conteudo do Elemento "Deleted" a ser Carregado na Remontagem dos aCols
							.T.				,;	//10 -> Se deve Transferir do aCols para o aColsAll
							.F.				,;	//11 -> Se deve Transferir do aColsAll para o aCols
							.T.				,;	//12 -> Se Existe o Elemento de Delecao no aCols
							.T.				,;	//13 -> Se deve Carregar os Inicializadores padroes
							bColsToAll		,;	//14 -> Condicao para a Transferencia do aCols para o aColsAll
							bAllToCols		 ;	//15 -> Condicao para a Transferencia do aColsAll para o aCols
						)
		EndIf
	EndIF

	IF (;
			( __nRd9AtAnt <> nRd9SvAt );
			.or.;
			( __nRdhAtAnt <> nRdhSvAt );
		)

		oGdRd9:Goto( nRd9SvAt )
		oGdRdh:Goto( nRdhSvAt )

		__nRd9AtAnt := nRd9SvAt
		__nRdhAtAnt	:= nRdhSvAt

	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	�Obtem as Informacoes para o GdColsExChange para o RDA         �
	����������������������������������������������������������������/*/
	RdaInfTrf(	nFolder,;
				@aRdaCposPes,;
				@aRdaCposSrt,;
				@bColsToAll,;
				@bAllToCols,;
				.T.,;
				.F.,;
				.F.;
			  )

	/*/
	��������������������������������������������������������������Ŀ
	�Transfiro os Dados do aColsAll para o aCols				   �
	����������������������������������������������������������������/*/
	GdColsExChange(	@aRdaColsAll	,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
					@oGdRda:aCols 	,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
					oGdRda:aHeader	,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
					NIL				,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
					NIL				,;	//05 -> Chave para Busca no aColsAll para Carga do aCols
					aRdaCposSrt		,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
					aRdaCposPes		,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
					NIL				,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
					.T.				,;	//09 -> Conteudo do Elemento "Deleted" a ser Carregado na Remontagem dos aCols
					.F.				,;	//10 -> Se deve Transferir do aCols para o aColsAll
					.T.				,;	//11 -> Se deve Transferir do aColsAll para o aCols
					.T.				,;	//12 -> Se Existe o Elemento de Delecao no aCols
					.T.				,;	//13 -> Se deve Carregar os Inicializadores padroes
					bColsToAll		,;	//14 -> Condicao para a Transferencia do aCols para o aColsAll
					bAllToCols		 ;	//15 -> Condicao para a Transferencia do aColsAll para o aCols
				 )

	aColsRDA := aClone(oGdRda:aCols)

	IF (;
			GdFieldGet( "GDDELETED" , oGdRd9:nAt , NIL , oGdRd9:aHeader , oGdRd9:aCols );
			.or.;
			Empty( GdFieldGet( "RD9_CODADO" , oGdRd9:nAt , NIL , oGdRd9:aHeader , oGdRd9:aCols ) );
		)
		Eval( { || oRdaBtnGet() } ):Disable()
	Else
		Rd9RdaBtnED()
	EndIF


	oGdRda:Goto( 1 )
	oGdRda:Refresh()

End Sequence

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaInfTrf		 �Autor�Marinaldo de Jesus� Data �27/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Monta as informacoes que serao utilizadas para a  transferen�
�          �cia de informacoes no GdColsExChange do RDA                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function RdaInfTrf(	nFolder		,;
							aRdaCposPes	,;
							aRdaCposSrt	,;
							bColsToAll	,;
							bAllToCols	,;
							lChkRdh		,;
							lChkDel		,;
							lOnlyCodAv	 ;
				  		 )

Local oGdRdp		:= oGdRdpGet()
Local oGdRd9		:= oGdRd9Get( nFolder )
Local oGdRda		:= oGdRdaGet( nFolder )

Local bAscanRdh
Local bAscanRd9
Local bAscanRda

Local cRd6Codigo
Local cRd6CodTip
Local cRd6CodPro

Local cRdhCodNet
Local cRdhNivel

Local cRd9CodAdo
Local cRd9CodPro

Local dRd9DtIAva

Local nRdaCodAva
Local nRdaCodAdo
Local nRdaCodTip
Local nRdaCodNet
Local nRdaNivel
Local nRdaCodDor
Local nRdaCodPro
Local nRdaDtIAva
Local nRdaGhostCol
Local nRdaDeleted

Local nRd9CodAdo
Local nRd9CodPro
Local nRd9DtIAva

Local nRdhCodNet
Local nRdhNivel

Local oGdRdh

DEFAULT lChkRdh		:= .T.
DEFAULT	lChkDel		:= .F.
DEFAULT lOnlyCodAv  := .F.

nRdaCodAva			:= GdFieldPos( "RDA_CODAVA" , oGdRda:aHeader )
nRdaCodAdo			:= GdFieldPos( "RDA_CODADO" , oGdRda:aHeader )
nRdaCodPro			:= GdFieldPos( "RDA_CODPRO" , oGdRda:aHeader )
nRdaDtIAva			:= GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader )
nRdaCodTip			:= GdFieldPos( "RDA_CODTIP" , oGdRda:aHeader )
nRdaCodNet			:= GdFieldPos( "RDA_CODNET" , oGdRda:aHeader )
nRdaNivel			:= GdFieldPos( "RDA_NIVEL"	, oGdRda:aHeader )
nRdaCodDor			:= GdFieldPos( "RDA_CODDOR" , oGdRda:aHeader )
nRdaGhostCol		:= GdFieldPos( "RDA_REC_WT"	, oGdRda:aHeader )

IF ( lChkDel )
	nRdaDeleted		:= GdFieldPos( "GDDELETED"	, oGdRda:aHeader )
EndIF

nRd9CodAdo			:= GdFieldPos( "RD9_CODADO" , oGdRd9:aHeader )
cRd9CodAdo			:= oGdRd9:aCols[ oGdRd9:nAt , nRd9CodAdo ]

nRd9CodPro			:= GdFieldPos( "RD9_CODPRO" , oGdRd9:aHeader )
cRd9CodPro			:= oGdRd9:aCols[ oGdRd9:nAt , nRd9CodPro ]

nRd9DtIAva			:= GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader )
dRd9DtIAva			:= oGdRd9:aCols[ oGdRd9:nAt , nRd9DtIAva ]

IF ( lChkRdh )

	oGdRdh := oGdRdhGet( nFolder )

	nRdhCodNet			:= GdFieldPos( "RDH_CODNET" , oGdRdh:aHeader )
	cRdhCodNet			:= oGdRdh:aCols[ oGdRdh:nAt , nRdhCodNet ]
	SetMemVar( "RDH_CODNET" , cRdhCodNet )

	nRdhNivel			:= GdFieldPos( "RDH_NIVEL"	, oGdRdh:aHeader )
	cRdhNivel			:= oGdRdh:aCols[ oGdRdh:nAt , nRdhNivel  ]
	SetMemVar( "RDH_NIVEL"	, cRdhNivel  )

EndIF

cRd6Codigo	:= GetMemVar( "RD6_CODIGO" )
cRd6CodTip	:= GetMemVar( "RD6_CODTIP" )
cRd6CodPro	:= GetMemVar( "RD6_CODPRO" )

aRdaCposPes	:= {}
aAdd( aRdaCposPes , { nRdaCodAva , cRd6Codigo } )
IF !( lOnlyCodAv )
	aAdd( aRdaCposPes , { nRdaCodAdo , cRd9CodAdo	} )
	aAdd( aRdaCposPes , { nRdaCodPro , cRd9CodPro	} )
	aAdd( aRdaCposPes , { nRdaDtIAva , dRd9DtIAva	} )
	aAdd( aRdaCposPes , { nRdaCodTip , cRd6CodTip	} )
EndIF
IF ( lChkRdh )
	aAdd( aRdaCposPes , { nRdaCodNet , cRdhCodNet	} )
	aAdd( aRdaCposPes , { nRdaNivel  , cRdhNivel	} )
EndIF
IF ( lChkDel )
	aAdd( aRdaCposPes , { nRdaDeleted , .F. } )
EndIF

aRdaCposSrt	:= {}
aAdd( aRdaCposSrt , nRdaCodAva 	 )
aAdd( aRdaCposSrt , nRdaCodAdo 	 )
aAdd( aRdaCposSrt , nRdaCodPro 	 )
aAdd( aRdaCposSrt , nRdaDtIAva 	 )
aAdd( aRdaCposSrt , nRdaCodTip 	 )
aAdd( aRdaCposSrt , nRdaCodNet 	 )
aAdd( aRdaCposSrt , nRdaNivel  	 )
aAdd( aRdaCposSrt , nRdaCodDor 	 )
aAdd( aRdaCposSrt , nRdaGhostCol )

bColsToAll	:= { | aCols , aHeader , nItem |;
												!Empty( aCols[ nItem , nRdaCodAva ] );
												.and.;
												!Empty( aCols[ nItem , nRdaCodAdo ] );
												.and.;
												!Empty( aCols[ nItem , nRdaDtIAva ] );
												.and.;
												!Empty( aCols[ nItem , nRdaCodTip ] );
												.and.;
												!Empty( aCols[ nItem , nRdaCodNet ] );
												.and.;
												!Empty( aCols[ nItem , nRdaNivel  ] );
												.and.;
												!Empty( aCols[ nItem , nRdaCodDor  ] );
				}

bAllToCols	:= { | aColsAll , aHeaderAll , nFindKey | .T. }

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRdaInit	 	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init da GetDados de Avaliadores  							�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function GdRdaInit( oGdRda )

Local nRdaCodAva := GdFieldPos( "RDA_CODAVA" , oGdRda:aHeader )

aEval( oGdRda:aCols , { |aColsElem|	aColsElem[ nRdaCodAva ] := GetMemVar( "RD6_CODIGO" ) } )
oGdRda:Goto( 1 )
oGdRda:Refresh()

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Leg		�Autor�Marinaldo de Jesus � Data �22/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Monta a Legenda de Estatus da Avaliacao 					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270														�
�������������������������������������������������������������������������/*/
Function APDA270Leg( aMarksCollor , nObj , lLegend , nActFolder , aPages , aFieldsKey )

Local aSvKeys
Local aRd9Bmp
Local aRdaBmp
Local aBmpLegend

Local cTitle
Local cMsgInfo
Local cResourceName

Local nLoop
Local nLoops

Begin Sequence

	DEFAULT lLegend := .F.
	IF ( lLegend )
		aSvKeys 	:= GetKeys()
		IF (;
				( nActFolder <> APDA270_FOLDER_AGENDA );
				.and.;
				( nActFolder <> APDA270_FOLDER_AVALIADOS );
				.and.;
				( nActFolder <> APDA270_FOLDER_AVALIADORES );
			)
			cMsgInfo := STR0010	//"Op��o dispon�vel apenas para pesquisa na(s) Pasta(s):"
			cMsgInfo += CRLF
			cMsgInfo += aPages[ APDA270_FOLDER_AGENDA ]
			cMsgInfo += CRLF
			cMsgInfo += aPages[ APDA270_FOLDER_AVALIADOS ]
			cMsgInfo += CRLF
			cMsgInfo += aPages[ APDA270_FOLDER_AVALIADORES ]
			MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
			Break
		EndIF
		nObj := APDA270LgObj( nActFolder , @cTitle , aFolders )
	EndIF

	DEFAULT nObj := 0
	IF ( ( nObj <> 1 ) .and. ( nObj <> 2 ) .and. ( nObj <> 3 ) )
		Break
	EndIF

	nLoops	:= Len( aMarksCollor[ 1 ] )
	aRd9Bmp	:= Array( nLoops , 2 )
	For nLoop := 1 To nLoops
		aRd9Bmp[ nLoop , 1 ] := aMarksCollor[ 1 , nLoop , 1 ]
		aRd9Bmp[ nLoop , 2 ] := aMarksCollor[ 1 , nLoop , 2 ]
	Next nLoop

	nLoops	:= Len( aMarksCollor[ 2 ] )
	aRdaBmp	:= Array( nLoops , 2 )
	For nLoop := 1 To nLoops
		aRdaBmp[ nLoop , 1 ] := aMarksCollor[ 2 , nLoop , 1 ]
		aRdaBmp[ nLoop , 2 ] := aMarksCollor[ 2 , nLoop , 2 ]
	Next nLoop

	IF ( lLegend )
		aBmpLegend := IF( nObj == 1 , aRd9Bmp , aRdaBmp )
		BrwLegenda( OemToAnsi( STR0035 ) , OemToAnsi( cTitle ) , aBmpLegend ) //'Legenda'
	Else
		IF ( nObj == 2 )
			cResourceName := RdaGetResN( aRdaBmp , @aFieldsKey )
		ElseIF ( nObj == 1 )
			IF ( nActFolder == APDA270_FOLDER_AGENDA )
				cResourceName := RdpGetResN( aRdaBmp , @aFieldsKey )
			Else
				cResourceName := Rd9GetResN( aRdaBmp , @aFieldsKey )
			EndIF

			IF ( cResourceName <> "BR_VERDE" )
				cResourceName := aRd9Bmp[ 1 , 1 ]
			EndIF
		EndIF
	EndIF

End Sequence

IF ( lLegend )
	RestKeys( aSvKeys , .T. )
EndIF

Return( cResourceName )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpGetResN 		�Autor�Marinaldo de Jesus � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o Resource Name para o @BMP da GetDatos de Avaliados�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270														�
�������������������������������������������������������������������������/*/
Static Function RdpGetResN(	aBmpLegend , aFieldsKey )

Local aChrDelStr
Local aIndexKey

Local cIndexKey
Local cKeySeek
Local cRdpGetResN

Local nRd9Order
Local nSizeKey
Local nRecno
Local nNextRecno

Begin Sequence

	cRd9Fil		:= xFilial( "RD9" )
	cIndexKey	:= "RD9_FILIAL+RD9_CODAVA+DTOS(RD9_DTIAVA)"
	nRd9Order	:= RetOrdem( "RD9" , cIndexKey )

	RD9->( dbSetOrder( nRd9Order ) )
	cIndexKey	:= StrTran( RD9->( IndexKey() ) , " " , "" )
	cIndexKey	:= StrTran( cIndexKey , "RD9_" , "RDP_" )
	cIndexKey	:= StrTran( cIndexKey , "RDP_FILIAL" , "" )
	cIndexKey	:= StrTran( cIndexKey , "DTIAVA" , "DATINI" )
	aChrDelStr	:= { "DTOS" , "STR" , "STRZERO" , "(" , ")" }
	aIndexKey	:= StrToArray( cIndexKey , "+" , { | cString | StrDelChr( @cString , aChrDelStr ) , .T. } )
	aFieldsKey	:= aIndexKey

	IF IsInGetDados( { "RDP_DATINI" } )
		cKeySeek := aFlds2Str( "RDP" , aIndexKey , aCols[ n ] , aHeader )
	Else
		cKeySeek := aFlds2Str( "RDP" , aIndexKey )
	EndIF

	IF Empty( cKeySeek )
		Break
	EndIF

	cKeySeek := ( xFilial( "RD9" , xFilial( "RDP" ) ) + cKeySeek )
	RD9->( dbSetOrder( nRd9Order ) )
	IF RD9->( !dbSeek( cKeySeek , .F. ) )
		Break
	EndIF

	cIndexKey	:= RD9->( IndexKey() )
	nSizeKey	:= Len( cKeySeek )
	While RD9->(;
					!Eof();
					.and.;
					( SubStr( &( cIndexKey ) , 1 , nSizeKey ) == cKeySeek );
				 )
		IF !( GetNextRecno( "RD9" , @nNextRecno , @nRecno , nRd9Order ) )
			Break
		EndIF

		IF ( ( cRdpGetResN := Rd9GetResN( aBmpLegend ) ) <> "BR_VERDE" )
			Break
		EndIF

		IF !GotoNextRecno( "RD9" , nNextRecno , nRd9Order )
			Break
		EndIF
	End While

End Sequence

DEFAULT cRdpGetResN := aBmpLegend[ 1 , 1 ]

Return( cRdpGetResN )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9GetResN 		�Autor�Marinaldo de Jesus � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o Resource Name para o @BMP da GetDatos de Avaliados�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270														�
�������������������������������������������������������������������������/*/
Static Function Rd9GetResN(	aBmpLegend , aFieldsKey )

Local aChrDelStr
Local aIndexKey

Local aRd9GetResN
Local cIndexKey
Local cKeySeek

Local nRd9GetResN
Local nRdaNextRecno
Local nRdaRecno
Local nRdaOrder

Begin Sequence

	cRdaFil		:= xFilial( "RDA" )
	cIndexKey	:= "RDA_FILIAL+RDA_CODAVA+RDA_CODADO+RDA_CODPRO+DTOS(RDA_DTIAVA)"
	nRdaOrder	:= RetOrdem( "RDA" , cIndexKey )

	RDA->( dbSetOrder( nRdaOrder ) )
	cIndexKey	:= StrTran( RDA->( IndexKey() ) , " " , "" )
	cIndexKey	:= StrTran( cIndexKey , "RDA_" , "RD9_" )
	cIndexKey	:= StrTran( cIndexKey , "RD9_FILIAL" , "" )
	aChrDelStr	:= { "DTOS" , "STR" , "STRZERO" , "(" , ")" }
	aIndexKey	:= StrToArray( cIndexKey , "+" , { | cString | StrDelChr( @cString , aChrDelStr ) , .T. } )
	aFieldsKey	:= aIndexKey

	IF IsInGetDados( { "RD9_CODADO" } )
		cKeySeek := aFlds2Str( "RD9" , aIndexKey , aCols[ n ] , aHeader )
	Else
		cKeySeek := aFlds2Str( "RD9" , aIndexKey )
	EndIF

	IF Empty( cKeySeek )
		Break
	EndIF

	cKeySeek := ( xFilial( "RDA" , xFilial( "RD9" ) ) + cKeySeek )
	RDA->( dbSetOrder( nRdaOrder ) )
	IF RDA->( !dbSeek( cKeySeek , .F. ) )
		Break
	EndIF

	aRd9GetResN := {}
	cIndexKey 	:= "RDA_FILIAL+RDA_CODAVA+RDA_CODADO+RDA_CODPRO+DTOS(RDA_DTIAVA)"
	While RDA->( !Eof() .and. ( &( cIndexKey ) == cKeySeek ) )
		IF !GetNextRecno( "RDA" , @nRdaNextRecno , @nRdaRecno , nRdaOrder )
			Exit
		EndIF
		aAdd( aRd9GetResN , RdaGetResN( aBmpLegend ) )
		IF !GotoNextRecno( "RDA" , nRdaNextRecno , nRdaOrder )
			Exit
		EndIF
	End While

	IF ( ( nRd9GetResN := aScan( aRd9GetResN , { |x| ( x <> "BR_VERDE" ) } ) ) == 0 )
		nRd9GetResN := aScan( aRd9GetResN , { |x| ( x == "BR_VERDE" ) } )
	EndIF

End Sequence

IF Empty( nRd9GetResN )
	aRd9GetResN := { aBmpLegend[ 1 , 1 ] }
	nRd9GetResN := 1
EndIF

Return( aRd9GetResN[ nRd9GetResN ] )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaGetResN 		�Autor�Marinaldo de Jesus � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o Resource Name para o @BMP da GetDatos de  Avaliado�
�          �res															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270														�
�������������������������������������������������������������������������/*/
Static Function RdaGetResN(	aBmpLegend , aFieldsKey )

Local lRdcFound		:= .F.

Local aChrDelStr
Local aIndexKey

Local cIndexKey
Local cRdaGetResN
Local cRdatipoAv
Local cKeySeek

Local lIsInGetDados
Local lInAddLine

Local nRdcOrder

Begin Sequence

	IF ( lIsInGetDados := IsInGetDados( { "RDA_CODADO" , "RDA_TIPOAV" } ) )
		lInAddLine	:= InAddLine( "APDA270/__EXECUTE/RUNAPP/SIGAAPD/" )
	EndIF
	IF (;
			( lIsInGetDados );
			.and.;
			( lInAddLine );
		)
		Break
	EndIF

	cRdcFil		:= xFilial( "RDC" )
	cIndexKey	:= "RDC_FILIAL+RDC_CODAVA+RDC_CODADO+RDC_CODPRO+RDC_CODDOR+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV"
	nRdcOrder	:= RetOrdem( "RDC" , cIndexKey )

	RDC->( dbSetOrder( nRdcOrder ) )
	cIndexKey		:= StrTran( RDC->( IndexKey() ) , " " , "" )
	cIndexKey		:= StrTran( cIndexKey , "RDC_" , "RDA_" )
	cIndexKey		:= StrTran( cIndexKey , "RDA_FILIAL" , "" )
	aChrDelStr		:= { "DTOS" , "STR" , "STRZERO" , "(" , ")" }
	aIndexKey		:= StrToArray( cIndexKey , "+" , { | cString | StrDelChr( @cString , aChrDelStr ) , .T. } )
	aFieldsKey		:= aIndexKey

	IF ( lIsInGetDados )
		cKeySeek := aFlds2Str( "RDA" , aIndexKey , aCols[ n ] , aHeader )
	Else
		cKeySeek := aFlds2Str( "RDA" , aIndexKey )
	EndIF

	IF Empty( cKeySeek )
		Break
	EndIF

	cKeySeek := ( xFilial( "RDC" , xFilial( "RDA" ) ) + cKeySeek )

	RDC->( dbSetOrder( nRdcOrder ) )
	IF RDC->( !( lRdcFound := dbSeek( cKeySeek , .F. ) ) )
		Break
	EndIF

	RDC->( ApdEnvChk( RDC_FILIAL , Recno() ) )

	IF RDC->(;
				Empty( RDC_DATENV );
				.and.;
				Empty( RDC_DATRET );
			)
		IF ( RDC->RDC_TIPOAV == "1" )
			Break
		ElseIF ( RDC->RDC_TIPOAV == "2" )
			cRdaGetResN := aBmpLegend[ 3 , 1 ]
			Break
		ElseIF ( RDC->RDC_TIPOAV == "3" )
			cRdaGetResN := aBmpLegend[ 5 , 1 ]
			Break
		EndIF
	EndIF

	IF RDC->( !Empty( RDC_DATENV ) .and. Empty( RDC_DATRET ) )
		IF ( RDC->RDC_TIPOAV == "1" )
			cRdaGetResN := aBmpLegend[ 2 , 1 ]
			Break
		ElseIF ( RDC->RDC_TIPOAV == "2" )
			cRdaGetResN := aBmpLegend[ 4 , 1 ]
			Break
		ElseIF ( RDC->RDC_TIPOAV == "3" )
			cRdaGetResN := aBmpLegend[ 6 , 1 ]
			Break
		EndIF
	EndIF

	IF !Empty( RDC->RDC_DATRET )
		cRdaGetResN := aBmpLegend[ Len( aBmpLegend ) , 1 ]
	EndIF

End Sequence

IF !( lRdcFound )
	IF (;
			!( lIsInGetDados );
			.or.;
			(;
				( lIsInGetDados );
				.and.;
				!( lInAddLine );
			);
		)
		IF ( lIsInGetDados )
			cRdatipoAv := GdFieldGet( "RDA_TIPOAV" )
		Else
			cRdaTipoAv := RDA->RDA_TIPOAV
		EndIF
		IF ( cRdatipoAv == "1" )
			cRdaGetResN := aBmpLegend[ 1 , 1 ]
		ElseIF ( cRdatipoAv == "2" )
			cRdaGetResN := aBmpLegend[ 3 , 1 ]
		ElseIF ( cRdatipoAv == "3" )
			cRdaGetResN := aBmpLegend[ 5 , 1 ]
		EndIF
	EndIF
EndIF

DEFAULT cRdaGetResN := aBmpLegend[ 1 , 1 ]

Return( cRdaGetResN )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �APDA270LgObj	�Autor�Marinaldo de Jesus � Data �23/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna as Opcoes para Visualizacao da Legenda              �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Retorno   �Numero do Objeto para Pesquisa na GetDados                  �
�����������������������������������������������������������������������Ĵ
�Uso	   �APDA270Leg() em APDA270()							    	�
�������������������������������������������������������������������������/*/
Static Function APDA270LgObj( nActFolder , cTitle , aFolders )

Local aSvKeys		:= GetKeys()
Local aItens		:= {}
Local aInfoAdvSize	:= {}
Local aAdvSize      := {}
Local aObjCoords    := {}
Local aObjSize      := {}
Local bSet15		:= { || lOpcOk	:= .T.	, RestKeys( aSvKeys , .T. ) , oDlg:End() }
Local bSet24		:= { || nOpcRel	:= 0	, RestKeys( aSvKeys , .T. ) , oDlg:End() }
Local lOpcOk		:= .F.
Local nOpcLegend	:= 1

Local oRadio
Local oDlg
Local oGroup
Local oFont

Begin Sequence

	DEFAULT cTitle := STR0035 + " "	//'Legenda'
	IF ( nActFolder == APDA270_FOLDER_AGENDA )
		nOpcLegend	:= 3
		cTitle		+= aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , nOpcLegend , APDA270_OBJ ]:oBrowse:cToolTip
		nOpcLegend	:= 1
		Break
	ElseIF ( nActFolder == APDA270_FOLDER_AVALIADOS )
		nOpcLegend	:= 2
		cTitle		+= aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , nOpcLegend , APDA270_OBJ ]:oBrowse:cToolTip
		nOpcLegend	:= 1
		Break
	ElseIf ( nActFolder == APDA270_FOLDER_AVALIADORES )
		aAdd( aItens , aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , 1 , APDA270_OBJ ]:oBrowse:cToolTip )
		aAdd( aItens , aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , 4 , APDA270_OBJ ]:oBrowse:cToolTip )
	EndIF

	aAdvSize	 := MsAdvSize( , .T. , 50 )
	aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }

	/*/
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������/*/
	aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM  aAdvSize[7],0 TO aAdvSize[6]*0.65,aAdvSize[5] TITLE OemToAnsi( STR0035 ) PIXEL	//'Legenda'

		@ aObjSize[1,1],aObjSize[1,2]	GROUP oGroup TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0046) OF oDlg PIXEL	//"Selecione o Objeto da Pesquisa"
		oGroup:oFont:=oFont

 		oRadio 			:= TRadMenu():New( aObjSize[1,1]+10,aObjSize[1,2]+10 , aItens , NIL , oDlg , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. )
		oRadio:bSetGet	:= { |nItem| IF( nItem <> NIL , nOpcLegend := nItem , nOpcLegend ) }

		oDlg:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
	RestKeys( aSvKeys , .T. )

	IF !( lOpcOk )
		nOpcLegend := 0
	Else
		cTitle += aItens[ nOpcLegend ]
		IF ( nActFolder == APDA270_FOLDER_AVALIADORES )
			IF ( nOpcLegend == 4 )
				nOpcLegend	:= 2
			EndIF
		EndIF
	EndIF

End Sequence

Return( nOpcLegend )


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270MarksRD6 �Autor�Marinaldo de Jesus � Data �04/10/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorno de Array com as Opcoes para o MarkBrowse do RD6		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270														�
�������������������������������������������������������������������������/*/
Function APDA270MarksRD6()

Local aMarks := {}

aMarks	:=	{	                                    	 	 	 ;
				{ "RD6->RD6_STATUS=='1'" , "BR_VERDE"		}	,;
				{ "RD6->RD6_STATUS=='2'" , "BR_VERMELHO"	}	 ;
			 }

Return( aClone( aMarks ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �a270RdpGdLinOk�Autor�Marinaldo de Jesus   � Data �18/06/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validacao da LinhaOk da GetDados para o RDP					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �a270RdpGdLinOk( oBrowse )								    �
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function a270RdpGdLinOk( oBrowse , lShowMsg , lSoft , nModelo )

Local aCposKey		:= {}
Local lLinOk		:= .T.

Local aRd9Header
Local aRd9Cols
Local aLstRdpCols

Local bRdpSort

Local cMsgInfo

Local dRdpDatIni
Local dRdpDatFim

Local dRd6DtIni
Local dRd6DtFim

Local lSort
Local lChkDtIniFim

Local nRdpDatIni
Local nRdpDatFim
Local nRdpGhostCol
Local nLinDiff
Local nRdpDelete
Local nRd9DtiAva
Local nRd9CodAdo
Local nRd9Delete
Local nLoop
Local nLoops
Local cRd5Tipo		:= Posicione("RD5",1,xFilial("RD5")+GetMemVar( "RD6_CODTIP" ),"RD5_TIPO")

DEFAULT lShowMsg	:= .T.
DEFAULT lSoft		:= .F.
DEFAULT nModelo		:= 4

If 	cRd5Tipo="3"
	Return( lLinOk )
EndIf
/*
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������*/
MyCursorWait()

	Begin Sequence

		/*
		��������������������������������������������������������������Ŀ
		� Valida Apenas na Inclusao e na Alteracao				       �
		����������������������������������������������������������������*/
		IF (;
				!( Inclui );
				.and.;
				!( Altera );
			)
			Break
		EndIF

		/*
		��������������������������������������������������������������Ŀ
		� Se a Linha da GetDados Nao Estiver Deletada				   �
		����������������������������������������������������������������*/
		IF !( GdDeleted() )

			IF !( lSoft )

				/*
				��������������������������������������������������������������Ŀ
				� Verifica Itens Duplicados na GetDados						   �
				����������������������������������������������������������������*/
				aCposKey := GetArrUniqe( "RDP" )
				IF !( lLinOk := GdCheckKey( aCposKey , nModelo , NIL , @cMsgInfo , lShowMsg ) )
					Break
				EndIF

				/*
				��������������������������������������������������������������Ŀ
				� Verifica Se o Campos Estao Devidamente Preenchidos		   �
				����������������������������������������������������������������*/
				aCposKey := GdObrigat( aHeader )
				IF ( RdpMTipCob() )
					aAdd( aCposKey , "RDP_MEMCOB" )
				EndIF
				IF ( GdFieldGet( "RDP_TIPENV" ) == "1" )
					aAdd( aCposKey , "RDP_MSGAVA" )
				EndIF
				IF !( lLinOk := GdNoEmpty( aCposKey , NIL , NIL , NIL , NIL , @cMsgInfo , lShowMsg ) )
			    	Break
				EndIF

				/*
				��������������������������������������������������������������Ŀ
				� Consiste Data Inicial e Final                                �
				����������������������������������������������������������������*/
				IF ( lChkDtIniFim := ( IsMemVar( "RD6_DTINI" ) .and. IsMemVar( "RD6_DTFIM" ) ) )

					/*
					��������������������������������������������������������������Ŀ
					� Obtem o Periodo da Avaliacao conforme RD6                    �
					����������������������������������������������������������������*/
					dRd6DtIni	:= GetMemVar( "RD6_DTINI" )
					dRd6DtFim	:= GetMemVar( "RD6_DTFIM" )

					/*
					��������������������������������������������������������������Ŀ
					� Obtem o Conteudo do campo RDP_DATINI                         �
					����������������������������������������������������������������*/
					IF ( ( nRdpDatIni := GdFieldPos( "RDP_DATINI" ) ) > 0 )
						dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )
					EndIF

					/*
					��������������������������������������������������������������Ŀ
					� Obtem o Conteudo do campo RDP_DATFIM                         �
					����������������������������������������������������������������*/
					IF ( ( nRdpDatFim := GdFieldPos( "RDP_DATFIM" ) ) > 0 )
						dRdpDatFim	:= GdFieldGet( "RDP_DATFIM" )
                	EndIF

					/*
					��������������������������������������������������������������Ŀ
					� Verifica Se RDP_DATINI esta dentro do Periodo da Avaliacao   �
					����������������������������������������������������������������*/
					IF (  GdFieldPos( "RDP_DATINI" ) > 0 )
						IF !( lLinOk := ( ( dRdpDatIni >= dRd6DtIni ) .and. ( dRdpDatIni <= dRd6DtFim ) ) )
							cMsgInfo	:= STR0120	//"O conte�do do campo"
							cMsgInfo	+= " "
							cMsgInfo	+= aHeader[ GdFieldPos( "RDP_DATINI" ) , 01 ]
							cMsgInfo	+= " "
							cMsgInfo	+= STR0121	//"deve estar dentro do per�odo definido para a Avalia��o."
	    					cMsgInfo	+= CRLF
	    					cMsgInfo	+= CRLF
	    					cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
							cMsgInfo 	+= CRLF
							cMsgInfo 	+= CRLF
	    					cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
							IF ( lShowMsg )
								MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia!'
			    			EndIF
			    			Break
						EndIF
					EndIF

					/*
					��������������������������������������������������������������Ŀ
					� Verifica Se RDP_DATFIM esta dentro do Periodo da Avaliacao   �
					����������������������������������������������������������������*/
					IF ( GdFieldPos( "RDP_DATFIM" ) > 0 )
						IF !( lLinOk := ( ( dRdpDatFim >= dRd6DtIni ) .and. ( dRdpDatFim <= dRd6DtFim ) ) )
							cMsgInfo	:= STR0120	//"O conte�do do campo"
							cMsgInfo	+= " "
							cMsgInfo	+= aHeader[ GdFieldPos( "RDP_DATFIM" ) , 01 ]
							cMsgInfo	+= " "
							cMsgInfo	+= STR0121	//"deve estar dentro do per�odo definido para a Avalia��o."
	    					cMsgInfo	+= CRLF
	    					cMsgInfo	+= CRLF
	    					cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
							cMsgInfo 	+= CRLF
							cMsgInfo 	+= CRLF
	    					cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
							IF ( lShowMsg )
								MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia!'
			    			EndIF
			    			Break
						EndIF
					EndIF

				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				� Se a Data Inicial e Final nao Conflitam com Periodos Ja  Exis�
				� tentes													   �
				����������������������������������������������������������������/*/
				IF (;
						( ( nRdpDelete := GdFieldPos( "GDDELETED" ) ) > 0 );
						.and.;
						( Type("nRdpDatIni") <> "U" .And. Type("nRdpDatFim") <> "U" );
						.And.;
						( nRdpDatIni > 0 );
						.and.;
						( nRdpDatFim > 0 );
					)

					IF ( ( nLoops := Len( aCols ) ) > 0 )
						For nLoop := 1 To nLoops
							IF (;
									( aCols[ nLoop , nRdpDelete ] );
									.or.;
									( n == nLoop );
								)
								Loop
							EndIF
							IF ConflictDate( dRdpDatIni , dRdpDatFim , aCols[ nLoop , nRdpDatIni ] , aCols[ nLoop , nRdpDatFim ] )
								lLinOk := .F.
							EndIF
							IF !( lLinOk )
				    			cMsgInfo :=	STR0073	//'A Data Inicial ou Final est� conflitando com per�odo j� existente'
					    		cMsgInfo += CRLF
					    		cMsgInfo += CRLF
								cMsgInfo += aHeader[ nRdpDatIni , 01 ]
								cMsgInfo += ": "
								cMsgInfo += Dtoc( dRdpDatIni )
								cMsgInfo += " - "
								cMsgInfo += aHeader[ nRdpDatFim , 01 ]
								cMsgInfo += ": "
								cMsgInfo += Dtoc( dRdpDatFim )
					    	   	cMsgInfo += CRLF
					    		cMsgInfo += CRLF
					    		cMsgInfo += STR0074	//'Linha: '
					    		cMsgInfo += Alltrim( Str( nLoop ) )
								cMsgInfo += ". "
								cMsgInfo += CRLF
								cMsgInfo += CRLF
								cMsgInfo += aHeader[ nRdpDatIni , 01 ]
								cMsgInfo += ": "
								cMsgInfo += Dtoc( aCols[ nLoop , nRdpDatIni ] )
								cMsgInfo += " - "
								cMsgInfo += aHeader[ nRdpDatFim , 01 ]
								cMsgInfo += ": "
								cMsgInfo += Dtoc( aCols[ nLoop , nRdpDatFim ] )
				    			IF ( lShowMsg )
					    			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia'
								EndIF
								Break
							EndIF
						Next nLoop
					EndIF

				EndIF

			EndIF

			IF APDA270Fldrs()
				IF ( GdFieldPos( "RDP_DATINI" ) > 0 )
					dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )
					aRd9Header	:= Rd9HeaderGet()
					aRd9Cols	:= Rd9ColsGet()
					IF ( ValType( aRd9Header ) == "A" )
						nRd9DtiAva	:= GdFieldPos( "RD9_DTIAVA" , aRd9Header )
						nRd9CodAdo	:= GdFieldPos( "RD9_CODADO" , aRd9Header )
						nRd9Delete	:= GdFieldPos( "GDDELETED"  , aRd9Header )
						IF ( aScan( aRd9Cols , { |x| ( x[ nRd9DtIAva ] == dRdpDatIni ) .and. ( !x[nRd9Delete] ) } ) == 0 )
	                    	IF ( aScan( aRd9Cols , { |x| ( x[ nRd9DtIAva ] == dRdpDatIni ) .and. ( x[nRd9Delete] ) .and. !Empty( x[nRd9CodAdo] ) } ) > 0 )
								GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 2 , 1 ) )	//Excluida
							Else
								GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 1 , 1 ) )	//N�o Gerada
							EndIF
						Else
							IF ( GdFieldGet( "RDP_STATUS" ) < SubStr( RdpStatusBox( .T. ) , 3 , 1 ) )
								GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 3 , 1 ) )	//N�o Enviada
							EndIF
						EndIF
					EndIF
				EndIF
			EndIF

		EndIF

	End Sequence

	/*
	��������������������������������������������������������������Ŀ
	�Se Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  �
	����������������������������������������������������������������*/
	IF !( lLinOk )
		IF ( ValType( oBrowse ) == "O" )
			oBrowse:SetFocus()
		EndIF
	ElseIF !( lSoft )
		/*
		��������������������������������������������������������������Ŀ
		�Ordena a GetDados apenas se houve alteracao na Data           �
		����������������������������������������������������������������*/
		IF ( !Empty( nRdpDatIni ) )
			aLstRdpCols := aClone( aFolders[ APDA270_FOLDER_AGENDA , APDA270_FOLDER_OBJECTS , 3 , APDA270_ALSTCOLS	] )
			IF !( ArrayCompare( aCols , aLstRdpCols , @nLinDiff ) )
				DEFAULT nLinDiff := Len( aCols )
				IF ( nLinDiff <= Len( aLstRdpCols ) )
					lSort := ( aCols[ nLinDiff , nRdpDatIni ] <> aLstRdpCols[ nLinDiff , nRdpDatIni ] )
				Else
					lSort := .T.
				EndIF
				IF ( lSort )
					IF ( ( nRdpGhostCol := GdFieldPos( "GHOSTCOL" ) ) > 0 )
						bRdpSort := { |x,y| ( ( Dtos( x[ nRdpDatIni ] ) + x[ nRdpGhostCol ] ) < ( Dtos( y[ nRdpDatIni ] ) + y[ nRdpGhostCol ] ) ) }
					Else
						bRdpSort := { |x,y| ( x[ nRdpDatIni ] < y[ nRdpDatIni ] ) }
					EndIF
					aSort( aCols , NIL , NIL , bRdpSort )
					IF ( ValType( oBrowse ) == "O" )
						oBrowse:Refresh()
					EndIF
				EndIF
				aLstRdpCols := aClone( aCols )
			EndIF
		EndIF
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Garante que na Inclusao o Ponteiro do RDP estara em Eof()    �
	����������������������������������������������������������������/*/
	PutFileInEof( "RDP" )

/*
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������*/
MyCursorArrow()

Return( lLinOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpGdTudOk	�Autor�Marinaldo de Jesus     � Data �18/06/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validacao do TudoOk da GetDados para o RDP					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �RdpGdTudOk( oBrowse )									    �
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function a270RdpGdTudOk( oBrowse , lShowMsg , lSoft , nModelo )

Local lTudoOk := .T.

Local nLoop
Local nLoops

/*
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������*/
MyCursorWait()

	Begin Sequence

		/*
		��������������������������������������������������������������Ŀ
		� Valida Apenas na Inclusao e na Alteracao				       �
		����������������������������������������������������������������*/
		IF (;
				!( Inclui );
				.and.;
				!( Altera );
			)
			Break
		EndIF

	    /*
		��������������������������������������������������������������Ŀ
		� Percorre Todas as Linhas para verificar se Esta Tudo OK      �
		����������������������������������������������������������������*/
		nLoops := Len( aCols )
		For nLoop := 1 To nLoops
			n := nLoop
			IF !( lTudoOk := a270RdpGdLinOk( oBrowse , lShowMsg , lSoft , nModelo ) )
				IF ( ValType( oBrowse ) == "O" )
					oBrowse:Refresh()
				EndIF
				Break
			EndIF
		Next nLoop

	End Sequence

/*
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������*/
MyCursorArrow()

Return( lTudoOk  )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpGdDelOk  �Autor�Marinaldo de Jesus     � Data �18/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a Delecao na GetDados                               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>           						�
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdpGdDelOk( nOpc , lNoChkFirst , lShowMsg , lExecDel )

Local lDelOk 		:= .T.
Local lStatusDel	:= .F.

Local aRd9ColsAll
Local aRd9ColPos
Local aRdaColsAll
Local aRdaColPos
Local aRdpNotChk

Local bGdRstOk

Local cRdpCodAva
Local cRdpKeyChk

Local dRdpDatIni

Local nRdpOrder
Local nRdpRecno

Local nRd9CodAdo
Local nRdaCodAdo
Local nRdaCodDor

Local oGdRd9
Local oGdRda

Static lFirstDelOk
Static lLstDelOk

DEFAULT lFirstDelOk	:= .T.
DEFAULT lLstDelOk	:= .T.
DEFAULT lNoChkFirst	:= .F.
DEFAULT lShowMsg	:= .T.
DEFAULT lExecDel	:= .T.

Begin Sequence

	//Quando for Visualizacao ou Exclusao Abandona
	IF (;
			( nOpc == 2 ) .or. ;	//Visualizacao
			( nOpc == 5 );			//Exclusao
		)
		Break
	EndIF

	IF !( lNoChkFirst )
		//Apenas se for a primeira vez
		IF !( lFirstDelOk )
			lFirstDelOk	:= .T.
			lDelOk 		:= lLstDelOk
			lLstDelOk	:= .T.
			Break
		EndIF
	Else
		lFirstDelOk := .T.
	EndIF

	lStatusDel	:= !( GdDeleted() ) //Inverte o Estado

	cRdpCodAva	:= GetMemVar( "RD6_CODIGO" )
	dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )

	IF ( lStatusDel )	//Deletar

		/*/
		��������������������������������������������������������������Ŀ
		� Verifica se o Item pode ser Deletado                         �
		����������������������������������������������������������������/*/
		nRdpOrder := RetOrdem( "RDP" , "RDP_FILIAL+DTOS(RDP_DATINI" )
		cRdpKeyChk	:= ( cRdpCodAva + Dtos( dRdpDatIni ) )
		RDP->( dbSetOrder( nRdpOrder ) )
		IF RDP->( MsSeek( xFilial( "RDP" ) + cRdpKeyChk , .F. ) )
			nRdpRecno := RDP->( Recno() )
			aRdpNotChk := { "RD9" , "RDA" , "RDC" }
			IF !( lDelOk := ApdChkDel( "RDP" , nRdpRecno , nOpc , cRdpKeyChk , .F. , NIL , NIL , aRdpNotChk , .T. , .T. ) )
   				cMsgInfo := STR0129 //"Este �tem n�o pode ser exclu�do."
   				IF ( lShowMsg )
   					//'Aviso de Inconsist�ncia!'
   					MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )
   				EndIF
   				lLstDelOk := lDelOk
   				//Ja Passou pela funcao
				lFirstDelOk := .F.
				Break
			EndIF
		EndIF

		IF ( lExecDel )

			/*/
			��������������������������������������������������������������Ŀ
			� Deleta os Avaliados                                          �
			����������������������������������������������������������������/*/
			oGdRd9		:= oGdRd9Get( APDA270_FOLDER_AVALIADOS )
			aRd9ColsAll	:= Rd9ColsGet()
			aRd9ColPos	:= {;
								{ GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader ) },;
								{ dRdpDatIni },;
								 GdFieldPos( "GDDELETED" , oGdRd9:aHeader );
							}
			GdDelItens( @oGdRd9:aCols , aRd9ColPos )
			GdDelItens( @aRd9ColsAll  , aRd9ColPos )

			/*/
			��������������������������������������������������������������Ŀ
			� Deleta os Avaliadores										   �
			����������������������������������������������������������������/*/
			oGdRda   	:= oGdRdaGet( APDA270_FOLDER_AVALIADORES )
			aRdaColsAll	:= RdaColsGet()
			aRdaColPos	:= {;
								{ GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader ) },;
								{ dRdpDatIni },;
								 GdFieldPos( "GDDELETED" , oGdRda:aHeader );
							}
			GdDelItens( @oGdRda:aCols , aRdaColPos )
			GdDelItens( @aRdaColsAll  , aRdaColPos )

		EndIF

	Else	//Restaurar

   		lDelOk		:= .T.
   		lLstDelOk	:= lDelOk

		IF ( lExecDel )

			/*/
			��������������������������������������������������������������Ŀ
			� Restaura os Avaliados                                        �
			����������������������������������������������������������������/*/
			oGdRd9		:= oGdRd9Get( APDA270_FOLDER_AVALIADOS )
			aRd9ColsAll	:= Rd9ColsGet()
			aRd9ColPos	:= {;
								{ GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader ) },;
								{ dRdpDatIni },;
								 GdFieldPos( "GDDELETED" , oGdRd9:aHeader );
							}
			nRd9CodAdo  := GdFieldPos( "RD9_CODADO" , oGdRd9:aHeader )
			bGdRstOk		:= { | aColsnLin , nLin | !Empty( aColsnLin[ nRd9CodAdo ] ) }
			GdRstItens( @oGdRd9:aCols , aRd9ColPos , bGdRstOk )
			GdRstItens( @aRd9ColsAll  , aRd9ColPos , bGdRstOk )

			/*/
			��������������������������������������������������������������Ŀ
			� Restaura os Avaliadres                                        �
			����������������������������������������������������������������/*/
			oGdRda		:= oGdRdaGet( APDA270_FOLDER_AVALIADORES )
			aRdaColsAll	:= RdaColsGet()
			aRdaColPos	:= {;
								{ GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader ) },;
								{ dRdpDatIni },;
								 GdFieldPos( "GDDELETED" , oGdRda:aHeader );
							}
			nRdaCodAdo	:= GdFieldPos( "RDA_CODADO" , oGdRda:aHeader )
			nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" , oGdRda:aHeader )
			bGdRstOk		:= { | aColsnLin , nLin | !Empty( aColsnLin[ nRdaCodAdo ] ) .and. !Empty( aColsnLin[ nRdaCodDor ] ) }
			GdRstItens( @oGdRda:aCols , aRdaColPos , bGdRstOk )
			GdRstItens( @aRdaColsAll  , aRdaColPos , bGdRstOk )

		EndIF

	EndIF

	//Ja Passou pela funcao
	lFirstDelOk := .F.

End Sequence

Return( lDelOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �a270Rd9GdLinOk	 �Autor�Marinaldo de Jesus� Data �27/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a LinhaOk da GetDados para os Avaliados				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Function a270Rd9GdLinOk( oBrowse , lShowMsg , nModelo )

Local lLinOk	:= .T.

Local aColsReg
Local aCposKey
Local cMsgInfo
Local cRd9CodAva
Local cRd9CodAdo
Local cRd9CodPro
Local dRd9DtiAva
Local dRd9DtfAva
Local nRd9CodAva
Local nRd9CodAdo
Local nRd9Delete
Local nRd9DtiAva
Local nRd9DtfAva
Local nRd9CodPro
Local nLoop
Local nLoops
Local cRd5Tipo		:= Posicione("RD5",1,xFilial("RD5")+GetMemVar( "RD6_CODTIP" ),"RD5_TIPO")

DEFAULT lShowMsg	:= .T.
DEFAULT nModelo		:= 4

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
MyCursorWait()

	Begin Sequence

		/*
		��������������������������������������������������������������Ŀ
		� Valida Apenas na Inclusao e na Alteracao				       �
		����������������������������������������������������������������*/
		IF (;
				!( Inclui );
				.and.;
				!( Altera );
			)
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Se a Linha da GetDados Nao Estiver Deletada				   �
		����������������������������������������������������������������/*/
		IF !( GdDeleted() )

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Itens Duplicados na GetDados						   �
			����������������������������������������������������������������/*/
			aCposKey := GetArrUniqe( "RD9" )
			IF !( lLinOk := GdCheckKey( aCposKey , nModelo , NIL , @cMsgInfo , lShowMsg ) )
				Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Campos Estao Devidamente Preenchidos		   �
			����������������������������������������������������������������/*/
			aCposKey := GdObrigat( aHeader )
			IF !( lLinOk := GdNoEmpty( aCposKey , NIL , NIL , NIL , NIL , @cMsgInfo , lShowMsg ) )
		    	Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o Conteudo dos Campos       						   �
			����������������������������������������������������������������/*/
			cRd9CodAva	:= GdFieldGet( "RD9_CODAVA" )
			cRd9CodAdo	:= GdFieldGet( "RD9_CODADO" )
			cRd9CodPro	:= GdFieldGet( "RD9_CODPRO"	)
			dRd9DtiAva	:= GdFieldGet( "RD9_DTIAVA"	)
			dRd9DtfAva	:= GdFieldGet( "RD9_DTFAVA"	)

			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o Posicionamento dos Campos							   �
			����������������������������������������������������������������/*/
			nRd9CodAva	:= GdFieldPos( "RD9_CODAVA" )
			nRd9CodAdo	:= GdFieldPos( "RD9_CODADO" )
			nRd9CodPro	:= GdFieldPos( "RD9_CODPRO"	)
			nRd9DtiAva	:= GdFieldPos( "RD9_DTIAVA"	)
			nRd9DtfAva	:= GdFieldPos( "RD9_DTFAVA"	)
			nRd9Delete	:= GdFieldPos( "GDDELETED"  )

			/*/
			��������������������������������������������������������������Ŀ
			� Percorre Todos os Avaliados em Questao conforme Projeto      �
			����������������������������������������������������������������/*/
			aColsReg	:= {}
			aEval( aCols ,	{ |x,y| IF(;
										(;
											( x[nRd9CodAdo] == cRd9CodAdo );	//Mesmo Codigo de Avaliado
											.and.;
											( x[nRd9CodPro] == cRd9CodPro );	//Mesmo Codigo de Projeto
											.and.;
											( y <> n );							//Nao for o Registro Atual
											.and.;
											!( x[nRd9Delete] );					//Nao Estiver Deletado
										 ),;
										aAdd( aColsReg , y ),;
										NIL;
									   );
							};
				  )

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Data Inicial eh Maior que Data Final		   �
			����������������������������������������������������������������/*/
			IF !( lLinOk := ( dRd9DtiAva <= dRd9DtfAva ) )
		    	cMsgInfo := STR0072	//'A Data Inicial n�o pode ser maior que a Data Final'###'Aviso de Inconsist�ncia!'
		    	IF ( lShowMsg )
		    		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )
		    	EndIF
		    	Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se a Data Inicial e Final estao Dentro do Periodo de�
			� finido para a Avalliacao									   �
			����������������������������������������������������������������/*/
			IF !( lLinOk := ( dRd9DtiAva >= GetMemVar( "RD6_DTINI" ) .and. dRd9DtfAva <= GetMemVar( "RD6_DTFIM" ) ) )
		    	IF ( ( dRd9DtiAva < GetMemVar( "RD6_DTINI" ) ) .and. ( dRd9DtfAva <= GetMemVar( "RD6_DTFIM" ) ) )
		    		cMsgInfo := STR0072	//'A Data Inicial n�o pode ser menor que a Data Inical da Avalia��o'
		    	ElseIF ( dRd9DtfAva > GetMemVar( "RD6_DTFIM" ) ) .and. ( dRd9DtiAva >= GetMemVar( "RD6_DTINI" ) )
		    		cMsgInfo := STR0076	//'A Data Final n�o pode ser maior que a Data Final da Avalia��o'
		    	Else
		    		cMsgInfo := STR0077	//'As Datas, Inicial e Final, est�o fora do per�odo definido para a Avalia��o'
		    	EndIF
	    		cMsgInfo	+= CRLF
	    		cMsgInfo	+= CRLF
	    		cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
	    		cMsgInfo	+= ( Dtoc( GetMemVar( "RD6_DTINI" ) ) + " - " + Dtoc( GetMemVar( "RD6_DTFIM" ) ) )
	    		IF ( lShowMsg )
	    			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
		    	EndIF
		    	Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Se a Data Inicial e Final nao Conflitam com Periodos Ja  Exis�
			� tentes													   �
			����������������������������������������������������������������/*/
			IF ( ( nLoops := Len( aColsReg ) ) > 0 )
				For nLoop := 1 To nLoops
					IF (;
							( aCols[ aColsReg[ nLoop ] , nRd9Delete ] );
							.or.;
							( n == aColsReg[ nLoop ] );
						)
						Loop
					EndIF
					IF ConflictDate( dRd9DtiAva , dRd9DtfAva , aCols[ aColsReg[ nLoop ] , nRd9DtiAva ] , aCols[ aColsReg[ nLoop ] , nRd9DtfAva ] )
						lLinOk := .F.
					EndIF
					IF !( lLinOk )
		    			cMsgInfo :=	STR0073	//'A Data Inicial ou Final est� conflitando com per�odo j� existente'
			    		cMsgInfo += CRLF
			    		cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRd9DtiAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( dRd9DtiAva )
						cMsgInfo += " - "
						cMsgInfo += aHeader[ nRd9DtfAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( dRd9DtfAva )
			    	   	cMsgInfo += CRLF
			    		cMsgInfo += CRLF
			    		cMsgInfo += STR0074	//'Linha: '
			    		cMsgInfo += Alltrim( Str( aColsReg[ nLoop ] ) )
						cMsgInfo += ". "
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRd9CodAdo , 01 ]
						cMsgInfo += ": "
						cMsgInfo += cRd9CodAdo
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRd9CodPro , 01 ]
						cMsgInfo += ": "
						cMsgInfo += cRd9CodPro
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRd9DtiAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( aCols[ aColsReg[ nLoop ] , nRd9DtiAva ] )
						cMsgInfo += " - "
						cMsgInfo += aHeader[ nRd9DtfAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( aCols[ aColsReg[ nLoop ] , nRd9DtfAva ] )
		    			IF ( lShowMsg )
			    			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia'
						EndIF
						Break
					EndIF
				Next nLoop
			EndIF

		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Reinicializa RDA_CODADO    								   �
		����������������������������������������������������������������/*/
        SetMemVar( "RD9_CODADO" , Space( GetSx3Cache( "RD9_CODADO" , "X3_TAMANHO" ) ) )

	End Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Garante que na Inclusao o Ponteiro do RD9 estara em Eof()    �
	����������������������������������������������������������������/*/
	PutFileInEof( "RD9" )

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( lLinOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �a270Rd9GdTudOk	 �Autor�Marinaldo de Jesus� Data �18/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Tudo Ok da GetDados para os Avaliados				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Function a270Rd9GdTudOk( oBrowse , nModelo )

Local nLoop		:= 0
Local nLoops	:= Len( aCols )

Local lTudOk	:= .T.

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
MyCursorWait()
	Begin Sequence

		/*
		��������������������������������������������������������������Ŀ
		� Valida Apenas na Inclusao e na Alteracao				       �
		����������������������������������������������������������������*/
		IF (;
				!( Inclui );
				.and.;
				!( Altera );
			)
			Break
		EndIF

		For nLoop := 1 To nLoops
			n := nLoop
			IF !( lTudOk := a270Rd9GdLinOk( oBrowse , NIL , nModelo ) )
				Break
			EndIF
		Next nLoop

	End Sequence

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( lTudOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9GdDelOk	�Autor�Marinaldo de Jesus     � Data �18/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a Delecao na GetDados dos Avaliados					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd9GdDelOk( nOpc , lNoChkFirst , lShowMsg )

Local lDelOk 		:= .T.
Local lStatusDel	:= .F.

Local aRd9NotChk
Local aRdaColsAll
Local aRdaColPos

Local bGdRstOk

Local cRd9CodAva
Local cRd9CodAdo
Local cRd9CodPro
Local cRd9KeyChk
Local cMsgInfo

Local dRd9DtiAva

Local nRd9CodAdo
Local nRd9CodPro
Local nRd9DtiAva
Local nRd9Delete

Local nRdaCodAdo
Local nRdaCodDor
Local nRdaCodPro
Local nRdaDtiAva
Local nRdaDelete
Local nRd9Order
Local nRd9Recno

Local oGdRda

DEFAULT lNoChkFirst	:= .F.
DEFAULT lShowMsg	:= .T.

Begin Sequence

	//Quando for Visualizacao ou Exclusao Abandona
	IF (;
			( nOpc == 2 ) .or. ;	//Visualizacao
			( nOpc == 5 );			//Exclusao
		)
		Break
	EndIF

	lStatusDel	:= !( GdDeleted() ) //Inverte o Estado

	nRd9CodAdo	:= GdFieldPos( "RD9_CODADO" )
	nRd9CodPro	:= GdFieldPos( "RD9_CODPRO" )
	nRd9DtiAva	:= GdFieldPos( "RD9_DTIAVA" )
	nRd9Delete	:= GdFieldPos( "GDDELETED"	)

	cRd9CodAva	:= GdFieldGet( "RD9_CODAVA" )
	cRd9CodAdo	:= GdFieldGet( "RD9_CODADO" )
	cRd9CodPro	:= GdFieldGet( "RD9_CODPRO" )
	dRd9DtiAva	:= GdFieldGet( "RD9_DTIAVA" )

	oGdRda		:= oGdRdaGet( APDA270_FOLDER_AVALIADORES )
	aRdaColsAll	:= RdaColsGet()
	nRdaCodAdo	:= GdFieldPos( "RDA_CODADO" , oGdRda:aHeader )
	nRdaCodPro	:= GdFieldPos( "RDA_CODPRO" , oGdRda:aHeader )
	nRdaDtiAva	:= GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader )
	nRdaDelete	:= GdFieldPos( "GDDELETED"	, oGdRda:aHeader )

	aRdaColPos	:= {;
						{ nRdaCodAdo , nRdaCodPro , nRdaDtiAva },;
						{ cRd9CodAdo , cRd9CodPro , dRd9DtiAva },;
						nRdaDelete;
					}

	IF ( lStatusDel )	//Deletar

		/*/
		��������������������������������������������������������������Ŀ
		� Verifica se o Item pode ser Deletado                         �
		����������������������������������������������������������������/*/
		nRd9Order := RetOrdem( "RD9" , "RD9_FILIAL+RD9_CODAVA+RD9_CODADO+RD9_CODPRO+DTOS(RD9_DTIAVA)" )
		cRd9KeyChk := ( cRd9CodAva + cRd9CodAdo + cRd9CodPro + Dtos( dRd9DtiAva ) )
		RD9->( dbSetOrder( nRd9Order ) )
		IF RD9->( MsSeek( xFilial( "RD9" ) + cRd9KeyChk , .F. ) )
			nRd9Recno	:= RD9->( Recno() )
			aRd9NotChk	:= { "RDA" , "RDC" }
			IF !( lDelOk := ApdChkDel( "RD9" , nRd9Recno , nOpc , cRd9KeyChk , .F. , NIL , NIL , aRd9NotChk , .T. , .T. ) )
   				cMsgInfo := STR0129 //"Este �tem n�o pode ser exclu�do."
   				IF ( lShowMsg )
   					//'Aviso de Inconsist�ncia!'
   					MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )
   				EndIF
				Break
			EndIF
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Deleta os Avaliadores correspondetes ao Avaliado Deletado    �
		����������������������������������������������������������������/*/
		GdDelItens( @oGdRda:aCols , aRdaColPos )
		GdDelItens( @aRdaColsAll  , aRdaColPos )
   		Break

	Else	//Restaurar

		/*/
		��������������������������������������������������������������Ŀ
		�Restaura os Avaliadores Anteriormente Deletados  			   �
		����������������������������������������������������������������/*/
		nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" , oGdRda:aHeader )
		bGdRstOk	:= { | aColsnLin , nLin | !Empty( aColsnLin[ nRdaCodAdo ] ) .and. !Empty( aColsnLin[ nRdaCodDor ] ) }
		GdRstItens( @oGdRda:aCols , aRdaColPos , bGdRstOk )
		GdRstItens( @aRdaColsAll  , aRdaColPos , bGdRstOk )
   		Break

	EndIF

End Sequence

Return( lDelOk )


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9bExit	�Autor�Marinaldo de Jesus     � Data �18/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Exit do Folder de Avaliados                					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd9bExit( oGdRd9 )

GdRdpRd9Chg( .F. , .T. )

Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRdpRd9Chg		 �Autor�Marinaldo de Jesus� Data �07/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Change da GetDados Agenda vs Avaliados						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function GdRdpRd9Chg( lAllToCol , lColToAll , nFolder , lRd9Bxit )

Local lRd9NoAlter	:= .T.

Local aRd9ColsAll
Local aRd9CposPes
Local aRd9CposSrt

Local bColsToAll
Local bAllToCols

Local cRd6Codigo
Local cKeyRdpRd9Chg

Local dRdpDatIni

Local lDeleted

Local oGdRdp
Local oGdRd9

Begin Sequence

	oGdRdp			:= oGdRdpGet()
	dRdpDatIni		:= GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )

	cRd6Codigo		:= GetMemVar( "RD6_CODIGO" )
	cKeyRdpRd9Chg	:= cRd6Codigo
	cKeyRdpRd9Chg	+= Dtos( dRdpDatIni )
	aRd9ColsAll		:= Rd9ColsGet()

	DEFAULT nFolder := APDA270_FOLDER_AVALIADOS
	IF (;
			( nFolder == APDA270_FOLDER_AVALIADOS );
			.and.;
			(;
				( cGdRdpRd9Chg == cKeyRdpRd9Chg );
				.and.;
				( lRd9NoAlter := ArrayCompare( aRd9ColsAll , aRd9LstColsAll ) );
			);
		)
		IF !( lRd9NoAlter )
			aRd9LstColsAll := aClone( aRd9ColsAll )
		EndIF
		Break
	EndIF
	cGdRdpRd9Chg	:= cKeyRdpRd9Chg

	/*/
	��������������������������������������������������������������Ŀ
	�Obtem as Informacoes para o GdColsExChange para o RD9         �
	����������������������������������������������������������������/*/
	lDeleted := ( nFolder <> APDA270_FOLDER_AVALIADOS )
	Rd9InfTrf(	APDA270_FOLDER_AVALIADOS,;
				@aRd9CposPes,;
				@aRd9CposSrt,;
				@bColsToAll	,;
				@bAllToCols	,;
				lDeleted	,;
				.F.			 ;
			  )

	/*/
	��������������������������������������������������������������Ŀ
	�Garanto que o Ponteiro Estara no Final do Arquivo para que nao�
	�Carregue Conteudo Invalido nos Inicializadores Padroes        �
	����������������������������������������������������������������/*/
	PutFileInEof( "RD9" )

	DEFAULT lAllToCol	:= .T.
	DEFAULT lColToAll	:= .F.
	IF (;
			( lColToAll );
			.and.;
			(;
				!( Inclui );
				.and.;
				!( Altera );
			);
		)
		lColToAll := .F.
	EndIF

	DEFAULT lRd9Bxit := .F.
	oGdRd9 := oGdRd9Get( nFolder )
	If 	lRd9Bxit .and. !ArrayCompare( oGdRd9:aCols , aRd9ColsAll )
		lColToAll := .T.
	EndIf
	GdColsExChange(	@aRd9ColsAll	,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
					@oGdRd9:aCols 	,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
					oGdRd9:aHeader	,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
					NIL				,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
					NIL				,;	//05 -> Chave para Busca no aColsAll para Carga do aCols
					aRd9CposSrt		,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
					aRd9CposPes		,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
					NIL				,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
					.T.				,;	//09 -> Conteudo do Elemento "Deleted" a ser Carregado na Remontagem dos aCols
					lColToAll		,;	//10 -> Se deve Transferir do aCols para o aColsAll
					lAllToCol		,;	//11 -> Se deve Transferir do aColsAll para o aCols
					.T.				,;	//12 -> Se Existe o Elemento de Delecao no aCols
					.T.				,;	//13 -> Se deve Carregar os Inicializadores padroes
					bColsToAll		,;	//14 -> Condicao para a Transferencia do aCols para o aColsAll
					bAllToCols		 ;	//15 -> Condicao para a Transferencia do aColsAll para o aCols
				 )

	oGdRd9:Goto( 1 )
	oGdRd9:Refresh()

End Sequence

Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9InfTrf		 �Autor�Marinaldo de Jesus� Data �27/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Monta as informacoes que serao utilizadas para a  transferen�
�          �cia de informacoes no GdColsExChange do RD9                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function Rd9InfTrf(	nFolder		,;
							aRd9CposPes	,;
							aRd9CposSrt	,;
							bColsToAll	,;
							bAllToCols	,;
							lChkDel		,;
							lOnlyCodAv	 ;
				  		)

Local cRd6Codigo

Local dRdpDatIni
Local dRdpDatFim

Local nRd9CodAva
Local nRd9CodAdo
Local nRd9DtIAva
Local nRd9DtFAva
Local nRd9Deleted
Local nRd9GhostCol

Local oGdRdp
Local oGdRd9

DEFAULT lChkDel		:= .F.
DEFAULT lOnlyCodAv	:= .F.

IF !( lOnlyCodAv )
	oGdRdp		:= oGdRdpGet()
	dRdpDatIni	:= GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )//GetMemVar( "RD6_DTINI" )//
	dRdpDatFim	:= GdFieldGet( "RDP_DATFIM" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )//GetMemVar( "RD6_DTFIM" )//
EndIF

cRd6Codigo		:= GetMemVar( "RD6_CODIGO" )

oGdRd9			:= oGdRd9Get( nFolder )
nRd9CodAva		:= GdFieldPos( "RD9_CODAVA" , oGdRd9:aHeader )
nRd9CodAdo		:= GdFieldPos( "RD9_CODADO" , oGdRd9:aHeader )
nRd9DtIAva		:= GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader )
nRd9DtFAva		:= GdFieldPos( "RD9_DTFAVA" , oGdRd9:aHeader )
nRd9GhostCol    := GdFieldPos( "RD9_REC_WT"	, oGdRd9:aHeader )

aRd9CposPes := {}
aAdd( aRd9CposPes , { nRd9CodAva , cRd6Codigo } )
IF !( lOnlyCodAv )
	aAdd( aRd9CposPes , { nRd9DtIAva , dRdpDatIni } )
	aAdd( aRd9CposPes , { nRd9DtFAva , dRdpDatFim } )
EndIF
IF ( lChkDel )
	nRd9Deleted	:= GdFieldPos( "GDDELETED"  , oGdRd9:aHeader )
	aAdd( aRd9CposPes , { nRd9Deleted , .F. } )
EndIF

aRd9CposSrt := {}
aAdd( aRd9CposSrt , nRd9CodAva )
aAdd( aRd9CposSrt , nRd9DtIAva )
aAdd( aRd9CposSrt , nRd9CodAdo )
aAdd( aRd9CposSrt , nRd9GhostCol )

bColsToAll	:= { | aCols , aHeader , nItem |;
												!Empty( aCols[ nItem , nRd9CodAva ] );
												.and.;
												!Empty( aCols[ nItem , nRd9DtIAva ] );
												.and.;
												!Empty( aCols[ nItem , nRd9CodAdo ] );
				}

bAllToCols	:= { | aColsAll , aHeaderAll , nFindKey | .T. }

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpChkChange�Autor�Marinaldo de Jesus     � Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Exit do Folder Agenda                      					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdpChkChange( oGdRdp , lRdpBxit )

Local aRdpLstCols	:= RdpColsGet( APDA270_ALSTCOLS )
Local aRdpCols 		:= RdpColsGet()

Local aRdpHeader
Local bEvalDele
Local bEvalAdd
Local nRdpDeleted

DEFAULT lRdpBxit := .F.
IF (;
		!( lRdpBxit );
		.and.;
		!( ArrayCompare( aRdpLstCols , oGdRdp:aCols ) );
	)
	aRdpHeader	:= RdpHeaderGet()
	nRdpDeleted	:= GdFieldPos( "GDDELETED" , aRdpHeader )
	bEvalDele	:= { |x,y| aRdpCols[ y , nRdpDeleted ] := .T. }
	aEval( aRdpCols , bEvalDele )
	bEvalAdd	:= { |x,y| aAdd( aRdpCols , aClone( oGdRdp:aCols[ y ] ) ) }
	aEval( oGdRdp:aCols , bEvalAdd )
	RdpColsSet( oGdRdp:aCols , APDA270_ALSTCOLS )
	RdpColsSet( oGdRdp:aCols , APDA270_ACOLS )
Else
	RdpColsSet( oGdRdp:aCols , APDA270_ACOLS )
EndIF

Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6bExit	�Autor�Marinaldo de Jesus     � Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o � valid do campo RD6_PERIOD no Fonte APDA270					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Function valRd6Exit(  )
Return Rd6bExit( @aFolders )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6bExit	�Autor�Marinaldo de Jesus     � Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Exit do Folder Principal                   					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd6bExit( aFolders )
Local cRd6CodTip	 := GetMemVar( "RD6_CODTIP" )
Local cRd5Tipo		:= Posicione("RD5",1,xFilial("RD5")+cRd6CodTip,"RD5_TIPO")


Rd9RdaBtnED()
If cRd5Tipo<>"3" // Projetos n�o tem agenda
	RdpBldCalend( @aFolders )
EndIf
Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRdpGetDet	  �Autor�Marinaldo de Jesus   � Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Informa Informacoes padroes para o Agendamento              �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �RdpBldCalend() em APDA270()									�
�������������������������������������������������������������������������/*/
Static Function GdRdpGetDet( aHeader , aGdAltera )

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local aNewHeader	:= {}
Local aCols			:= {}
Local aRdpNotFields	:= {}

Local lGdRdpGetDet	:= .F.

Local nLoop			:= 0
Local nLoops		:= Len( aHeader )
Local nOpcNewGd		:= ( GD_INSERT + GD_UPDATE + GD_DELETE )

Local oDlg			:= NIL
Local oGdRdp		:= NIL

/*/
��������������������������������������������������������������Ŀ
� Carrega os campos que nao Deverao Constar no aHeader	   	   �
����������������������������������������������������������������/*/
aAdd( aRdpNotFields , "RDP_CODAVA" )
aAdd( aRdpNotFields , "RDP_DATINI" )
aAdd( aRdpNotFields , "RDP_DATFIM" )
aAdd( aRdpNotFields , "RDP_DATGER" )
aAdd( aRdpNotFields , "RDP_INIRSP" )
aAdd( aRdpNotFields , "RDP_STATUS" )
aAdd( aRdpNotFields , "RDP_RSPADO" )
aAdd( aRdpNotFields , "RDP_RSPDOR" )
aAdd( aRdpNotFields , "RDP_RSPCON" )
aAdd( aRdpNotFields , "COLBMP" 	   )
aAdd( aRdpNotFields , "GHOSTCOL"   )

/*/
��������������������������������������������������������������Ŀ
� Carrega os campos para o Cabecalho     					   �
����������������������������������������������������������������/*/
For nLoop := 1 To nLoops
	IF ( aScan( aRdpNotFields , { |x| ( x == aHeader[ nLoop , 02 ] ) } ) > 0 )
		Loop
	EndIF
	aAdd( aNewHeader , aClone( aHeader[ nLoop ] ) )
Next nLoop

/*/
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������/*/
aAdvSize		:= MsAdvSize(  , .T., 200 )
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*/
��������������������������������������������������������������Ŀ
� Define o Bloco para a Teclas <CTRL-O>   ( Button OK da Enchoi�
� ceBar )													   �
����������������������������������������������������������������/*/
bSet15 := { || IF( oGdRdp:LinhaOk() , ( RestKeys( aSvKeys ) , oDlg:End() , lGdRdpGetDet := .T. ) , lGdRdpGetDet := .F. ) }

/*/
��������������������������������������������������������������Ŀ
� Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da En�
� choiceBar )												   �
����������������������������������������������������������������/*/
bSet24 := { || RestKeys( aSvKeys ) , oDlg:End() , lGdRdpGetDet := .F. }

/*/
�������������������������������������������������������������Ŀ
�Monta Dialogo para a selecao do Periodo 					  �
���������������������������������������������������������������/*/
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro + " - " + StrTran( OemToAnsi( STR0101 ) , "&" , "" ) ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	//'Agenda'

	/*/
	��������������������������������������������������������������Ŀ
	� Monta o Objeto GetDados para o SP8						   �
	����������������������������������������������������������������/*/
	oGdRdp	:= MsNewGetDados():New(		aObjSize[1,1]	,;
										aObjSize[1,2]	,;
										aObjSize[1,3]	,;
										aObjSize[1,4]	,;
										nOpcNewGd		,;
										"a270RdpGdLinOk"	,;
										"RdpGdTudOk"	,;
										""				,;
										aGdAltera		,;
										0				,;
										1				,;
										NIL				,;
										NIL				,;
										{ || .F. } 		,;
										oDlg			,;
										aNewHeader		,;
										aCols			 ;
									 )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , NIL )
/*/
�������������������������������������������������������������Ŀ
� Restaura as Teclas de Atalho                     	  		  �
���������������������������������������������������������������/*/
RestKeys( aSvKeys , .T. )

Return( lGdRdpGetDet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9RdaBtnED	�Autor�Marinaldo de Jesus     � Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Enable e Disable dos Botoes para Escolha de Participantes	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function Rd9RdaBtnED()

Local cRd6Montag
Local nFolder	:= 0
Local nX		:= 0

Begin Sequence

	IF (;
			( Inclui );
			.or.;
			( Altera );
		)

		cRd6Montag := GetMemVar( "RD6_MONTAG" )

		IF ( cRd6Montag == "3" )		//Automatica
			Eval( { || oRd9BtnGet() } ):Disable()
			Eval( { || oRdaBtnGet() } ):Disable()
			nFolder := aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJ_NUMBER ]
			For nX:=1 to nFolder
				aFolders[ APDA270_FOLDER_AVALIADORES, APDA270_FOLDER_OBJECTS , nX , APDA270_OBJ ] :Disable()
			Next
			Break
		EndIF

		IF ( cRd6Montag == "2" )	//Semi-Automatica
			Eval( { || oRd9BtnGet() } ):Disable()
			Eval( { || oRdaBtnGet() } ):Enable()
			Break
	    EndIF

		Eval( { || oRd9BtnGet() } ):Enable()
		Eval( { || oRdaBtnGet() } ):Enable()

	Else

		Eval( { || oRd9BtnGet() } ):Disable()
		Eval( { || oRdaBtnGet() } ):Disable()

	EndIF

End Sequence

Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaGdLinOk	 	 �Autor�Marinaldo de Jesus� Data �18/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a LinhaOk da GetDados para os Avaliadores			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Function a270GdLinOk( oBrowse , lShowMsg , nModelo )

Local lLinOk		:= .T.

Local aCposKey
Local aRdaColsAll
Local aColsReg
Local aRdhHeader
Local aRdhCols

Local cMsgInfo
Local cRdaCodAva
Local cRdaCodAdo
Local cRdaCodNet
Local cRdaNivel
Local cRdaCodDor
Local cRdaNome
Local cRdaCodPro
Local cRdaTipoAv
Local dRdaDtIAva
Local dRdaDtFAva

Local nMaxPar
Local nCountPar
Local nRdaCodAva
Local nRdaCodAdo
Local nRdaCodNet
Local nRdaCodDor
Local nRdaNome
Local nRdaDelete
Local nRdaDtIAva
Local nRdaDtFAva
Local nRdaCodPro
Local nRdaTipoAv
Local nRdhAt
Local nRdhCodNet
Local nRdhNivel
Local nColsDorAll
Local nLoop
Local nLoops

DEFAULT lShowMsg	:= .T.
DEFAULT nModelo		:= 4

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
MyCursorWait()

	Begin Sequence

		/*
		��������������������������������������������������������������Ŀ
		� Valida Apenas na Inclusao e na Alteracao				       �
		����������������������������������������������������������������*/
		IF (;
				!( Inclui );
				.and.;
				!( Altera );
			)
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Se a Linha da GetDados Nao Estiver Deletada				   �
		����������������������������������������������������������������/*/
		IF !( GdDeleted() )

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica se o Avaliado Esta Deletado e Nao Permite Alteracao �
			� e ou Inclusao de Novas Linhas								   �
			����������������������������������������������������������������/*/
			IF !( lLinOk := !GdRd9Deleted( "RDA" , aHeader , aCols , NIL , lShowMsg ) )
				/*/
				��������������������������������������������������������������Ŀ
				� Deleta a Linha atual da GetDados							   �
				����������������������������������������������������������������/*/
				GdFieldPut( "GDDELETED" , .T. )
				Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Itens Duplicados na GetDados						   �
			����������������������������������������������������������������/*/
			aCposKey := GetArrUniqe( "RDA" )
			IF !( lLinOk := GdCheckKey( aCposKey , nModelo , NIL , @cMsgInfo , lShowMsg ) )
				Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Campos Estao Devidamente Preenchidos		   �
			����������������������������������������������������������������/*/
			aCposKey := GdObrigat( aHeader )
			IF !( lLinOk := GdNoEmpty( aCposKey , NIL , NIL , NIL , NIL , @cMsgInfo , lShowMsg ) )
		    	Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o Conteudo dos Campos       						   �
			����������������������������������������������������������������/*/
			cRdaCodAva	:= GdFieldGet( "RDA_CODAVA" )
			cRdaCodAdo	:= GdFieldGet( "RDA_CODADO" )
			cRdaCodDor	:= GdFieldGet( "RDA_CODDOR" )
			cRdaNome	:= GdFieldGet( "RDA_NOME"	)
			cRdaCodPro	:= GdFieldGet( "RDA_CODPRO"	)
			dRdaDtIAva	:= GdFieldGet( "RDA_DTIAVA"	)
			dRdaDtFAva	:= GdFieldGet( "RDA_DTFAVA"	)
			cRdaCodNet	:= GdFieldGet( "RDA_CODNET" )
			cRdaNivel	:= GdFieldGet( "RDA_NIVEL"  )
			cRdaTipoAv	:= GdFieldGet( "RDA_TIPOAV" )

			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o Posicionamento dos Campos							   �
			����������������������������������������������������������������/*/
			nRdaCodAva	:= GdFieldPos( "RDA_CODAVA" )
			nRdaCodAdo	:= GdFieldPos( "RDA_CODADO" )
			nRdaCodNet	:= GdFieldPos( "RDA_CODNET" )
			nRdaNivel	:= GdFieldPos( "RDA_NIVEL"  )
			nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" )
			nRdaNome	:= GdFieldPos( "RDA_NOME"	)
			nRdaCodPro	:= GdFieldPos( "RDA_CODPRO"	)
			nRdaDtIAva	:= GdFieldPos( "RDA_DTIAVA"	)
			nRdaDtFAva	:= GdFieldPos( "RDA_DTFAVA"	)
			nRdaTipoAv	:= GdFieldPos( "RDA_TIPOAV"	)
			nRdaDelete	:= GdFieldPos( "GDDELETED"  )

			/*/
			��������������������������������������������������������������Ŀ
			� Percorre Todos os Avaliadores do Avaliado em Qustao  conforme�
			� Projeto 													   �
			����������������������������������������������������������������/*/
			aColsReg	:= {}
			nCountPar	:= 0
			aEval( aCols ,	{ |x,y| IF(;
										(;
											( x[nRdaCodAdo] == cRdaCodAdo );	//Mesmo Codigo de Avaliado
											.and.;
											( x[nRdaCodDor] == cRdaCodDor );	//Mesmo Codigo de Avaliador
											.and.;
											( x[nRdaCodPro] == cRdaCodPro );	//Mesmo Codigo de Projeto
											.and.;
											( x[nRdaTipoAv] == cRdaTipoAv );	//Mesmo Flag de Avaliacao
											.and.;
											( y <> n );							//Nao for o Registro Atual
											.and.;
											!( x[nRdaDelete] );					//Nao Estiver Deletado
										 ),;
										(;
											++nCountPar,;
											aAdd( aColsReg , y );
										),;
										NIL;
									   );
							};
				  )

			/*/
			��������������������������������������������������������������Ŀ
			� Obtem o Posicionamento dos Campos para o RDH				   �
			����������������������������������������������������������������/*/
			aRdhHeader	:= RdhHeaderGet()
			aRdhCols	:= RdhColsGet()

			nRdhCodNet	:= GdFieldPos( "RDH_CODNET" , aRdhHeader )
			nRdhNivel	:= GdFieldPos( "RDH_NIVEL"	, aRdhHeader )

			/*/
			��������������������������������������������������������������Ŀ
			� Procura a Rede Para Obtencao do Numero de Participantes	   �
			����������������������������������������������������������������/*/
			IF ( ( nRdhAt := aScan( aRdhCols , { |x| ( x[nRdhCodNet] == cRdaCodNet ) .and. ( x[nRdhNivel] == cRdaNivel ) } ) ) > 0 )

				/*/
				��������������������������������������������������������������Ŀ
				� Obtem o Numero de Participantes de Acordo com a Rede		   �
				����������������������������������������������������������������/*/
				nMaxPar := GdFieldGet( "RDH_NUMPAR" , nRdhAt , NIL , aRdhHeader , aRdhCols )
				/*/
				��������������������������������������������������������������Ŀ
				� Se Houver Avaliacao de Consenso, Incrementa Maximo de Partici�
				� pantes Avaliadores										   �
				����������������������������������������������������������������/*/
				IF ( cRdaTipoAv == "1" )
					nMaxPar *= 2
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				� Verifica Se o Numero de Participantes nao Extrapolou o Numero�
				� de Participantes Definido na Rede							   �
				����������������������������������������������������������������/*/
		        IF !( lLinOk := ( nCountPar <= nMaxPar ) )
					cMsgInfo := ( STR0023 + CRLF )	//'Numero de Avaliadores Maior que o permitido para a Rede.'
		            cMsgInfo += CRLF
		            cMsgInfo += ( STR0026 + " " + AllTrim( Str( nCountPar ) ) + CRLF ) //'Participantes Selecionados: '
					cMsgInfo += CRLF
					cMsgInfo += ( STR0027 + " " + AllTrim( nMaxPar ) ) //'Numero Permitido: '
		        	IF ( lShowMsg )
		        		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia!'
		        	EndIF
					Break
				EndIF

			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Data Inicial eh Maior que Data Final		   �
			����������������������������������������������������������������/*/
			IF !( lLinOk := ( dRdaDtIAva <= dRdaDtfAva ) )
		    	cMsgInfo := STR0072	//'A Data Inicial n�o pode ser maior que a Data Final'###'Aviso de Inconsist�ncia!'
		    	IF ( lShowMsg )
		    		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )
		    	EndIF
		    	Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se a Data Inicial e Final estao Dentro do Periodo de�
			� finido para a Avalliacao									   �
			����������������������������������������������������������������/*/
			IF !( lLinOk := ( dRdaDtIAva >= GetMemVar( "RD6_DTINI" ) .and. dRdaDtfAva <= GetMemVar( "RD6_DTFIM" ) ) )
		    	IF ( ( dRdaDtIAva < GetMemVar( "RD6_DTINI" ) ) .and. ( dRdaDtfAva <= GetMemVar( "RD6_DTFIM" ) ) )
		    		cMsgInfo := STR0072	//'A Data Inicial n�o pode ser menor que a Data Inical da Avalia��o'
		    	ElseIF ( dRdaDtfAva > GetMemVar( "RD6_DTFIM" ) ) .and. ( dRdaDtIAva >= GetMemVar( "RD6_DTINI" ) )
		    		cMsgInfo := STR0076	//'A Data Final n�o pode ser maior que a Data Final da Avalia��o'
		    	Else
		    		cMsgInfo := STR0077	//'As Datas, Inicial e Final, est�o fora do per�odo definido para a Avalia��o'
		    	EndIF
	    		cMsgInfo	+= CRLF
	    		cMsgInfo	+= CRLF
	    		cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
	    		cMsgInfo	+= ( Dtoc( GetMemVar( "RD6_DTINI" ) ) + " - " + Dtoc( GetMemVar( "RD6_DTFIM" ) ) )
	    		IF ( lShowMsg )
	    			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
		    	EndIF
		    	Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Se a Data Inicial e Final nao Conflitam com Periodos Ja  Exis�
			� tentes													   �
			����������������������������������������������������������������/*/
			IF ( ( nLoops := Len( aColsReg ) ) > 0 )
				For nLoop := 1 To nLoops
					IF (;
							( aCols[ aColsReg[ nLoop ] , nRdaDelete ] );
							.or.;
							( n == aColsReg[ nLoop ] );
						)
						Loop
					EndIF
					IF ConflictDate( dRdaDtIAva , dRdaDtfAva , aCols[ aColsReg[ nLoop ] , nRdaDtIAva ] , aCols[ aColsReg[ nLoop ] , nRdaDtFAva ] )
						lLinOk := .F.
					EndIF
					IF !( lLinOk )
		    			cMsgInfo := STR0073	//'A Data Inicial ou Final est� conflitando com per�odo j� existente'
			    		cMsgInfo += CRLF
			    		cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRdaDtiAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( dRdaDtiAva )
						cMsgInfo += " - "
						cMsgInfo += aHeader[ nRdaDtfAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( dRdaDtfAva )
			    		cMsgInfo += CRLF
			    		cMsgInfo += CRLF
			    		cMsgInfo += STR0074
			    		cMsgInfo += Alltrim( Str( aColsReg[ nLoop ] ) )
						cMsgInfo += ". "
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRdaCodAdo , 01 ]
						cMsgInfo += ": "
						cMsgInfo += cRdaCodAdo
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRdaCodDor , 01 ]
						cMsgInfo += ": "
						cMsgInfo += cRdaCodDor
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRdaCodPro , 01 ]
						cMsgInfo += ": "
						cMsgInfo += cRdaCodPro
						cMsgInfo += CRLF
						cMsgInfo += CRLF
						cMsgInfo += aHeader[ nRdaDtiAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( aCols[ aColsReg[ nLoop ] , nRdaDtiAva ] )
						cMsgInfo += " - "
						cMsgInfo += aHeader[ nRdaDtfAva , 01 ]
						cMsgInfo += ": "
						cMsgInfo += Dtoc( aCols[ aColsReg[ nLoop ] , nRdaDtfAva ] )
		    			IF ( lShowMsg )
			    			MsgInfo( OemToAnsi( cMsgInfo ),  OemToAnsi( STR0022 ) ) //'Aviso de Inconsist�ncia'
						EndIF
						Break
					EndIF
				Next nLoop
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Carrega Array com Todos os Participantes Avaliadores ja  Sele�
			� cionados													   �
			����������������������������������������������������������������/*/
			aRdaColsAll	:= RdaColsGet()

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica se o participante Avaliador ja foi selecionado em ou�
			� tra Rede e nao Permite nova Selecao						   �
			����������������������������������������������������������������/*/
			IF !( lLinOk := (;
								nColsDorAll := aScan( aRdaColsAll , { |x|	x[nRdaCodAva] == cRdaCodAva .and.	;
																			x[nRdaCodAdo] == cRdaCodAdo .and.	;
																			x[nRdaCodNet] != cRdaCodNet	.and.	;
																			x[nRdaNivel ] == cRdaNivel	.and.	;
																			x[nRdaCodDor] == cRdaCodDor .and.	;
																			x[nRdaCodPro] == cRdaCodPro .and.	;
																			x[nRdaDtiAva] == dRdaDtiAva .and.	;
																			x[nRdaDtfAva] == dRdaDtfAva .and.	;
																			x[nRdaTipoAv] == cRdaTipoAv .and.	;
																			!x[nRdaDelete]						;
																	};
													);
							) == 0 ;
				)
				cMsgInfo := STR0029 + CRLF	//'O Avaliador em questao :'
				cMsgInfo += CRLF
				cMsgInfo += ( aHeader[ nRdaCodDor , 01 ] + ": " + cRdaCodDor + CRLF )
				cMsgInfo += CRLF
				cMsgInfo += ( aHeader[ nRdaNome   , 01 ] + ": " + cRdaNome   + CRLF )
				cMsgInfo += CRLF
				cMsgInfo += STR0040 + " ( " + aRdaColsAll[ nColsDorAll , nRdaCodNet ] + " )" + CRLF // 'Ja foi Selecionado em outra Rede.'
				cMsgInfo += CRLF
				cMsgInfo += STR0030 + CRLF	//'Escolha um outro Avaliador ou Delete o Avaliador Atual.'
				IF ( lShowMsg )
					MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	// 'Aviso de Inconsist�ncia!'
				EndIF
				Break
			EndIF

		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Reinicializa RDA_CODDOR 									   �
		����������������������������������������������������������������/*/
		SetMemVar( "RDA_CODDOR" , Space( GetSx3Cache( "RDA_CODDOR" , "X3_TAMANHO" ) ) )

	End Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Garante que na Inclusao o Ponteiro do RDP estara em Eof()    �
	����������������������������������������������������������������/*/
	PutFileInEof( "RDA" )

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( lLinOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �a270RdaGdTudOk	 �Autor�Marinaldo de Jesus� Data �18/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Tudo Ok da GetDados para os Avaliadores			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Function a270GdTudOk( oBrowse , nModelo )

Local lTudOk	:= .T.
Local nLoop		:= 0
Local nLoops	:= Len( aCols )

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
MyCursorWait()

	Begin Sequence

		/*
		��������������������������������������������������������������Ŀ
		� Valida Apenas na Inclusao e na Alteracao				       �
		����������������������������������������������������������������*/
		IF (;
				!( Inclui );
				.and.;
				!( Altera );
			)
			Break
		EndIF

		For nLoop := 1 To nLoops
			n := nLoop
			IF !( lTudOk := a270GdLinOk( oBrowse , NIL , nModelo ) )
				Break
			EndIF
		Next nLoop


	End Sequence

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( lTudOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaGdDelOk	�Autor�Marinaldo de Jesus     � Data �18/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a Delecao na GetDados dos Avaliadores				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()	                                                �
�������������������������������������������������������������������������/*/
Static Function RdaGdDelOk( nOpc , lNoChkFirst , lShowMsg )

Local lDelOk 		:= .T.
Local lStatusDel	:= .F.

Local aRdaNotChk
Local cRdaKeyChk
Local cRdaCodAva
Local cRdaCodAdo
Local cRdaCodPro
Local cRdaCodDor
Local cRdaNivel
Local cRdaTipoAv
Local dRdaDtiAva
Local cRdaCodNet
Local nRdaOrder
Local nRdaRecno

Static lFirstDelOk
Static lLstDelOk

DEFAULT lFirstDelOk	:= .T.
DEFAULT lLstDelOk	:= .T.
DEFAULT lNoChkFirst	:= .F.
DEFAULT lShowMsg	:= .T.

Begin Sequence

	//Quando for Visualizacao ou Exclusao Abandona
	IF (;
			( nOpc == 2 ) .or. ;	//Visualizacao
			( nOpc == 5 );			//Exclusao
		)
		Break
	EndIF

	IF !( lNoChkFirst )
		//Apenas se for a primeira vez
		IF !( lFirstDelOk )
			lFirstDelOk	:= .T.
			lDelOk 		:= lLstDelOk
			lLstDelOk	:= .T.
			Break
		EndIF
	Else
		lFirstDelOk	:= .T.
	EndIF

	lStatusDel	:= !( GdDeleted() ) //Inverte o Estado

	IF ( lStatusDel )	//Deletar

		cRdaCodAva	:= GdFieldGet( "RDA_CODAVA" )
		cRdaCodAdo	:= GdFieldGet( "RDA_CODADO" )
		cRdaCodPro	:= GdFieldGet( "RDA_CODPRO" )
		cRdaCodDor	:= GdFieldGet( "RDA_CODDOR" )
		dRdaDtiAva	:= GdFieldGet( "RDA_DTIAVA" )
		cRdaNivel	:= GdFieldGet( "RDA_NIVEL"  )
		cRdaTipoAv	:= GdFieldGet( "RDA_TIPOAV" )
		cRdaCodNet	:= GdFieldGet( "RDA_CODNET" )

		/*/
		��������������������������������������������������������������Ŀ
		� Verifica se o Item pode ser Deletado                         �
		����������������������������������������������������������������/*/
		nRdaOrder := RetOrdem( "RDA" , "RDA_FILIAL+RDA_CODAVA+RDA_CODADO+RDA_CODPRO+RDA_CODDOR+DTOS(RDA_DTIAVA)+RDA_CODNET+RDA_NIVEL+RDA_TIPOAV" )
		cRdaKeyChk := ( cRdaCodAva + cRdaCodAdo + cRdaCodPro + cRdaCodDor + Dtos( dRdaDtiAva ) + cRdaCodNet + cRdaNivel + cRdaTipoAv )
		RDA->( dbSetOrder( nRdaOrder ) )
		IF RDA->( MsSeek( xFilial( "RDA" ) + cRdaKeyChk , .F. ) )
			nRdaRecno := RDA->( Recno() )
			aRdaNotChk	:= { "RDC" }
			IF !( lDelOk := ApdChkDel( "RDA" , nRdaRecno , nOpc , cRdaKeyChk , .F. , NIL , NIL , aRdaNotChk , .T. , .T. ) )
   				cMsgInfo := STR0129 //"Este �tem n�o pode ser exclu�do."
   				IF ( lShowMsg )
   					//'Aviso de Inconsist�ncia!'
   					MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )
   				EndIF
   				lLstDelOk := lDelOk
   				//Ja Passou pela funcao
				lFirstDelOk := .F.
				Break
			EndIF
		EndIF

   		//Ja Passou pela funcao
		lFirstDelOk := .F.
   		Break

	Else	//Restaurar

		/*/
		��������������������������������������������������������������Ŀ
		� Verifica se o Avaliado Esta Deletado e Nao Permite Restaurar �
		� o Avaliador sem Antes Restaurar o Avaliado				   �
		����������������������������������������������������������������/*/
		//'Esta Linha n�o pode ser restaurada. Restaure primeiro o Avaliado.'
		lDelOk := !( GdRd9Deleted( "RDA" , aHeader , aCols , STR0090 , lShowMsg ) )
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
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRd9Deleted	 �Autor�Marinaldo de Jesus� Data �04/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Avaliado Esta Deletado                	    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function GdRd9Deleted( cAlias , aHeader , aCols , cMsgInfo , lShowMsg )

Local lGdRd9Deleted	:= .F.

Local cPrefixoCpo

Local bAscan

Local cCodAva
Local cCodAdo
Local cCodPro

Local dDtiAva

Local nCodAva
Local nCodAdo
Local nCodPro
Local nDtiAva
Local nPosRd9
Local nRd9CodAva
Local nRd9CodAdo
Local nRd9CodPro
Local nRd9DtiAva
Local nRd9Deleted

Local oGdRd9

Begin Sequence

	IF ( lBldAvaAuto )
		Break
	EndIF

	DEFAULT cMsgInfo		:= STR0021	//'Nao pode haver insercao de novas informacoes para Participantes (Avaliados) Deletados'
	DEFAULT lShowMsg		:= .T.

	cPrefixoCpo	:= ( PrefixoCpo( cAlias ) + "_" )
	oGdRd9		:= oGdRd9Get( APDA270_FOLDER_AVALIADOS )

	nCodAva	:= GdFieldPos( cPrefixoCpo + "CODAVA" , aHeader )
	cCodAva	:= aCols[ n , nCodAva ]
	nCodAdo	:= GdFieldPos( cPrefixoCpo + "CODADO" , aHeader )
	cCodAdo := aCols[ n , nCodAdo ]
	nCodPro	:= GdFieldPos( cPrefixoCpo + "CODPRO" , aHeader )
	cCodPro := aCols[ n , nCodPro ]
	nDtiAva	:= GdFieldPos( cPrefixoCpo + "DTIAVA" , aHeader )
	dDtiAva	:= aCols[ n , nDtiAva ]

	nRd9CodAva	:= GdFieldPos( "RD9_CODAVA" ,  oGdRd9:aHeader )
	nRd9CodAdo	:= GdFieldPos( "RD9_CODADO" ,  oGdRd9:aHeader )
	nRd9Deleted	:= GdFieldPos( "GDDELETED"	,  oGdRd9:aHeader )

	nRd9CodPro	:= GdFieldPos( "RD9_CODPRO" ,  oGdRd9:aHeader )
	nRd9DtiAva	:= GdFieldPos( "RD9_DTIAVA" ,  oGdRd9:aHeader )
	nRd9DtfAva	:= GdFieldPos( "RD9_DTFAVA" ,  oGdRd9:aHeader )

	bAscan := { |x| ( x[nRd9CodAva] == cCodAva );
					.and.;
					( x[nRd9CodAdo] == cCodAdo );
					.and.;
					( x[nRd9CodPro] == cCodPro );
					.and.;
					( x[nRd9DtiAva] == dDtiAva );
			  }

	IF ( ( nPosRd9 := aScan( oGdRd9:aCols , bAscan ) ) > 0 )
		lGdRd9Deleted := oGdRd9:aCols[ nPosRd9 , nRd9Deleted ]
	EndIF

	IF ( lShowMsg )
		IF ( lGdRd9Deleted )
			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia!'
		EndIF
	EndIF

End Sequence

Return( lGdRd9Deleted )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270AllWaysTrue�Autor�Marinaldo de Jesus�Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna Funcao de Validacao de Acordo com a Opcao do aRotina�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function APDA270AllWaysTrue( nOpc , cVldFunction )

Local cRetFunction := "AllWaysTrue()"

DEFAULT cVldFunction := cRetFunction

IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )
	cRetFunction := cVldFunction
EndIF

Return( cRetFunction )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270TudoOk	 �Autor�Marinaldo de Jesus� Data �18/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar Todos os Objetos dos Folders						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function APDA270TudoOk( nOpc )

Local nFldValid			:= 0
Local nFldsValid		:= APDA270_ELEMENTOS_FOLDER
Local lAPDA270TudoOk	:= .T.

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Efetua a Validacao de Todos os Folders					   �
	����������������������������������������������������������������/*/
	For nFldValid := 1 To nFldsValid
		MyCursorWait()
		IF !( lAPDA270TudoOk := APDA270SetOption( nOpc , nFldValid , nFldValid , .T. , .T. ) )
			Break
		EndIF
	Next nFldValid

End Sequence
RstEnchoVlds()
Return( lAPDA270TudoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270SelPartic �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Selecao de Participantes da Avaliacao						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function APDA270SelPartic(	nOpc		,;	//Opcao do aRotina
									cDlgTitulo	,;	//Titulo do Dialogo
									aPartSelect	,;	//Array com os Participantes Selecionados
									aCposLbx	,;	//Campos para a ListBox
									cKeyFilter	,;	//Filtro para a ListBox
									aKeyFields	,;	//Array com as Chaves para a Listbox
									cAlias		,;	//Alias para a Selecao do Participante
									aQuery		 ;	//Array com os Indices para a FilBrowse
								)

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= MsAdvSize(  , .T. , 390 )
Local aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
Local aObjCoords	:= { { 0 , 0 , .T. , .T. } }
Local aObjSize 		:= MsObjSize( aInfoAdvSize , aObjCoords )
Local bSet15		:= { || lSelectOk := .T. , RestKeys( aSvKeys , .T. ) , oDlg:End() }
Local bSet24		:= { || RestKeys( aSvKeys , .T. ) , oDlg:End() }
Local lSelectOk		:= .F.
Local oDlg 			:= NIL

DEFAULT cAlias		:= "RD0"
DEFAULT aQuery		:= {}

DEFINE MSDIALOG oDlg TITLE cDlgTitulo From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

	/*/
	��������������������������������������������������������������Ŀ
	� Altera o Estado do Cursor  								   �
	����������������������������������������������������������������/*/
	MyCursorWait()

		ApdListFilter(	nOpc			,;	//01 -> Opcao do aRotina
						aObjSize[1]		,;	//02 -> Array com o Dimensionamento Disponivel
						@aPartSelect	,;	//03 -> Array dos Participantes Selecionados
						aCposLbx		,;	//04 -> Array com os Campos para o ListBox
						oDlg			,;	//05 -> Dialogo onde sera montado o ListBox
						cAlias			,;	//06 -> Alias para a Carga das Informacoes
						cKeyFilter		,;	//07 -> Filtro Inicial
						aKeyFields		,;	//08 -> Array contendo os campos Chaves
						NIL				,;	//09 -> Fonte
						NIL				,;	//10 -> Objeto ListBox dos Participantes a serem Selecionados
						NIL				,;	//11 -> Objeto ListBox dos Participantes Selecionados
						aQuery			 ;	//12 -> Array com os Indices para a FilBrowse
					)

	/*/
	��������������������������������������������������������������Ŀ
	� Restaura o Estado do Cursor								   �
	����������������������������������������������������������������/*/
	MyCursorArrow()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24  )

RestKeys( aSvKeys , .T. )

Return( lSelectOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �BtnRd9Select	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Mostra novo Dialogo para Selecao dos Participantes Avaliados�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Button para Selecao dos Avaliados em APDA270()				�
�������������������������������������������������������������������������/*/
Static Function BtnRd9Select( nOpc )

Local aPartSelect	:= {}
Local aKeyFields	:= { "RD0_FILIAL" , "RD0_CODIGO" }
Local aCposHeader	:= ApdCarrCpos( "RD0" , NIL , { "RD0_FILIAL" , "RD0_CODIGO" , "RD0_NOME" } )
Local aCposLbx		:= aCposHeader[1]
Local aHeaderLbx	:= aCposHeader[2]

Local cKeyFilter

Local lSelect

Local nLbxFilial
Local nLbxCodigo
Local nLbxNome

nLbxFilial	:= ( GdFieldPos( "RD0_FILIAL" , aHeaderLbx ) + 1 )
nLbxCodigo	:= ( GdFieldPos( "RD0_CODIGO" , aHeaderLbx ) + 1 )
nLbxNome	:= ( GdFieldPos( "RD0_NOME"   , aHeaderLbx ) + 1 )

/*/
��������������������������������������������������������������Ŀ
�Garanto que o Ponteiro Estara no Final do Arquivo para que nao�
�Carregue Conteudo Invalido nos Inicializadores Padroes        �
����������������������������������������������������������������/*/
PutFileInEof( "RD9" )

MsAguarde(;
				{ ||    MyCursorWait(),;
						Rd9Gd2Rd9Lbx(	oGdRd9Get()		,;
										@aPartSelect	,;
										aCposLbx		,;
										nLbxFilial		,;
										nLbxCodigo		,;
										nLbxNome		 ;
			 	 					),;
						MyCursorArrow();
				};
			)

IF ( lSelect := APDA270SelPartic(	nOpc					,;
									OemToAnsi( STR0024 )	,;	//'Selecionar Participantes ( Avaliados )'
									@aPartSelect			,;
									aCposLbx				,;
									cKeyFilter				,;
									aKeyFields				 ;
								);
	 )
	MsAguarde(;
					{ ||	MyCursorWait(),;
							Rd9Lbx2Rd9Gd(	oGdRd9Get()		,;
											@aPartSelect	,;
											aCposLbx		,;
											nLbxCodigo		,;
											nLbxNome	 	 ;
				 	 					),;
							MyCursorArrow();
					};
				)
	Eval( { || oGdRd9Get() } ) :Refresh()
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9Gd2Rd9Lbx	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Carrega Participantes Avaliados da GetDados para o ListBox	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �BtnRd9Select() em APDA270()									�
�������������������������������������������������������������������������/*/
Static Function Rd9Gd2Rd9Lbx(	oGdRd9			,;	//Objeto GetDados dos Avaliados
								aPartSelect		,;	//Objeto GetDados dos Avaliados
								aCposLbx		,;	//Campos para a ListBox para a Selecao de Participantes
								nLbxFilial		,;	//Posicao na Filial na ListBox de Participantes
								nLbxCodigo		,;	//Posicao do Codigo do Participante na ListBox de Participantes
								nLbxNome		 ;	//Posicao do Nome do Participante na ListBox de Participantes
							  )

Local aItens		:= {}
Local bAeval		:= { |x,y| IF( !x[nRd9Delete] .and. !Empty(x[nRd9CodAdo] ) , aAdd( aItens , y ) , NIL ) }
Local cRd0Fil		:= xFilial("RD0")
Local nRd9CodAdo	:= GdFieldPos( "RD9_CODADO"	, oGdRd9:aHeader )
Local nRd9Nome		:= GdFieldPos( "RD9_NOME"	, oGdRd9:aHeader )
Local nRd9Delete    := GdFieldPos( "GDDELETED"	, oGdRd9:aHeader )

Local bAscan
Local nItem
Local nItens

aEval( oGdRd9:aCols , bAeval )
IF ( ( nItens := Len( aItens ) ) > 0 )
	bAscan := { |x| ( x[nLbxFilial] == cRd0Fil );
			  		.and.;
			  		( x[nLbxCodigo] == oGdRd9:aCols[ aItens[ nItem ] , nRd9CodAdo ] );
			  }
	aPartSelect	:= Array( nItens , ( Len( aCposLbx ) + 1 ) )
	For nItem := 1 To nItens
		IF ( aScan( aPartSelect , bAscan ) == 0 )
			aPartSelect[ nItem , 01			]	:= .F.
			aPartSelect[ nItem , nLbxFilial	]	:= cRd0Fil
			aPartSelect[ nItem , nLbxCodigo	]	:= oGdRd9:aCols[ aItens[ nItem ] , nRd9CodAdo	]
			aPartSelect[ nItem , nLbxNome	]	:= oGdRd9:aCols[ aItens[ nItem ] , nRd9Nome		]
		EndIF
	Next nItem
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9Lbx2Rd9Gd	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Carrega Participantes Avaliados da ListBox para a GetDados  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �BtnRd9Select() em APDA270()									�
�������������������������������������������������������������������������/*/
Static Function Rd9Lbx2Rd9Gd(	oGdRd9			,;	//Objeto GetDados dos Avaliados
								aPartSelect		,;	//Objeto GetDados dos Avaliados
								aCposLbx		,;	//Campos para a ListBox para a Selecao de Participantes
								nLbxCodigo		,;	//Posicao do Codigo do Participante na ListBox de Participantes
								nLbxNome	 	 ;	//Posicao do Nome do Participante na ListBox de Participantes
							  )

Local oGdRdp 		:= oGdRdpGet()
Local aRdpCols 		:= RdpColsGet()
Local cRd6Codigo	:= GetMemVar( "RD6_CODIGO" )
Local cRd6CodPro	:= GetMemVar( "RD6_CODPRO" )
Local dRd9DtiAva	:= GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )//GetMemVar( "RD6_DTINI" )//
Local dRd9DtfAva	:= GdFieldGet( "RDP_DATFIM" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )//GetMemVar( "RD6_DTFIM" )//
Local nRd9CodAva	:= GdFieldPos( "RD9_CODAVA"	, oGdRd9:aHeader )
Local nRd9CodAdo	:= GdFieldPos( "RD9_CODADO"	, oGdRd9:aHeader )
Local nRd9Nome		:= GdFieldPos( "RD9_NOME"	, oGdRd9:aHeader )
Local nRd9DtiAva	:= GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader )
Local nRd9DtfAva	:= GdFieldPos( "RD9_DTFAVA" , oGdRd9:aHeader )
Local nRd9CodPro	:= GdFieldPos( "RD9_CODPRO"	, oGdRd9:aHeader )
Local nRd9Delete	:= GdFieldPos( "GDDELETED"	, oGdRd9:aHeader )

Local aRd9SvCols
Local bRd9Sort
Local lRd9Modify
Local nLoop
Local nLoops
Local aAuxRd9 := {}
Private aHeader	:= oGdRd9:aHeader
Private aCols
Private n

IF ( ( Len( oGdRd9:aCols ) == 1 ) .and. Empty( oGdRd9:aCols[ 1 , nRd9CodAdo ] ) )
	oGdRd9:aCols[ 1 , nRd9Delete ] := .T.
EndIF

aRd9SvCols	:= aClone( oGdRd9:aCols )
aAuxRd9 := aClone( oGdRd9:aCols )
nLoops := Len( aPartSelect )
For nLoop := 1 To nLoops
	aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
	oGdRd9:aCols:= aClone( aAuxRd9 )
	aCols[ 1 , nRd9CodAva ] := cRd6Codigo
	aCols[ 1 , nRd9CodAdo ] := aPartSelect[ nLoop , nLbxCodigo	]
	aCols[ 1 , nRd9Nome   ] := aPartSelect[ nLoop , nLbxNome	]
	aCols[ 1 , nRd9DtiAva ] := dRd9DtiAva
	aCols[ 1 , nRd9DtfAva ] := dRd9DtfAva
	If !Empty(cRd6CodPro)
			aCols[ 1 , nRd9CodPro ] := cRd6CodPro
	EndIf
	//aCols[ 1 , nRd9Delete ] := .F.
	aAdd( oGdRd9:aCols , aClone( aCols[ 01 ] ) )
	aCols	:= oGdRd9:aCols
	n		:= Len( oGdRd9:aCols )
	IF !( a270Rd9GdLinOk( NIL , .F. , 1 ) )
		aDel( oGdRd9:aCols , n )
		aSize( oGdRd9:aCols , --n )
	EndIF
	aAuxRd9 := aClone( oGdRd9:aCols )
Next nLoop

lRd9Modify := !( ArrayCompare( aRd9SvCols , oGdRd9:aCols ) )
IF ( lRd9Modify )
	bRd9Sort := { |x,y|	( x[ nRd9CodAdo ] + Dtos( x[ nRd9DtiAva] ) + IF( !x[ nRd9Delete ] , "0" , "1" ) );
						<;
						( y[ nRd9CodAdo ] + Dtos( y[ nRd9DtiAva] ) + IF( !y[ nRd9Delete ] , "0" , "1" ) );
				}
	aSort( oGdRd9:aCols , NIL , NIL , bRd9Sort )
	GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 3 , 1 ) , oGdRdp:oBrowse:nAt , oGdRdp:aHeader , aRdpCols , .F. )
	GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 3 , 1 ) , oGdRdp:oBrowse:nAt , oGdRdp:aHeader , oGdRdp:aCols , .F. )
EndIF
oGdRd9:Goto( 1 )

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �BtnRdaSelect	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Mostra novo Dialogo para Selecao dos Participantes  Avaliado�
�          �res															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Button para Selecao dos Avaliadores em APDA270()			�
�������������������������������������������������������������������������/*/
Static Function BtnRdaSelect( nOpc )

Local aQuery			:= {}
Local aPartSelect		:= {}
Local aKeyFields		:= { "RD0_FILIAL" , "RD0_CODIGO" }
Local aCposHeader		:= ApdCarrCpos( "RD0" , NIL , { "RD0_FILIAL" , "RD0_CODIGO" , "RD0_NOME" } )
Local aCposLbx			:= aCposHeader[1]
Local aHeaderLbx		:= aCposHeader[2]

Local lSelect
Local cKeyFilter
Local nLbxFilial
Local nLbxCodigo
Local nLbxNome

Begin Sequence

	cKeyFilter := ApdDorFilterBuild( oGdRdaGet() )

	nLbxFilial	:= ( GdFieldPos( "RD0_FILIAL" , aHeaderLbx ) + 1 )
	nLbxCodigo	:= ( GdFieldPos( "RD0_CODIGO" , aHeaderLbx ) + 1 )
	nLbxNome	:= ( GdFieldPos( "RD0_NOME"   , aHeaderLbx ) + 1 )

	/*/
	��������������������������������������������������������������Ŀ
	�Garanto que o Ponteiro Estara no Final do Arquivo para que nao�
	�Carregue Conteudo Invalido nos Inicializadores Padroes        �
	����������������������������������������������������������������/*/
	PutFileInEof( "RDA" )

	MsAguarde(;
					{ ||    MyCursorWait(),;
							RdaGd2RdaLbx(	oGdRdaGet()		,;
											@aPartSelect	,;
											aCposLbx		,;
											nLbxFilial		,;
											nLbxCodigo		,;
											nLbxNome		 ;
				 	 					),;
							MyCursorArrow();
					};
				)

	IF ( lSelect := APDA270SelPartic(	nOpc					,;
										OemToAnsi( STR0025 )	,;	//'Selecionar Participantes ( Avaliadores )'
										@aPartSelect			,;
										aCposLbx				,;
										cKeyFilter				,;
										aKeyFields				,;
										"RD0" 			 		,;
										@aQuery					 ;
									);
		)
		MsAguarde(;
						{ ||    MyCursorWait(),;
								RdaLbx2RdaGd(	oGdRdaGet()		,;
												@aPartSelect	,;
												aCposLbx		,;
												nLbxCodigo		,;
												nLbxNome	 	 ;
					 	 					),;
								MyCursorArrow();
						};
					)
		Eval( { || oGdRdaGet() } ):Refresh()
	EndIF

End Sequence

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �ApdDorFilterBuild�Autor�Marinaldo de Jesus� Data �26/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cria Filtro para a Selecao dos Avaliadores de Acordo com   a�
�          �Visao do Avalidado										    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �BtnRdaSelect() em APDA270()								    �
�������������������������������������������������������������������������/*/
Static Function ApdDorFilterBuild( oGdRda )

Local aRdaColsAll	:= RdaColsGet()
Local aArea			:= GetArea()
Local aAreaRDE		:= RDE->( GetArea() )
Local cRdeFil		:= xFilial( "RDE" )
Local cKeyFilter	:= ""
Local cKeySeek		:= ""
Local cCodVis		:= ""
Local cIteVis		:= ""
Local cRd9CodAdo	:= ""
Local cRd9CodAva	:= ""
Local cRdhCodNet	:= ""
Local cRdhNivel		:= ""
Local cSpcCodDor	:= ""
Local nNiveis		:= 0
Local nRdaCodAva	:= GdFieldPos( "RDA_CODAVA" , oGdRda:aHeader )
Local nRdaCodAdo	:= GdFieldPos( "RDA_CODADO" , oGdRda:aHeader )
Local nRdaCodNet	:= GdFieldPos( "RDA_CODNET" , oGdRda:aHeader )
Local nRdaNivel		:= GdFieldPos( "RDA_NIVEL"  , oGdRda:aHeader )
Local nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" , oGdRda:aHeader )
Local nRdaDelete	:= GdFieldPos( "GDDELETED"  , oGdRda:aHeader )
Local nRdhNivel		:= 0
Local nRdhNumNiv	:= 0
Local nRd9CodAdo	:= 0
Local nTamCodDor	:= GetSx3Cache( "RDA_CODDOR" , "X3_TAMANHO" )
Local nItem			:= 0
Local nItens		:= 0
Local oGdRd9		:= oGdRd9Get( APDA270_FOLDER_AVALIADORES )
Local oGdRdh		:= oGdRdhGet( APDA270_FOLDER_AVALIADORES )

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
MyCursorWait()

	nRdhNivel	:= GdFieldPos( "RDH_NIVEL"	, oGdRdh:aHeader	)
	nRdhNumNiv	:= GdFieldPos( "RDH_NUMNIV"	, oGdRdh:aHeader	)
	nRd9CodAdo	:= GdFieldPos( "RD9_CODADO"	, oGdRd9:aHeader	)

	cRdhCodNet	:= GdFieldGet( "RDH_CODNET" , oGdRdh:nAt	, .F. , oGdRdh:aHeader	, oGdRdh:aCols	)
	cRd9CodAdo	:= GdFieldGet( "RD9_CODADO" , oGdRd9:nAt	, .F. , oGdRd9:aHeader	, oGdRd9:aCols	)
	cRd9CodAva	:= GdFieldGet( "RD9_CODAVA" , oGdRd9:nAt	, .F. , oGdRd9:aHeader	, oGdRd9:aCols	)

	cCodVis		:= GetMemVar( "RD6_CODVIS" )
	cIteVis		:= a270GetRdeIteV( cRd9CodAdo , cCodVis , "1" , cRdeFil )
	IF !Empty( cIteVis )
		nNiveis 	:= ( oGdRdh:aCols[ oGdRdh:nAt , nRdhNumNiv ] )
		cRdhNivel	:= oGdRdh:aCols[ oGdRdh:nAt , nRdhNivel ]
		IF ( cRdhNivel == "1" )		//Mesmo Nivel
			cKeyFilter := ApdaDorNivel( cIteVis , cRdeFil , cCodVis , "1" , nNiveis , , , , "RDE" )
		ElseIF ( cRdhNivel == "2" )	//Superior
			cKeyFilter := ApdaDorNivel( cIteVis , cRdeFil , cCodVis , "2" , nNiveis , , , , "RDE" )
		ElseIF ( cRdhNivel == "3" )	//Inferior
			cKeyFilter := ApdaDorNivel( cIteVis , cRdeFil , cCodVis , "3" , nNiveis , , , , "RDE" )
		EndIF
	EndIF

	IF !Empty( cKeyFilter )
		IF !( cKeyFilter == "__NoExistItem__" )
			nItens		:= Len( cKeyFilter )
			cSpcCodDor	:= Replicate( "@" , nTamCodDor )
			For nItem := 1 To nItens Step ( nTamCodDor + 1 )
				cKeySeek := SubStr( cKeyFilter , nItem , nTamCodDor )
				IF (;
						( aScan( aRdaColsAll , { |x|	x[nRdaCodAva] == cRd9CodAva .and. ;
													  	x[nRdaCodAdo] == cRd9CodAdo .and. ;
											  			x[nRdaCodNet] != cRdHCodNet .and. ;
														x[nRdaNivel ] == cRdHNivel  .and. ;
											  			x[nRdaCodDor] == cKeySeek	.and. ;
											  			!x[nRdaDelete]					  ;
										  		};
					     		);
						) > 0;
					)
					/*/
					��������������������������������������������������������������Ŀ
					� Exclui do Filtro os Participantes Selecionados em outra Rede �
					����������������������������������������������������������������/*/
					cKeyFilter := StrTran( cKeyFilter , cKeySeek , cSpcCodDor )
				EndIF
			Next nItem
		EndIF
		IF !Empty( cKeyFilter )
			cKeyFilter :=  "RD0_CODIGO $ '" + cKeyFilter + "'"
		EndIF
	EndIF

	RestArea( aAreaRDE )
	RestArea( aArea )

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
MyCursorArrow()

Return( cKeyFilter )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaGd2RdaLbx	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Carrega Participantes Avaliadores da GetDados para o ListBox�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �BtnRdaSelect() em APDA270()									�
�������������������������������������������������������������������������/*/
Static Function RdaGd2RdaLbx(	oGdRda			,;	//GetDados dos Avaliadores
								aPartSelect		,;	//Array com os Participantes Selecionados
								aCposLbx		,;	//Campos da ListBox para Selecao de Participantes
								nLbxFilial		,;	//Posicao Referente a Filial do Participante no ListBox
								nLbxCodigo		,;	//Posicao Referente ao Codigo do Participante no ListBox
								nLbxNome		 ;	//Posicao Referente ao Nome do Participante no ListBox
							  )

Local aItens	:= {}
Local bAeval	:= { |x,y| IF( !x[nRdaDelete] .and. !Empty(x[nRdaCodDor] ) , aAdd( aItens , y ) , NIL ) }
Local cRd0Fil	:= xFilial("RD0")

Local bAscan
Local nItem
Local nItens
Local nRdaCodDor
Local nRdaNome
Local nRdaDelete

nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" , oGdRda:aHeader )
nRdaDelete	:= GdFieldPos( "GDDELETED"	, oGdRda:aHeader )
aEval( oGdRda:aCols , bAeval )
IF ( ( nItens := Len( aItens ) ) > 0 )
	nRdaNome	:= GdFieldPos( "RDA_NOME"	, oGdRda:aHeader )
	bAscan := { |x| ( x[nLbxFilial] == cRd0Fil );
			  		.and.;
			  		( x[nLbxCodigo] == oGdRda:aCols[ aItens[ nItem ] , nRdaCodDor ] );
			  }
	aPartSelect	:= Array( nItens , ( Len( aCposLbx ) + 1 ) )
	For nItem := 1 To nItens
		IF ( aScan( aPartSelect , bAscan ) == 0 )
			aPartSelect[ nItem , 01			]	:= .F.
			aPartSelect[ nItem , nLbxFilial	]	:= cRd0Fil
			aPartSelect[ nItem , nLbxCodigo	]	:= oGdRda:aCols[ aItens[ nItem ] , nRdaCodDor	]
			aPartSelect[ nItem , nLbxNome	]	:= oGdRda:aCols[ aItens[ nItem ] , nRdaNome		]
		EndIF
	Next nItem
EndIF

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaLbx2RdaGd	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Carrega Participantes Avaliadores da ListBox para a GetDados�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �BtnRdaSelect() em APDA270()									�
�������������������������������������������������������������������������/*/
Static Function RdaLbx2RdaGd(	oGdRda			,;	//GetDados dos Avaliadores
								aPartSelect		,;	//Array com os Participantes Selecionados
								aCposLbx		,;	//Campos para a ListBox
								nLbxCodigo		,;	//Posicao Referente ao Codigo do Participante no ListBox
								nLbxNome	 	 ;	//Posicao Referente ao Nome do Participante no ListBox
							  )

Local aRdpCols 		:= RdpColsGet()
Local cRd6Codigo	:= GetMemVar( "RD6_CODIGO" )
Local cRd6CodPro	:= GetMemVar( "RD6_CODPRO" )
Local cRd6CodTip	:= GetMemVar( "RD6_CODTIP" )
Local cRdhCodNet	:= GetMemVar( "RDH_CODNET" )
Local cRdhNivel		:= GetMemVar( "RDH_NIVEL" )
Local oGdRd9		:= oGdRd9Get( APDA270_FOLDER_AVALIADORES )
Local oGdRdp 		:= oGdRdpGet()

Local aRdaSvCols
Local bRd9Sort

Local cRd9CodPro

Local dRdpDatIni
Local dRdpDatFim

Local nRdaCodAva
Local nRdaCodAdo
Local nRdaCodNet
Local nRdaNivel
Local nRdaCodDor
Local nRdaNome
Local nRdaCodPro
Local nRdaDtiAva
Local nRdaDtfAva
Local nRdaCodTip
Local nRdaDelete

Local lRdaModify
Local nLoop
Local nLoops
Local aAuxRda := {}

dRdpDatIni	:= GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader, oGdRdp:aCols )
dRdpDatFim	:= GdFieldGet( "RDP_DATFIM" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader, oGdRdp:aCols )//GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader, oGdRdp:aCols )

cRd9CodPro	:= GdFieldGet( "RD9_CODPRO" , oGdRd9:oBrowse:nAt , .F. , oGdRd9:aHeader, oGdRd9:aCols )

nRd9CodAdo	:= GdFieldPos( "RD9_CODADO" , oGdRd9:aHeader )

nRdaCodAva	:= GdFieldPos( "RDA_CODAVA" , oGdRda:aHeader )
nRdaCodAdo	:= GdFieldPos( "RDA_CODADO" , oGdRda:aHeader )
nRdaCodNet	:= GdFieldPos( "RDA_CODNET" , oGdRda:aHeader )
nRdaNivel	:= GdFieldPos( "RDA_NIVEL" 	, oGdRda:aHeader )
nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" , oGdRda:aHeader )
nRdaNome	:= GdFieldPos( "RDA_NOME"	, oGdRda:aHeader )
nRdaCodPro	:= GdFieldPos( "RDA_CODPRO" , oGdRda:aHeader )
nRdaDtiAva	:= GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader )
nRdaDtfAva	:= GdFieldPos( "RDA_DTFAVA" , oGdRda:aHeader )
nRdaCodTip	:= GdFieldPos( "RDA_CODTIP" , oGdRda:aHeader )
nRdaDelete	:= GdFieldPos( "GDDELETED"  , oGdRda:aHeader )

IF ( ( Len( oGdRda:aCols ) == 1 ) .and. Empty( oGdRda:aCols[ 1 , nRdaCodDor ] ) )
	oGdRda:aCols[ 1 , nRdaDelete ] := .T.
EndIF

Private aHeader := oGdRda:aHeader
Private aCols
Private n

aRdaSvCols	:= aClone( oGdRda:aCols )
aAuxRda := aClone( oGdRda:aCols )
nLoops := Len( aPartSelect )
For nLoop := 1 To nLoops
	aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
	oGdRda:aCols := aClone( aAuxRda )
	aCols[ 1 , nRdaCodAva ] := cRd6Codigo
	aCols[ 1 , nRdaCodAdo ] := oGdRd9:aCols[ oGdRd9:nAt , nRd9CodAdo ]
	aCols[ 1 , nRdaCodTip ] := cRd6CodTip
	aCols[ 1 , nRdaCodNet ] := cRdhCodNet
	aCols[ 1 , nRdaNivel  ] := cRdhNivel
	aCols[ 1 , nRdaCodDor ] := aPartSelect[ nLoop , nLbxCodigo	]
	aCols[ 1 , nRdaNome   ] := aPartSelect[ nLoop , nLbxNome	]
	aCols[ 1 , nRdaDtiAva ] := dRdpDatIni
	aCols[ 1 , nRdaDtfAva ] := dRdpDatFim
	If !Empty(cRd6CodPro)
		aCols[ 1 , nRdaCodPro ] := cRd6CodPro
	EndIf
	aAdd( oGdRda:aCols , aClone( aCols[ 1 ] ) )
	aCols	:= oGdRda:aCols
	n		:= Len( oGdRda:aCols )
	IF !( a270GdLinOk( NIL , .F. , 1 ) )
		aDel( oGdRda:aCols , n )
		aSize( oGdRda:aCols , --n )
	EndIF
	aAuxRda := aClone( oGdRda:aCols )
Next nLoop

lRdaModify := !( ArrayCompare( aRdaSvCols , oGdRda:aCols ) )
IF ( lRdaModify )
	bRdaSort := { |x,y|	( x[ nRdaCodAdo ] + Dtos( x[ nRdaDtiAva ] ) + x[ nRdaCodDor ] + IF( !x[ nRdaDelete ] , "0" , "1" ) );
						<;
						( y[ nRdaCodAdo ] + Dtos( y[ nRdaDtiAva ] ) + y[ nRdaCodDor ] + IF( !y[ nRdaDelete ] , "0" , "1" ) );
				}
	aSort( oGdRda:aCols , NIL , NIL , bRdaSort )
	GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 3 , 1 ) , oGdRdp:oBrowse:nAt , oGdRdp:aHeader , aRdpCols , .F. )
	GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 3 , 1 ) , oGdRdp:oBrowse:nAt , oGdRdp:aHeader , oGdRdp:aCols , .F. )
EndIF
oGdRda:Goto( 1 )

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Aloca	 �Autor�Marinaldo de Jesus� Data �06/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Monta Tree para Realocacao de Participantes            	    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270()													�
�������������������������������������������������������������������������/*/
Static Function APDA270Aloca( nOpc )

Local aArea		 	:= GetArea()
Local aAreaRDK	 	:= RDK->( GetArea() )
Local aSvKeys	 	:= GetKeys()
Local lFindVisao	:= .F.

Begin Sequence

	RDK->( dbSetOrder( RetOrdem( "RDK" , "RDK_FILIAL+RDK_CODIGO" ) ) )
	IF ( lFindVisao := RDK->( MsSeek( xFilial( "RDK" ) + GetMemVar( "RD6_CODVIS" ) , .F. ) ) )
		ApdLbxMArray()
			Apda070( IF( nOpc <= 2 , nOpc , IF( nOpc >= 5 , 2 , 3 ) ) )
		ApdLbxMArray()
	EndIF

End Sequence

RestKeys( aSvKeys , .T. )
RestArea( aAreaRDK )
RestArea( aArea    )

Return( lFindVisao )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270GdSeek�Autor�Marinaldo de Jesus    � Data �10/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Efetuar Pesquisa na GetDados                               	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270                                                		�
�������������������������������������������������������������������������/*/
Static Function APDA270GdSeek( lGdSeek , nActFolder , aPages )

Local aSvKeys 		:= GetKeys()
Local nObj			:= 0

Local cMsgInfo
Local cTitle

DEFAULT lGdSeek		:= .F.

Begin Sequence

	IF !( lGdSeek )
		cMsgInfo := STR0010	//"Op��o dispon�vel apenas para pesquisa na(s) Pasta(s):"
		cMsgInfo += CRLF
		cMsgInfo += aPages[ APDA270_FOLDER_AGENDA ]
		cMsgInfo += CRLF
		cMsgInfo += aPages[ APDA270_FOLDER_AVALIADOS ]
		cMsgInfo += CRLF
		cMsgInfo += aPages[ APDA270_FOLDER_AVALIADORES ]
		MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
		Break
	EndIF

	nObj := GetObjGdSeek( nActFolder , @cTitle )

	IF ( nObj > 0 )
		GdSeek( aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , nObj , APDA270_OBJ ] , OemToAnsi( cTitle ) )
	EndIF

End Sequence

RestKeys( aSvKeys , .T. )

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �GetObjGdSeek	�Autor�Marinaldo de Jesus � Data �10/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna as Opcoes para Pesquisa na GetDados                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Retorno   �Numero do Objeto para Pesquisa na GetDados                  �
�����������������������������������������������������������������������Ĵ
�Uso	   �APDA270GdSeek() em APDA270()							    �
�������������������������������������������������������������������������/*/
Static Function GetObjGdSeek( nActFolder , cTitle )

Local aSvKeys		:= GetKeys()
Local aItens		:= {}
Local bSet15		:= { || lOpcOk	:= .T.	, RestKeys( aSvKeys , .T. ) , oDlg:End() }
Local bSet24		:= { || nOpcRel	:= 0	, RestKeys( aSvKeys , .T. ) , oDlg:End() }
Local lOpcOk		:= .F.
Local nOpjGdSeek	:= 1
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local oRadio
Local oDlg
Local oGroup
Local oFont

Begin Sequence

	DEFAULT cTitle := STR0002 + " "	//Pesquisar
	IF ( nActFolder == APDA270_FOLDER_AVALIADOS )
		nOpjGdSeek	:= 2
		cTitle		+= aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , nOpjGdSeek , APDA270_OBJ ]:oBrowse:cToolTip
		Break
	ElseIF ( nActFolder == APDA270_FOLDER_AGENDA )
		nOpjGdSeek	:= 3
		cTitle		+= aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , nOpjGdSeek , APDA270_OBJ ]:oBrowse:cToolTip
		Break
	ElseIf ( nActFolder == APDA270_FOLDER_AVALIADORES )
		aAdd( aItens , aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , 1 , APDA270_OBJ ]:oBrowse:cToolTip )
		aAdd( aItens , aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , 2 , APDA270_OBJ ]:oBrowse:cToolTip )
		aAdd( aItens , aFolders[ nActFolder , APDA270_FOLDER_OBJECTS , 4 , APDA270_OBJ ]:oBrowse:cToolTip )
	EndIF

	aAdvSize	 := MsAdvSize( , .T. , 100 )
	aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }

	/*/
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������/*/
	aAdd( aObjCoords , { 000 , 045 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM  aAdvSize[7],0 TO aAdvSize[6]*0.65,aAdvSize[5] TITLE OemToAnsi( STR0002 ) PIXEL	//"Pesquisar"

		@ aObjSize[1,1],aObjSize[1,2] 	GROUP oGroup TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi(STR0046) OF oDlg PIXEL	//"Selecione o Objeto da Pesquisa"
		oGroup:oFont:=oFont

 		oRadio 			:= TRadMenu():New( aObjSize[1,1]+10,aObjSize[1,2]+10, aItens , NIL , oDlg , NIL , NIL , NIL , NIL , NIL , NIL , NIL , 115 , 010 , NIL , NIL , NIL , .T. )
		oRadio:bSetGet	:= { |nItem| IF( nItem <> NIL , nOpjGdSeek := nItem , nOpjGdSeek ) }

		//oRadio:aItems := aItens

		oDlg:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
	RestKeys( aSvKeys , .T. )

	IF !( lOpcOk )
		nOpjGdSeek := 0
	ElseIF ( nActFolder == APDA270_FOLDER_AVALIADORES )
		IF ( nOpjGdSeek == 3 )
			cTitle		+= aItens[ nOpjGdSeek ]
			nOpjGdSeek	:= 4
		Else
			cTitle		+= aItens[ nOpjGdSeek ]
		EndIF
	Else
		cTitle += aItens[ nOpjGdSeek ]
	EndIF

End Sequence

Return( nOpjGdSeek )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270AvaBld�Autor�Marinaldo de Jesus    � Data �10/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Montar ou Excluir as Avaliacaoes de Determinado Periodo		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270                                                		�
�������������������������������������������������������������������������/*/
Static Function APDA270AvaBld( nActFolder , aPages )

Local aSvKeys 			:= GetKeys()
Local lAPDA270AvaBld	:= .T.

Local bApda80BldAuto
Local cMsgInfo
Local cFolders
Local cRdpStatus
Local dRdpDatIni
Local dRdpDatGer
Local oGdRdp

Begin Sequence

	cFolders := AllTrim( Str( APDA270_FOLDER_AGENDA ) )

	IF !( AllTrim( Str( nActFolder ) ) $ cFolders )
		cMsgInfo := STR0115	//"Op��o dispon�vel apenas na(s) Pasta(s):"
		cMsgInfo += CRLF
		cMsgInfo += CRLF
		cMsgInfo += aPages[ APDA270_FOLDER_AGENDA ]
		MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
		lAPDA270AvaBld := .F.
		Break
	EndIF

	IF !( lAPDA270AvaBld := ( GetMemVar( "RD6_STATUS" ) == "1" ) ) //Aberto
		cMsgInfo := STR0128	//"Esta Avalia��o j� foi encerrada."
		MsgInfo( OemToAnsi( cMsgInfo ) , STR0022 )	//"Aviso de Inconsistencia!"
		Break
	EndIF

	oGdRdp	:= oGdRdpGet()

	cRdpStatus	:= GdFieldGet( "RDP_STATUS" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )
	IF ( cRdpStatus == NIL )
		cMsgInfo := STR0111	//"N�o Foi poss�vel verificar o Estatus para o Per�odo."
		MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
		lAPDA270AvaBld := .F.
		Break
	EndIF

	IF ( cRdpStatus == SubStr( RdpStatusBox( .T. ) , 6 , 1 ) )
		cMsgInfo := STR0128	//"Esta Avalia��o j� foi encerrada."
		MsgInfo( OemToAnsi( cMsgInfo ) , STR0022 )	//"Aviso de Inconsistencia!"
		lAPDA270AvaBld := .F.
		Break
	EndIF

	IF !( lAPDA270AvaBld := oGdRdp:LinhaOk() )
		Break
	EndIF

	IF !( cRdpStatus $ SubStr( RdpStatusBox( .T. ) , 1 , 3 ) )
		cMsgInfo := STR0112	//"N�o podem haver modifica��es para as Avalia��es neste per�odo."
		MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
		lAPDA270AvaBld := .F.
		Break
	EndIF

	dRdpDatIni	:= GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )
	dRdpDatFim	:= GdFieldGet( "RDP_DATFIM" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )
	dRdpDatGer	:= GdFieldGet( "RDP_DATGER" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )

	bApda80BldAuto	:= { || Apda80BldAuto( dRdpDatIni , dRdpDatFim ) }
	Proc2BarGauge( bApda80BldAuto , NIL , NIL , NIL , .T. , .T. , .F. , .T. )

End Sequence

RestKeys( aSvKeys , .T. )

Return( lAPDA270AvaBld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �BldCaled	 �Autor�Marinaldo de Jesus    � Data �10/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Montar ou Excluir as Avaliacaoes de Determinado Periodo		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270                                                		�
�������������������������������������������������������������������������/*/
Static Function BldCalend( nActFolder , aFolders , aPages , lAgend )

Local aSvKeys 		:= GetKeys()

Local cMsgInfo

DEFAULT lAgend	:= .T.

Begin Sequence

	IF !Empty( nActFolder )

		IF !( nActFolder == APDA270_FOLDER_AGENDA )
			cMsgInfo := STR0115	//"Op��o dispon�vel apenas na(s) Pasta(s):"
			cMsgInfo += CRLF
			cMsgInfo += CRLF
			cMsgInfo += aPages[ APDA270_FOLDER_AGENDA ]
			MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
			Break
		EndIF

	EndIF

	RdpBldCalend( @aFolders , .T. , .T. , lAgend )

End Sequence

RestKeys( aSvKeys , .T. )

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APDA270Sch		�Autor�Marinaldo de Jesus � Data �30/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Schedule para a Geracao de Avaliacoes Automaticas           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Scheduler	                                                �
�������������������������������������������������������������������������/*/
Function APDA270Sch( aParam )

	Local cRd6Emp
	Local cRd6Filial
	Local cRd6CodAva
	Local uDataIni
	Local uDataFim

	Begin Sequence

		If Empty( aParam )
			Break
		EndIf

		If ( Len( aParam ) >= 1 )
			cRd6CodAva := aParam[1]
		EndIf

		If ( Len( aParam ) >= 2 )
			uDataIni := aParam[2]
		EndIf

		If ( Len( aParam ) >= 3 )
			uDataFim := aParam[3]
		EndIf

		If ( Len( aParam ) >= 4 )
			cRd6Emp := aParam[4]
		EndIf

		If ( Len( aParam ) >= 5 )
			cRd6Filial := aParam[5]
		EndIf

	End Sequence

	APDA270Job( cRd6Emp, cRd6Filial, cRd6CodAva, uDataIni, uDataFim )

	ApdChkEnv({cRd6Emp, cRd6Filial})

Return(.T.)

/*/{Protheus.doc} APDA270Job
Chamada do Apada080 atrav�s de JOB para a gera��o das avalia��es
@author  Marinaldo de Jesus
@since   29/07/2004
/*/
Static Function APDA270Job( cRd6Emp, cRd6Filial, cRd6CodAva, uDataIni, uDataFim )

	Local cLstEmp		:= "__cLstEmp__"
	Local lRd6Compart	:= .F.
	Local aModuloReSet
	Local cRd6KeySeek
	Local cRd6IndexKey
	Local dDataIni
	Local dDataFim
	Local lEmp
	Local lRd6Found
	Local lRd6Filial
	Local lRd6CodAva
	Local lChkFilAva
	Local lChkIniFim
	Local lSetCentury
	Local lStartJob
	Local nRd6Order
	Local nRd6KeyLen
	Local nRd6NextRecno
	Local nRd6Recno

	// Carrega os Sets DEFAULTS
	SetsDefault()
	lSetCentury	:= __SetCentury("on")

	RpcSetType(3)
	RPCSetEnv( cRd6Emp, cRd6Filial, , , , "APDA270Job")

	lEmp		:= !Empty( cRd6Emp )
	lRd6Filial	:= !Empty( cRd6Filial )
	lRd6CodAva	:= !Empty( cRd6CodAva )
	lChkFilAva	:= (( lRd6Filial ) .Or. ( lRd6CodAva ))

	If ( ValType( uDataIni ) == "C" )
		If ( "CTOD" $ Upper( uDataIni ))
			CheckExecForm( @uDataIni, .F. )
			dDataIni := uDataIni
		Else
			CheckExecForm( { || dDataIni := Ctod( uDataIni, "DDMMYYYY" )}, .F. )
		EndIf
	Else
		dDataIni := uDataIni
	EndIF

	IF ( ValType( uDataFim ) == "C" )
		IF ( "CTOD" $ Upper( uDataFim ) )
			CheckExecForm( @uDataFim, .F. )
			dDataFim := uDataFim
		Else
			CheckExecForm( { || dDataFim := Ctod( uDataFim, "DDMMYYYY" )}, .F. )
		EndIF
	Else
		dDataFim := uDataFim
	EndIF

	// Verifica se Passou Data Inicial e Data Final
	lChkIniFim := (( ValType( "dDataIni" ) == "D" ) .And. ( ValType( "dDataFim" ) == "D" ))

	// Redefine nModulo de forma a Garantir que o Modulo seja o SIGAAPD
	aModuloReSet := SetModulo( "SIGAAPD", "APD" )

	// Garanto que n�o vai consumir licen�as
	SetTopType( "A" )

	Begin Sequence

		// Abre as Tabelas do Ponto
		PonRelationFile()

		// Abre as Tabelas do GPE
		GpeRelationFile()

		// Abre as Tabelas do APD
		IF !( lStartJob := ApdRelationFile())
			Break
		EndIF

		// Obtem a Filial do RD6
		cRd6Filial	:= xFilial( "RD6", cRd6Filial )
		lRd6Compart	:= Empty( cRd6Filial )
		cLstEmp		:= cEmpAnt

		// Monta a chave para pesquisa
		If ( lRd6CodAva )
			cRd6KeySeek := ( cRd6Filial + cRd6CodAva )
		Else
			cRd6KeySeek := cRd6Filial
		EndIf

		// Seleciona a Ordem do Rd6
		nRd6Order := RD6->( RetOrdem( "RD6", "RD6_FILIAL+RD6_CODIGO" ))
		RD6->( dbSetOrder( nRd6Order ) )
		cRd6IndexKey := RD6->( IndexKey())

		// Procura pela Avaliacao
		lRd6Found := RD6->( dbSeek( cRd6KeySeek, .F. ))
		IF ( !( lRd6Found ) .and. ( lChkFilAva ))
			lStartJob := lRd6Found
			Break
		EndIF
		nRd6KeyLen := Len( cRd6KeySeek )

		// Executa a Gera��o
		While RD6->(!Eof() .And. If( lChkFilAva, SubStr( &( cRd6IndexKey ), 1, nRd6KeyLen ) == cRd6KeySeek, .T. ))

			If !( GetNextRecno( "RD6", @nRd6NextRecno, @nRd6Recno, nRd6Order ))
				Break
			EndIF

			// Apenas as Avalia��es Ativas
			If ( RD6->RD6_STATUS == "1" )

				// Se n�o Passou a Data Considera o Per�odo do RD6
				IF !( lChkIniFim )
					dDataIni := RD6->RD6_DTINI
					dDataFim := RD6->RD6_DTFIM
				EndIF

				// Gera as Avalia��es
				APDA270( "RD6", RD6->( Recno()), 4, .F., .T., dDataIni, dDataFim )

			EndIf

			IF !( GotoNextRecno( "RD6", nRd6NextRecno, nRd6Order ))
				Break
			EndIF

		End While

	End Sequence

	// Inicializo o Processo de Envio das Avalia��es
	If ( lStartJob )
		StartJob( "ApdSndAv", GetEnvServer(), .F., { cEmpAnt, cFilAnt, cRd6CodAva })
	EndIf

	ConOut( CRLF )

	// Restaura Informacoes de Entrada
	ReSetModulo( aModuloReSet )
	RpcClearEnv() // Reseta o ambiente

	If !( lSetCentury )
		__SetCentury("off")
	EndIf

Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apda80BldAuto	�Autor�Marinaldo de Jesus � Data �07/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Montagem Automatica das Avaliacoes                          �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA270  	                                                �
�������������������������������������������������������������������������/*/
Static Function Apda80BldAuto( dPerIni , dPerFim , lShowProc, nOpc)

	Local cSvEmpAnt			:= cEmpAnt
	Local cSvFilAnt			:= cFilAnt
	Local lApda80BldAuto	:= .F.
	Local aIndex
	Local aInfoCriter
	Local aRelation
	Local aScopeCount
	Local bFilter
	Local bMaxCodDor
	Local bRelation
	Local bInitPad
	Local cInitPad
	Local cRelation
	Local cMsgInfo
	Local cTimeIni
	Local cFieldFil
	Local dDataIni
	Local dDataFim
	Local nRelation
	Local nRecno
	Local nNextRecno
	Local nMaxCodDor
	Local nProcRegua
	Local nContPrc1
	Local nFieldFil
	Local uInitPad
	Local cRd6Codigo
	Local cRd6CodVis
	Local cRd6Criter
	Local cRd6Status
	Local cRd6Montag
	Local cRd6CodTip
	Local dRd6DtIni
	Local dRd6DtFim
	Local lRd6AutoAv
	Local aRd9Header
	Local aRd9Cols
	Local aRd9SvCols
	Local bSortRd9
	Local loGdRd9
	Local lRd9Modify
	Local lRd9GhostCol
	Local lRd9ColBmp
	Local nRd9Codava
	Local nRd9CodAdo
	Local nRd9CodPro
	Local nRd9Nome
	Local nRd9DtiAva
	Local nRd9DtfAva
	Local nRd9Delete
	Local nRd9GhostCol
	Local nRd9ColBmp
	Local oGdRd9
	Local aRdhHeader
	Local aRdhCols
	Local lRdhFeedBk
	Local lRdhAutoAv
	Local nRdhLoop
	Local nRdhLoops
	Local nRdhCodNet
	Local nRdhNivel
	Local nRdhNumPar
	Local nRdhNumNiv
	Local nRdhAutoAv
	Local nRdhFeedBk
	Local nRdhMaxPar
	Local aRdaHeader
	Local aRdaCols
	Local aRdaSvCols
	Local lRdaModify
	Local lRdaGhostCol
	Local lRdaColBmp
	Local nRdaCodava
	Local nRdaCodAdo
	Local nRdaCodDor
	Local nRdaCodPro
	Local nRdaNome
	Local nRdaNomeTmSx3
	Local nRdaDtiAva
	Local nRdaDtfAva
	Local nRdaCodTip
	Local nRdaCodNet
	Local nRdaNivel
	Local nRdaTipoAv
	Local nRdaDelete
	Local nRdaGhostCol
	Local nRdaColBmp
	Local bSortRda
	Local cRd0Fil
	Local cRd0Codigo
	Local cRd0Nome
	Local cRd0CodMen
	Local nRd0Order
	Local aRdpHeader
	Local aRdpCols
	Local cRdpStSub
	Local cRdpStGer
	Local nRdpLoop
	Local nRdpLoops
	Local nRdpDatGer
	Local nRdpDatIni
	Local nRdpDatFim
	Local nRdpStatus
	Local nRdpDelete
	Local aRdeHeader
	Local aRdeCols
	Local aRdeVisual
	Local aRdeVirtual
	Local aRdeQuery
	Local aRdeKeys
	Local aRdeCodRd0
	Local aRdeCompAux	:= {}
	Local bRdeGet
	Local cRdeFil
	Local cRdeKeySeek
	Local cRdeStatus
	Local lRdeLocks
	Local nRdeOrder
	Local nRdeLocks
	Local nRdeLoop
	Local nRdeLoops
	Local nLoopRdeRd0
	Local nLoopsRdeRd0
	Local nRdeIteVis
	Local aRdtHeader
	Local aRdtCols
	Local cRdtAlias
	Local cRdtCriter
	Local cFilRdtAlias
	Local nRdtLoop
	Local nRdtLoops
	Local nRdtAliasOrd
	Local aRdsHeader
	Local aRdsCols
	Local cRdsFil
	Local cNivAux	:= ""
	Local nRdsOrder
	Local aAreas	:={} 	// Array das areas de relacionamento no SX9 (RD0 X...)
	Local nPos		:=0 	// Posicao da tabela de pesquisa no array aAreas
	Local nRd0SvOrd	:= 0   // variavel de backup da ordem da area RDO
	Local lFound	:=.T.	// Flag de existencia do registro na rd0.
	Local aRD0Crit	:={}	// Array para conter o resultados do crit�rio de todas as tabelas
	Local nRD0CLoop
	Local nPosAux	:= 0
	Local nMedTAux	:= 0
	
	Private cArqPart	:= ""
	Private oTabRDE	
	Private cArqTMP1	:= ""
	Private cKeyRdt		:= ""	// Chave de pesquisa no relacionamento
	Private aPosAux		:= {}
	Private aTotPar		:= {}

	Begin Sequence

		/*/
		��������������������������������������������������������������Ŀ
		�So Executa se o Modo de Acesso dos Arquivos do Modulo APD esti�
		�verem OK													   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := ApdRelationFile( lShowProc ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Verifica se Esta Executando a partir do APDA270			   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := APDA270Fldrs() )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Verifica o "Status" da Avaliacao                			   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := ( ( cRd6Status := GetMemVar( "RD6_STATUS" ) ) == "1" ) ) //Aberto
			lShowProc	:= .T.
			cMsgInfo := STR0128	//"Esta Avalia��o j� foi encerrada."
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Verifica o Tipo de Montagem                     			   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := ( ( cRd6Montag := GetMemVar( "RD6_MONTAG" ) ) <> "1" ) ) //Manual
			lShowProc	:= .T.
			cMsgInfo := STR0127	//"Op��o Dispon�vel apenas para Montagem Semi-Autom�tica ou Autom�tica."
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Inicializacao das variaveis                     			   �
		����������������������������������������������������������������/*/
		DEFAULT lShowProc	:= .T.

		Private aHeader
		Private aCols
		Private n

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem o Periodo para a Geracao Automatica       			   �
		����������������������������������������������������������������/*/
		dPerIni := Max( dPerIni , ( dRd6DtIni := GetMemVar( "RD6_DTINI" ) ) )
		dPerFim := Min( dPerFim , ( dRd6DtFim := GetMemVar( "RD6_DTFIM" ) ) )

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem o Codigo do Tipo de Avaliacao             			   �
		����������������������������������������������������������������/*/
		cRd6CodTip := GetMemVar( "RD6_CODTIP" )

		/*/
		��������������������������������������������������������������Ŀ
		�Carrega informacoes do RDP ( Agenda )           			   �
		����������������������������������������������������������������/*/
		aRdpHeader	:= RdpHeaderGet()
		aRdpCols	:= RdpColsGet()

		IF !( lApda80BldAuto := !Empty( nRdpDatGer := GdFieldPos( "RDP_DATGER" , aRdpHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdpDatIni := GdFieldPos( "RDP_DATINI" , aRdpHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdpDatFim := GdFieldPos( "RDP_DATFIM" , aRdpHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdpStatus := GdFieldPos( "RDP_STATUS" , aRdpHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdpDelete := GdFieldPos( "GDDELETED" , aRdpHeader ) ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Carrega informacoes do RD9 ( Avaliados )          			   �
		����������������������������������������������������������������/*/
		aRd9Header	:= Rd9HeaderGet()
		aRd9Cols	:= Rd9ColsGet()
		aRd9SvCols	:= aClone( aRd9Cols )

		IF !( lApda80BldAuto := !Empty( nRd9Codava := GdFieldPos( "RD9_CODAVA" , aRd9Header ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRd9CodAdo	:= GdFieldPos( "RD9_CODADO" , aRd9Header ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRd9CodPro	:= GdFieldPos( "RD9_CODPRO" , aRd9Header ) ) )
			Break
		EndIF

		IF ( ( Len( aRd9Cols ) == 1 ) .and. Empty( aRd9Cols[ 1 , nRd9CodAdo ] ) )
			GdFieldPut( "GDDELETED" , .T. , 1 , aRd9Header , aRd9Cols )
		EndIF

		IF !( lApda80BldAuto := !Empty( nRd9Nome	:= GdFieldPos( "RD9_NOME"	, aRd9Header ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRd9DtiAva	:= GdFieldPos( "RD9_DTIAVA" , aRd9Header ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRd9DtfAva	:= GdFieldPos( "RD9_DTFAVA" , aRd9Header ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRd9Delete	:= GdFieldPos( "GDDELETED" , aRd9Header ) ) )
			Break
		EndIF

		IF ( lRd9GhostCol := ( ( nRd9GhostCol := GdFieldPos( "GHOSTCOL" , aRd9Header ) ) > 0 ) )
			lRd9GhostCol := !Empty( aRd9Header[ nRd9GhostCol , 12 ] )
		EndIF

		IF ( lRd9ColBmp := ( ( nRd9ColBmp := GdFieldPos( "COLBMP" , aRd9Header ) ) > 0 ) )
			lRd9ColBmp := !Empty( aRd9Header[ nRd9ColBmp , 12 ] )
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Carrega informacoes do RDH ( Rede ) 	         			   �
		����������������������������������������������������������������/*/
		aRdhHeader	:= RdhHeaderGet()
		aRdhCols	:= RdhColsGet()
		GdRdhRdaInit(	oGdRdhGet( APDA270_FOLDER_AVALIADORES ),;
						.F.,;
						.F.,;
						@aRdhHeader,;
						@aRdhCols,;
						nOpc)

		nRdhLoops	:= Len( aRdhCols )

		IF !( lApda80BldAuto := !Empty( nRdhLoops ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdhCodNet	:= GdFieldPos( "RDH_CODNET" , aRdhHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdhNivel	:= GdFieldPos( "RDH_NIVEL" , aRdhHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdhNumPar	:= GdFieldPos( "RDH_NUMPAR" , aRdhHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdhNumNiv	:= GdFieldPos( "RDH_NUMNIV" , aRdhHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdhAutoAv	:= GdFieldPos( "RDH_AUTOAV" , aRdhHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdhFeedBk	:= GdFieldPos( "RDH_FEEDBK" , aRdhHeader ) ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Carrega informacoes do RDA ( Avaliadores )        			   �
		����������������������������������������������������������������/*/
		aRdaHeader	:= RdaHeaderGet()
		aRdaCols	:= RdaColsGet()
		aRdaSvCols	:= aClone( aRdaCols )

		IF !( lApda80BldAuto := !Empty( nRdaCodava := GdFieldPos( "RDA_CODAVA" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaCodAdo	:= GdFieldPos( "RDA_CODADO" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaCodPro	:= GdFieldPos( "RDA_CODPRO" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaCodDor	:= GdFieldPos( "RDA_CODDOR" , aRdaHeader ) ) )
			Break
		EndIF

		IF ( ( Len( aRdaCols ) == 1 ) .and. Empty( aRdaCols[ 1 , nRdaCodAdo ] ) )
			GdFieldPut( "GDDELETED" , .T. , 1 , aRdaHeader , aRdaCols )
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaNome	:= GdFieldPos( "RDA_NOME"	, aRdaHeader ) ) )
			Break
		EndIF
		nRdaNomeTmSx3 := ( GetSx3Cache("RDA_NOME","X3_TAMANHO" ) )

		IF !( lApda80BldAuto := !Empty( nRdaDtiAva	:= GdFieldPos( "RDA_DTIAVA" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaDtfAva	:= GdFieldPos( "RDA_DTFAVA" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaCodTip	:= GdFieldPos( "RDA_CODTIP" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaCodNet	:= GdFieldPos( "RDA_CODNET" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaNivel	:= GdFieldPos( "RDA_NIVEL" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaTipoAv	:= GdFieldPos( "RDA_TIPOAV" , aRdaHeader ) ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( nRdaDelete	:= GdFieldPos( "GDDELETED" , aRdaHeader ) ) )
			Break
		EndIF

		IF ( lRdaGhostCol := ( ( nRdaGhostCol := GdFieldPos( "GHOSTCOL" , aRdaHeader ) ) > 0 ) )
			lRdaGhostCol := !Empty( aRdaHeader[ nRdaGhostCol , 12 ] )
		EndIF

		IF ( lRdaColBmp := ( ( nRdaColBmp := GdFieldPos( "COLBMP" , aRdaHeader ) ) > 0 ) )
			lRdaColBmp := !Empty( aRdaHeader[ nRdaColBmp , 12 ] )
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem o Criterio para a Geracao Automatica        			   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := !Empty( cRd6Criter	:= GetMemVar( "RD6_CRITER" ) ) )
			cMsgInfo := STR0126	//"N�o foi definido o Crit�rio para a Montagem Autom�tica."
			Break
		EndIF

		nRdsOrder	:= RDS->( RetOrdem( "RDS" , "RDS_FILIAL+RDS_CODIGO" ) )
		IF !( lApda80BldAuto := !Empty( nRdsOrder ) )
			Break
		EndIF

		cRdsFil		:= xFilial( "RDS" )

		RDS->( dbSetOrder( nRdsOrder ) )
		IF !( lApda80BldAuto := RDS->( dbSeek( cRdsFil + cRd6Criter , .F. ) ) )
			Break
		EndIF

		aInfoCriter := Apda160( "RDS" , RDS->( Recno() ) , 4 , .F. , .T. )
		IF !( lApda80BldAuto := !Empty( aInfoCriter ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( aRdsHeader	:= aInfoCriter[ 1 ] ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( aRdsCols	:= aInfoCriter[ 2 ] ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( aRdtHeader	:= aInfoCriter[ 3 ] ) )
			Break
		EndIF

		IF !( lApda80BldAuto := !Empty( aRdtCols	:= aInfoCriter[ 4 ] ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Define a Ordem para obtencao das Visoes           			   �
		����������������������������������������������������������������/*/
		nRdeOrder	:= RDE->( RetOrdem( "RDE" , "RDE_FILIAL+RDE_CODPAR+RDE_CODVIS+RDE_ITEVIS+DTOS(RDE_DATA)" ) )
		IF !( lApda80BldAuto := !Empty( nRdeOrder ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Define Blocos para obtencao das Visoes            			   �
		����������������������������������������������������������������/*/
		cRdeStatus	:= RdeStatusInit()
		bRdeSkip	:= { || ( ( RDE_STATUS <> cRdeStatus ) .or. ( RDE_CODVIS <> cRd6CodVis ) ) }
		bRdeGet	:= { |lLock|		RDE->( dbSetOrder( nRdeOrder ) ),;
									aRdeCols := RDE->(;
													lLock := .T.,;
													GDBuildCols(	@aRdeHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																	NIL       		,;	//02 -> Numero de Campos em Uso
																	@aRdeVisual		,;	//03 -> [@]Array com os Campos Virtuais
																	@aRdeVirtual	,;	//04 -> [@]Array com os Campos Visuais
																	"RDE"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																	NIL          	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																	@aRdeRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																	"RDE"		   	,;	//08 -> Alias do Arquivo Pai
																	cRdeKeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																	NIL				,;	//10 -> Bloco para condicao de Loop While
																	bRdeSkip		,;	//11 -> Bloco para Skip no Loop While
																	.F.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
																	NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																	.F.				,;	//14 -> Opcional, Carregar Todos os Campos
																	.T.				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																	aRdeQuery		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																	.F.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																	.F.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																	.F.				,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
																	NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																	.F.				,;	//21 -> Verifica se Deve checar se o campo eh usado
																	.F.				,;	//22 -> Verifica se Deve checar o nivel do usuario
																	.F.				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																	@aRdeKeys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																	@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																	.T.				,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																	NIL				,;	//27 -> Numero maximo de Locks a ser efetuado
																	NIL				,;	//28 -> Utiliza Numeracao na GhostCol
																	NIL				,;	//29 ->
																	NIL				,;	//30 ->
																	nOpc			;	//31 ->
																);
															);
					}

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem o Codigo da Avaliacao                       			   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := !Empty( cRd6Codigo := GetMemVar( "RD6_CODIGO" ) ) )
			Break
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem o Codigo da Visao                           			   �
		����������������������������������������������������������������/*/
		IF !( lApda80BldAuto := !Empty( cRd6CodVis := GetMemVar( "RD6_CODVIS" ) ) )
			Break
		EndIF

		cRd6CodPro := GetMemVar( "RD6_CODPRO" )

		/*/
		��������������������������������������������������������������Ŀ
		�Verifica se a Avaliacao ira considerar a Auto-Avaliacao	   �
		����������������������������������������������������������������/*/
		lRd6AutoAv := ( GetMemVar( "RD6_AUTOAV" ) == "1" )

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem o Array de Relacionamentos com o RD0        			   �
		����������������������������������������������������������������/*/
		BldArrRdZRel( @aRelation )

		cRdpStSub	:= SubStr( RdpStatusBox( .T. ) , 1 , 2 )
		cRdpStGer	:= SubStr( RdpStatusBox( .T. ) , 3 , 1 )

		/*/
		��������������������������������������������������������������Ŀ
		�Obtem a Ordem para o RD0                          			   �
		����������������������������������������������������������������/*/
		nRd0Order	:= RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" )

		/*/
		��������������������������������������������������������������Ŀ
		�Define o Bloco para Contador do Numero de Avaliadores		   �
		����������������������������������������������������������������/*/
		bMaxCodDor := { |x| IF(	!x[nRdaDeleted];
								.and.;
								( x[nRdaCodAdo] == cRd0Codigo );
								.and.;
								( x[nRdaDtiAva] == dDataIni );
								.and.;
								( x[ nRdaCodNet ] == aRdhCols[ nRdhLoop , nRdhCodNet ] );
								.and.;
								( x[ nRdaTipoAv ] == aRdhCols[ nRdhLoop , nRdhFeedBk ] ),;
								++nMaxCodDor,;
								NIL;
							);
					}

		aRD0Crit:={}
		/*/
		��������������������������������������������������������������Ŀ
		�Percorrendo todos os Periodos                     			   �
		����������������������������������������������������������������/*/
		nRdtLoops := Len( aRdtCols )
		IF ( lShowProc )
			cTimeIni := Time()
		EndIF
		For nRdtLoop := 1 To nRdtLoops

			cRdtAlias := GdFieldGet( "RDT_ALIAS" , nRdtLoop , .F. , aRdtHeader , aRdtCols )

			IF (;
					Empty( cRdtAlias );
					.or.;
					(;
						( cRdtAlias <> "RD0" );
						.and.;
						( ( nRelation := aScan( aRelation , { |x| x[1] == cRdtAlias } ) ) == 0 );
					);
				)
				Loop
			EndIF

			IF ( cRdtAlias <> "RD0" )
				bRelation		:= { || ( cRdtAlias )->( &( aRelation[ nRelation , 05 ] ) ) }
				nRdtAliasOrd	:= ( cRdtAlias )->( RetOrdem( cRdtAlias , aRelation[ nRelation , 05 ] ) )
			Else
				nRdtAliasOrd	:= RD0->( RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" ) )
			EndIF
			( cRdtAlias )->( dbSetOrder( nRdtAliasOrd ) )
			cFieldFil		:= ( PrefixoCpo( cRdtAlias ) + "_FILIAL" )
			nFieldFil		:= ( cRdtAlias )->( FieldPos( cFieldFil ) )
			cRdtCriter		:= GdFieldGet( "RDT_CRITER" , nRdtLoop , .F. , aRdtHeader , aRdtCols )
			DEFAULT cRdtCriter := ""
			aIndex			:= {}
			bFilter			:= { || FilBrowse( cRdtAlias , @aIndex , cRdtCriter , lShowProc ) }
			Eval( bFilter )
			nRdtAliasOrd	:= ( cRdtAlias )->( IndexOrd() )

			IF ( lShowProc )
				CREATE SCOPE aScopeCount FOR &( cRdtCriter )
				nProcRegua	:= ( cRdtAlias )->( ScopeCount( aScopeCount ) )
				BarGauge1Set( nProcRegua )
				nContPrc1	:= Aleatorio( 15000 , @nAPDA270Seed )
			EndIF
			aRD0Aux		:={}
			nNextRecno	:= NIL
			( cRdtAlias )->( dbGotop() )
			While ( cRdtAlias )->( !Eof() )

				IF ( lShowProc )
					IncPrcG1Time( NIL , nProcRegua , cTimeIni , .F. , nContPrc1 , 1 )
					IF ( lAbortPrint )
						Break
					EndIF
				EndIF
				If cRdtAlias=="RDE"
					Eval( bFilter )
					GotoNextRecno( cRdtAlias , nNextRecno , nRdtAliasOrd )
				EndIf
				/*/
				��������������������������������������������������������������Ŀ
				�Obtem o Proximo Registro                            		   �
				����������������������������������������������������������������/*/
				IF !GetNextRecno( cRdtAlias , @nNextRecno , NIL , nRdtAliasOrd )
					Exit
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				�Se nao for o RD0, verifica se Existe Relacionamento		   �
				����������������������������������������������������������������/*/
				IF ( cRdtAlias <> "RD0" )
					cRelation	:= Eval( bRelation )
					IF ( nFieldFil > 0 )
						cFilRdtAlias	:= ( cRdtAlias )->( FieldGet( nFieldFil ) )
					EndIF
					IF Empty( cFilRdtAlias )
						cFilRdtAlias 	:= cSvFilAnt
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					�Verifica de tem campos com relacionamentos, se nao houver, faz�
					�tratamento atraves do SX9                                     �
					����������������������������������������������������������������/*/
					If Empty(aRelation[ nRelation , 02 ])
						aAreas:={}
						CheckSx9( "RD0",@aAreas)  							// retorna no array aAreas, todas as tabelas que se relaciona com RD0
						nPos:=aScan( aAreas , { |x| x[1,1]=cRdtAlias})
						cKeyRdt:=""  												//
						aEval(aAreas[nPos,2],{|x|cKeyRdt+=cRdtAlias+"->"+x+"+"})	// Grava os campos de relacionamento com a tabela rd0
						cKeyRdt:=&(Subs(cKeyRdt,1,Len(cKeyRdt)-1))
						nRd0SvOrd:= RD0->( IndexOrd() )
						RD0->( dbSetOrder( RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" ) ) )
						lFound:=RD0->( MsSeek( cKeyRdt , .F. ) )
						RD0->( dbSetOrder( nRd0SvOrd ) )
					Else
						lFound:=ExistePessoa( cRdtAlias , cRelation , cEmpAnt , cFilRdtAlias , .T. )
					EndIf
					If !lFound
						IF !( GotoNextRecno( cRdtAlias , nNextRecno , nRdtAliasOrd ) )
							Exit
						EndIF
						Loop
					EndIF
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				�Obtem as Informacoes do RD0            					   �
				����������������������������������������������������������������/*/
				cRd0Fil		:= RD0->RD0_FILIAL
				cRd0Codigo	:= RD0->RD0_CODIGO
				cRd0Nome	:= RD0->RD0_NOME
				cRd0CodMen	:= RD0->RD0_CODMEN

				cRdeFil		:= xFilial( "RDE" , cRd0Fil )
				cRdeKeySeek := ( cRdeFil + cRd0Codigo + cRd6CodVis )
				/*/
				��������������������������������������������������������������Ŀ
				�Query para Carga das Informacoes do RDE					   �
				����������������������������������������������������������������/*/
				aRdeQuery		:= Array( 09 )
				aRdeQuery[01]	:= "RDE_FILIAL='"+cRdeFil+"'"
				aRdeQuery[02]	:= " AND "
				aRdeQuery[03]	:= "RDE_CODPAR='"+cRd0Codigo+"'"
				aRdeQuery[04]	:= " AND "
				aRdeQuery[05]	:= "RDE_CODVIS='"+cRd6CodVis+"'"
				aRdeQuery[06]	:= " AND "
				aRdeQuery[07]	:= "RDE_STATUS='"+cRdeStatus+"'"
				aRdeQuery[08]	:= " AND "
				aRdeQuery[09]	:= "D_E_L_E_T_=' ' "

				/*/
				��������������������������������������������������������������Ŀ
				�Lock dos Registros do RDE									   �
				����������������������������������������������������������������/*/
				aRdeRecnos	:= {}
				aRdeKeys	:= {}
				nRdeLocks	:= 0
				IF (;
						!ExeWhile(	NIL,;
									NIL,;
									{ |lLocks| Eval( bRdeGet , @lLocks ) , lRdeLocks := lLocks , !( lLocks ) },;
									NIL,;
									{ || ++nRdeLocks > 3 };
								);
						.or.;
						!( lRdeLocks );
						.or.;
						Empty( aRdeRecnos );
					)
					FreeLocks( "RDE" , aRdeRecnos , .T. , aRdeKeys )
					IF !( GotoNextRecno( cRdtAlias , nNextRecno , nRdtAliasOrd ) )
						Exit
					EndIF
					Loop
				EndIF
				nRdeLoops 	:= Len( aRdeCols )
				IF !( lApda80BldAuto := !Empty( nRdeIteVis := GdFieldPos( "RDE_ITEVIS"	, aRdeHeader ) ) )
					Break
				EndIF
				aadd(aRD0Aux, {cRd0Fil,cRd0Codigo,cRd0Nome,RD0->(RECNO())})
				/*/
				��������������������������������������������������������������Ŀ
				�Libera os Locks do RDE                              		   �
				����������������������������������������������������������������/*/
				FreeLocks( "RDE" , aRdeRecnos , .T. , aRdeKeys )

				/*/
				��������������������������������������������������������������Ŀ
				�Proximo Registro                                    		   �
				����������������������������������������������������������������/*/
				IF !( GotoNextRecno( cRdtAlias , nNextRecno , nRdtAliasOrd ) )
					Exit
				EndIF

			End While
			EndFilBrw( cRdtAlias , aIndex )
			/*/
			��������������������������������������������������������������Ŀ
			�Armazena o resultado do criterio processadO                   �
			����������������������������������������������������������������/*/
			If nRdtLoop==1
				aRD0Crit:=aClone(aRD0Aux)
			Else
				// Pesquisa os codigos que sao comuns nos dois array, senao for deleta
				For nRD0CLoop :=1 to Len(aRD0Crit)
					If (Ascan(aRD0Aux,{|xC| xC[2]==aRD0Crit[nRD0CLoop,2]}))==0
						aRD0Crit[nRD0CLoop,2]:="" // Nao pode deletar pq ele reposiciona o array delera para o final e erra o Laco
					EndIf
				Next nRD0CLoop
			EndIf
		Next nRdtLoop

		If !Empty(cRdtCriter) .And. cRdtAlias == "RDE"
			cArqPart := GetNextAlias()
			cArqTMP1 := GetNextAlias()
			fBuscPart(cRdeFil, cRd6CodVis, cRdeStatus, cRdtCriter)
		EndIf

		For nRD0CLoop := 1 to Len(aRD0Crit)
			
			If Empty(aRD0Crit[nRD0CLoop,2])
				Loop
			Endif

			RD0->( dbgoto(aRD0Crit[nRD0CLoop,4]) )
			
			/*/
			��������������������������������������������������������������Ŀ
			�Obtem as Informacoes do RD0            					   �
			����������������������������������������������������������������/*/
			cRd0Fil		:= RD0->RD0_FILIAL
			cRd0Codigo	:= RD0->RD0_CODIGO
			cRd0Nome	:= RD0->RD0_NOME
			cRd0CodMen	:= RD0->RD0_CODMEN

			cRdeFil		:= xFilial( "RDE" , cRd0Fil )
			cRdeKeySeek := ( cRdeFil + cRd0Codigo + cRd6CodVis )

			/*/
			��������������������������������������������������������������Ŀ
			�Query para Carga das Informacoes do RDE					   �
			����������������������������������������������������������������/*/
			aRdeQuery		:= Array( 09 )
			aRdeQuery[01]	:= "RDE_FILIAL='"+cRdeFil+"'"
			aRdeQuery[02]	:= " AND "
			aRdeQuery[03]	:= "RDE_CODPAR='"+cRd0Codigo+"'"
			aRdeQuery[04]	:= " AND "
			aRdeQuery[05]	:= "RDE_CODVIS='"+cRd6CodVis+"'"
			aRdeQuery[06]	:= " AND "
			aRdeQuery[07]	:= "RDE_STATUS='"+cRdeStatus+"'"
			aRdeQuery[08]	:= " AND "
			aRdeQuery[09]	:= "D_E_L_E_T_=' ' "
		/*/
			��������������������������������������������������������������Ŀ
			�Lock dos Registros do RDE									   �
			����������������������������������������������������������������/*/
			aRdeRecnos	:= {}
			aRdeKeys	:= {}
			nRdeLocks	:= 0
			IF (;
					!ExeWhile(	NIL,;
								NIL,;
								{ |lLocks| Eval( bRdeGet , @lLocks ) , lRdeLocks := lLocks , !( lLocks ) },;
								NIL,;
								{ || ++nRdeLocks > 3 };
							);
					.or.;
					!( lRdeLocks );
					.or.;
					Empty( aRdeRecnos );
				)
				FreeLocks( "RDE" , aRdeRecnos , .T. , aRdeKeys )
				Loop
			EndIF

			nRdeLoops 	:= Len( aRdeCols )

			IF !( lApda80BldAuto := !Empty( nRdeIteVis := GdFieldPos( "RDE_ITEVIS"	, aRdeHeader ) ) )
				Break
			EndIF

			nRdpLoops := Len( aRdpCols )

			IF ( lShowProc )
				BarGauge2Set( nRdpLoops )
				IncProcG2( STR0130 , .F. ) //"Gerando Avalia��o..."
			EndIF

			For nRdpLoop := 1 To nRdpLoops

				IF ( lShowProc )
					IncProcG2()
					IF ( lAbortPrint )
						FreeLocks( "RDE" , aRdeRecnos , .T. , aRdeKeys )
						Break
					EndIF
				EndIF

				IF (;
						aRdpCols[ nRdpLoop , nRdpDelete ];
					)
					Loop
				EndIF

				IF (;
						( aRdpCols[ nRdpLoop , nRdpDatIni ] < dPerIni );
						.or.;
						( aRdpCols[ nRdpLoop , nRdpDatIni ] > dPerFim );
					)
					Loop
				EndIF

				dDataIni	:= aRdpCols[ nRdpLoop , nRdpDatIni ]
				dDataFim	:= aRdpCols[ nRdpLoop , nRdpDatFim ]

				aHeader		:= aClone( aRd9Header )
				n			:= 1
				aCols		:= GdRmkaCols( aHeader , .F. , .T. , .T. )
				aCols[ n , nRd9CodAva	] := cRd6Codigo
				aCols[ n , nRd9CodAdo	] := cRd0Codigo
				aCols[ n , nRd9Nome		] := cRd0Nome
				aCols[ n , nRd9DtiAva	] := dDataIni
				aCols[ n , nRd9DtfAva	] := dDataFim

				If !Empty(cRd6CodPro)
					aCols[ n , nRd9CodPro	] := cRd6CodPro
				Endif

				aAdd( aRd9Cols , aClone( aCols[ 1 ] ) )
				aCols	:= aClone( aRd9Cols )
				n		:= Len( aRd9Cols )

				IF !( a270Rd9GdLinOk( NIL , .F. , 1 ) )
					aDel( aRd9Cols , n )
					aSize( aRd9Cols , --n )
				Else
					IF ( lRd9GhostCol )
						aRd9Cols[ n , nRd9GhostCol	] := GdNumItem( "GHOSTCOL" )
					EndIF
					IF ( lRd9ColBmp )
						cInitPad := aRd9Header[ nRd9ColBmp , 12 ]
						bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
						IF ( CheckExecForm( bInitPad , .F. ) )
							aRd9Cols[ n , nRd9ColBmp ] := uInitPad
						EndIF
					EndIF
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				�Montagem Autom�tica										   �
				����������������������������������������������������������������/*/
				IF ( cRd6Montag == "3" )

					aHeader := aClone( aRdaHeader )

					/*/
					��������������������������������������������������������������Ŀ
					�Carregando os Avaliadores Conforme a Rede					   �
					����������������������������������������������������������������/*/
					For nRdhLoop := 1 To nRdhLoops

						/*/
						��������������������������������������������������������������Ŀ
						�Verifica se a Rede eh de Auto-Avaliacao              	   	   �
						����������������������������������������������������������������/*/
						lRdhAutoAv	:= ( aRdhCols[ nRdhLoop , nRdhAutoAv ] == "1" )

						/*/
						��������������������������������������������������������������Ŀ
						�Verifica se Tem Avaliacao de Consenso                	   	   �
						����������������������������������������������������������������/*/
						lRdhFeedBk	:= ( aRdhCols[ nRdhLoop , nRdhFeedBk ] == "1" )

						/*/
						��������������������������������������������������������������Ŀ
						� Obtem o Numero de Participantes Avaliadores                  �
						����������������������������������������������������������������/*/
						nRdhMaxPar	:= aRdhCols[ nRdhLoop , nRdhNumPar ]
						/*/
						��������������������������������������������������������������Ŀ
						� Se Houver Avaliacao de Consenso, Incrementa Maximo de Partici�
						� pantes Avaliadores										   �
						����������������������������������������������������������������/*/
						IF ( lRdhFeedBk )
							nRdhMaxPar *= 2
						EndIF

						/*/
						��������������������������������������������������������������Ŀ
						�Carrega o Avaliado como Avaliador ( Auto-Avaliacao )		   �
						����������������������������������������������������������������/*/
						IF ( ( lRd6AutoAv ) .and. ( lRdhAutoAv ) )
							aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
							n := 1
							aCols[ n , nRdaCodAva	] := cRd6Codigo
							aCols[ n , nRdaCodAdo	] := cRd0Codigo
							aCols[ n , nRdaCodDor	] := cRd0Codigo
							aCols[ n , nRdaNome		] := cRd0Nome
							aCols[ n , nRdaDtiAva	] := dDataIni
							aCols[ n , nRdaDtfAva	] := dDataFim
							aCols[ n , nRdaCodTip	] := cRd6CodTip
							aCols[ n , nRdaCodNet	] := aRdhCols[ nRdhLoop , nRdhCodNet ]
							aCols[ n , nRdaNivel	] := aRdhCols[ nRdhLoop , nRdhNivel  ]
							aCols[ n , nRdaTipoAv	] := GetTpAvAdo()
							If !Empty(cRd6CodPro)
								aCols[ n , nRdaCodPro	] := cRd6CodPro
							Endif
							aAdd( aRdaCols , aClone( aCols[ 1 ] ) )
							aCols	:= aClone( aRdaCols )
							n		:= Len( aRdaCols )
							IF !( a270GdLinOk( NIL , .F. , 1 ) )
								aDel( aRdaCols , n )
								aSize( aRdaCols , --n )
							Else
								IF ( lRdaGhostCol )
									aRdaCols[ n , nRdaGhostCol	] := GdNumItem( "GHOSTCOL" )
								EndIF
								IF ( lRdaColBmp )
									cInitPad := aRdaHeader[ nRdaColBmp , 12 ]
									bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
									IF ( CheckExecForm( bInitPad , .F. ) )
										aRdaCols[ n , nRdaColBmp ] := uInitPad
									EndIF
								EndIF
							EndIF
							/*/
							��������������������������������������������������������������Ŀ
							�Se a Rede Definir Consenso, Gera a Avaliacao de Consenso	   �
							����������������������������������������������������������������/*/
							IF ( lRdhFeedBk )
								aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
								n := 1
								aCols[ n , nRdaCodAva	] := cRd6Codigo
								aCols[ n , nRdaCodAdo	] := cRd0Codigo
								aCols[ n , nRdaCodDor	] := cRd0Codigo
								aCols[ n , nRdaNome		] := cRd0Nome
								aCols[ n , nRdaDtiAva	] := dDataIni
								aCols[ n , nRdaDtfAva	] := dDataFim
								aCols[ n , nRdaCodTip	] := cRd6CodTip
								aCols[ n , nRdaCodNet	] := aRdhCols[ nRdhLoop , nRdhCodNet ]
								aCols[ n , nRdaNivel	] := aRdhCols[ nRdhLoop , nRdhNivel  ]
								aCols[ n , nRdaTipoAv	] := GetTpAvCon()
								If !Empty(cRd6CodPro)
									aCols[ n , nRdaCodPro	] := cRd6CodPro
								Endif
								aAdd( aRdaCols , aClone( aCols[ 1 ] ) )
								aCols	:= aClone( aRdaCols )
								n		:= Len( aRdaCols )
								IF !( a270GdLinOk( NIL , .F. , 1 ) )
									aDel( aRdaCols , n )
									aSize( aRdaCols , --n )
								Else
									IF ( lRdaGhostCol )
										aRdaCols[ n , nRdaGhostCol	] := GdNumItem( "GHOSTCOL" )
									EndIF
									IF ( lRdaColBmp )
										cInitPad := aRdaHeader[ nRdaColBmp , 12 ]
										bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
										IF ( CheckExecForm( bInitPad , .F. ) )
											aRdaCols[ n , nRdaColBmp ] := uInitPad
										EndIF
									EndIF
								EndIF
							EndIF
						EndIF

						/*/
						��������������������������������������������������������������Ŀ
						�Carrega o Mentor como Avaliador           				   	   �
						����������������������������������������������������������������/*/
						IF ( aRdhCols[ nRdhLoop , nRdhNivel ] == "2" )
							IF !Empty( cRd0CodMen )
								aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
								n := 1
								aCols[ n , nRdaCodAva	] := cRd6Codigo
								aCols[ n , nRdaCodAdo	] := cRd0Codigo
								aCols[ n , nRdaCodDor	] := cRd0CodMen
								aCols[ n , nRdaNome		] := PosAlias( "RD0" , cRd0CodMen , cRd0Fil , "RD0_NOME" , nRd0Order , .F. )
								aCols[ n , nRdaDtiAva	] := dDataIni
								aCols[ n , nRdaDtfAva	] := dDataFim
								aCols[ n , nRdaCodTip	] := cRd6CodTip
								aCols[ n , nRdaCodNet	] := aRdhCols[ nRdhLoop , nRdhCodNet ]
								aCols[ n , nRdaNivel	] := aRdhCols[ nRdhLoop , nRdhNivel  ]
								aCols[ n , nRdaTipoAv	] := GetTpAvDor()
								If !Empty(cRd6CodPro)
									aCols[ n , nRdaCodPro	] := cRd6CodPro
								Endif
								aAdd( aRdaCols , aClone( aCols[ 1 ] ) )
								aCols	:= aClone( aRdaCols )
								n		:= Len( aRdaCols )
								IF !( a270GdLinOk( NIL , .F. , 1 ) )
									aDel( aRdaCols , n )
									aSize( aRdaCols , --n )
								Else
									IF ( lRdaGhostCol )
										aRdaCols[ n , nRdaGhostCol	] := GdNumItem( "GHOSTCOL" )
									EndIF
									IF ( lRdaColBmp )
										cInitPad := aRdaHeader[ nRdaColBmp , 12 ]
										bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
										IF ( CheckExecForm( bInitPad , .F. ) )
											aRdaCols[ n , nRdaColBmp ] := uInitPad
										EndIF
									EndIF
								EndIF
								/*/
								��������������������������������������������������������������Ŀ
								�Se a Rede Definir Consenso, Gera a Avaliacao de Consenso	   �
								����������������������������������������������������������������/*/
								IF ( lRdhFeedBk )
									aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
									n := 1
									aCols[ n , nRdaCodAva	] := cRd6Codigo
									aCols[ n , nRdaCodAdo	] := cRd0Codigo
									aCols[ n , nRdaCodDor	] := cRd0CodMen
									aCols[ n , nRdaNome		] := PosAlias( "RD0" , cRd0CodMen , cRd0Fil , "RD0_NOME" , nRd0Order , .F. )
									aCols[ n , nRdaDtiAva	] := dDataIni
									aCols[ n , nRdaDtfAva	] := dDataFim
									aCols[ n , nRdaCodTip	] := cRd6CodTip
									aCols[ n , nRdaCodNet	] := aRdhCols[ nRdhLoop , nRdhCodNet ]
									aCols[ n , nRdaNivel	] := aRdhCols[ nRdhLoop , nRdhNivel  ]
									aCols[ n , nRdaTipoAv	] := GetTpAvCon()
									If !Empty(cRd6CodPro)
										aCols[ n , nRdaCodPro	] := cRd6CodPro
									Endif
										aAdd( aRdaCols , aClone( aCols[ 1 ] ) )
									aCols	:= aClone( aRdaCols )
									n		:= Len( aRdaCols )
									IF !( a270GdLinOk( NIL , .F. , 1 ) )
										aDel( aRdaCols , n )
										aSize( aRdaCols , --n )
									Else
										IF ( lRdaGhostCol )
											aRdaCols[ n , nRdaGhostCol	] := GdNumItem( "GHOSTCOL" )
										EndIF
										IF ( lRdaColBmp )
											cInitPad := aRdaHeader[ nRdaColBmp , 12 ]
											bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
											IF ( CheckExecForm( bInitPad , .F. ) )
												aRdaCols[ n , nRdaColBmp ] := uInitPad
											EndIF
										EndIF
									EndIF
								EndIF
							EndIF
						EndIF

						/*/
						��������������������������������������������������������������Ŀ
						�Carrega os Avaliadores                    				   	   �
						����������������������������������������������������������������/*/
						For nRdeLoop := 1 To nRdeLoops

							aRdeCodRd0	:= {}
							aTotPar 	:= {} //Zera variavel
							/*/
							��������������������������������������������������������������Ŀ
							�Carregou o Mentor como Avaliador          				   	   �
							����������������������������������������������������������������/*/
							If ( aRdhCols[ nRdhLoop , nRdhNivel ] == "2" ).AND.!Empty( cRd0CodMen )
								nMaxCodDor	:= 2
							Else
								nMaxCodDor	:= 0
							EndIf

							//Verifica se j� carregou os participantes do n�vel, em caso afirmativo, carrega o array. (melhoria performance)
							If ( nPosAux := ( aScan( aRdeCompAux , { |x| x[1]+x[2] == aRdeCols[ nRdeLoop , nRdeIteVis ] + aRdhCols[ nRdhLoop , nRdhNivel  ] .and. x[3] == aRdhCols[ nRdhLoop , nRdhNumNiv ] } ) ) ) > 0
								aRdeCodRd0 := aClone(aRdeCompAux[nPosAux][4])
								aTotPar    := aClone(aRdeCompAux[nPosAux][5])
							Else
								ApdaDorNivel(	aRdeCols[nRdeLoop, nRdeIteVis]		, ;	// 01 -> Codigo do Item Inicial
												cRdeFil								, ;	// 02 -> Filial do RDE
												cRd6CodVis							, ;	// 03 -> Cogido da Visao
												aRdhCols[nRdhLoop, nRdhNivel]		, ;	// 04 -> Posicao no Nivel (1=Mesmo Nivel),(2=Superior), (3=Subordinado)
												aRdhCols[nRdhLoop, nRdhNumNiv]		, ;	// 05 -> Numero de Niveis
												@aRdeCodRd0							, ;	// 06 -> Array com os Participantes do Nivel
												Nil									, ;	// 07 -> Qual o Status para o RDE
												Nil									, ;	// 08 -> Condicao de Filtro de Respons�vel		
												Iif(Empty(cArqTMP1), Nil, cArqTMP1) , ;	// 09 -> Alias tempor?io RDE
											)

								aAdd(aRdeCompAux, {aRdeCols[nRdeLoop, nRdeIteVis], aRdhCols[nRdhLoop, nRdhNivel], aRdhCols[nRdhLoop, nRdhNumNiv], aClone(aRdeCodRd0), {}})
							EndIf

							aEval( aRdaCols , bMaxCodDor )
							nLoopsRdeRd0	:= Len( aRdeCodRd0 )

							If nLoopsRdeRd0 == 0
								Loop
							EndIf

							//For nLoopRdeRd0 := 1 To nLoopsRdeRd0
							aPosAux := {}

							//Para existir equilibrio entre a quantidade de avalia��es por avaliador, ser� efetuado
							//controle da quantidade de avalia��es de cada participante. Matematicamente cada participante deveria
							//ter no m�ximo a mesma quantidade de avalia��es por pares definidas na rede
							nMedTAux := nRdhMaxPar
							nLoopRdeRd0 := 0

							While .T.
								If nRdhMaxPar < nLoopsRdeRd0
									nLoopRdeRd0 := Randomize( 1, nLoopsRdeRd0+1 )
							
									If nLoopRdeRd0 > nLoopsRdeRd0 //Documenta��o diz que fun��o retorna n�mero no intervalo do parametro inicial at� o parametro final menos 1...por�m esta devolvendo o valor do parametro final..inclus�odeste IF para n�o ocorrer problemas.
										Loop
									EndIf
								Else
									nLoopRdeRd0++ //Se a quantidade de avaliadores for maior ou igual a quantidade de participantes no n�vel, todos ser�o avaliadores, por isso n�o precisa executaar o randomize
							
									If nLoopRdeRd0 > nLoopsRdeRd0
										Exit
									EndIf
								EndIf
							
								If ( ( nMaxCodDor + 1 ) > nRdhMaxPar )
									Exit
								EndIf
							
								lSomaAux := .T.
								While .T.
									If aScan( aPosAux , { |x| x == nLoopRdeRd0 } ) > 0 .or. ( aRdeCodRd0[ nLoopRdeRd0 , 1 ] == cRd0Codigo )
										If lSomaAux
											nLoopRdeRd0++
										Else
											nLoopRdeRd0--
										EndIf
							
										If nLoopRdeRd0 > nLoopsRdeRd0
											nLoopRdeRd0--
											lSomaAux := .F. //Se foi at� a �ltima posi��o, come�a a decrementar para encontrar as menores que na� foram usadas
										EndIf

										If nLoopRdeRd0 == 0
											Exit
										EndIf

										Loop
									Else
										aAdd(aPosAux,nLoopRdeRd0)
										Exit
									EndIf
								EndDo
							
								If nLoopRdeRd0 > nLoopsRdeRd0 .or. nLoopRdeRd0 == 0 .or. Len(aPosAux) > nLoopsRdeRd0
									Exit
								EndIf
							
								If ( aRdeCodRd0[ nLoopRdeRd0 , 1 ] == cRd0Codigo )
									Loop
								EndIf
							
								//Se j� foi avaliador mais do que a quantidade m�dia, pula (apenas se as op��es j� n�o estiverem acabando)
								If ( nPosAux := ( aScan( aTotPar , { |x| x[1]+x[2]+x[3] == aRdeCodRd0[ nLoopRdeRd0 , 1 ] + Dtos(dDataIni) + Dtos(dDataFim)  } ) ) ) > 0
									If aTotPar[nPosAux,4] >= nMedTAux .and. Len(aPosAux)+nRdhMaxPar+1 <= nLoopsRdeRd0
										Loop
									Else
										aTotPar[nPosAux,4] += 1
									EndIf
								Else
									aAdd(aTotPar,{aRdeCodRd0[ nLoopRdeRd0, 1 ] ,Dtos(dDataIni) , Dtos(dDataFim) , 1})
								EndIf

								If Len(aTotPar) == nLoopsRdeRd0 .and. nMedTAux == nRdhMaxPar
									//Quando todos os particpantes possuirem pelo menos uma avalia��o
									// � somado 1 na m�dia para existir margem, caso um participante n�o
									//esteja apto a ser avaliador por algum motivo (a270GdLinOk())
									nMedTAux += 1
								EndIf

								aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
								n := 1
								aCols[ n , nRdaCodAva	] := cRd6Codigo
								aCols[ n , nRdaCodAdo	] := cRd0Codigo
								aCols[ n , nRdaCodDor	] := aRdeCodRd0[ nLoopRdeRd0 , 1 ]
								aCols[ n , nRdaNome		] := PosAlias( "RD0" , aRdeCodRd0[ nLoopRdeRd0 , 1 ] , cRd0Fil , "RD0_NOME" , nRd0Order , .F. )
								aCols[ n , nRdaDtiAva	] := dDataIni
								aCols[ n , nRdaDtfAva	] := dDataFim
								aCols[ n , nRdaCodTip	] := cRd6CodTip
								aCols[ n , nRdaCodNet	] := aRdhCols[ nRdhLoop , nRdhCodNet ]
								aCols[ n , nRdaNivel	] := aRdhCols[ nRdhLoop , nRdhNivel  ]
								aCols[ n , nRdaTipoAv	] := GetTpAvDor()
							
								If !Empty(cRd6CodPro)
									aCols[ n , nRdaCodPro	] := cRd6CodPro
								Endif
							
								aAdd( aRdaCols , aClone( aCols[ 1 ] ) )
								aCols	:= aClone( aRdaCols )
								n		:= Len( aRdaCols )
							
								IF !( a270GdLinOk( NIL , .F. , 1 ) )
									aDel( aRdaCols , n )
									aSize( aRdaCols , --n )
								Else
									++nMaxCodDor
							
									IF ( lRdaGhostCol )
										aRdaCols[ n , nRdaGhostCol	] := GdNumItem( "GHOSTCOL" )
									EndIF
							
									IF ( lRdaColBmp )
										cInitPad := aRdaHeader[ nRdaColBmp , 12 ]
										bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
										IF ( CheckExecForm( bInitPad , .F. ) )
											aRdaCols[ n , nRdaColBmp ] := uInitPad
										EndIF
									EndIF
								EndIF
							
								/*/
								��������������������������������������������������������������Ŀ
								�Se a Rede Definir Consenso, Gera a Avaliacao de Consenso	   �
								����������������������������������������������������������������/*/
								IF ( lRdhFeedBk )
									aCols := GdRmkaCols( aHeader , .F. , .T. , .T. )
									n := 1
									aCols[ n , nRdaCodAva	] := cRd6Codigo
									aCols[ n , nRdaCodAdo	] := cRd0Codigo
									aCols[ n , nRdaCodDor	] := aRdeCodRd0[ nLoopRdeRd0 , 1 ]
									aCols[ n , nRdaNome		] := PosAlias( "RD0" , aRdeCodRd0[ nLoopRdeRd0 , 1 ] , cRd0Fil , "RD0_NOME" , nRd0Order , .F. )
									aCols[ n , nRdaDtiAva	] := dDataIni
									aCols[ n , nRdaDtfAva	] := dDataFim
									aCols[ n , nRdaCodTip	] := cRd6CodTip
									aCols[ n , nRdaCodNet	] := aRdhCols[ nRdhLoop , nRdhCodNet ]
									aCols[ n , nRdaNivel	] := aRdhCols[ nRdhLoop , nRdhNivel  ]
									aCols[ n , nRdaTipoAv	] := GetTpAvCon()
							
									If !Empty(cRd6CodPro)
										aCols[ n , nRdaCodPro	] := cRd6CodPro
									Endif
							
									aAdd( aRdaCols , aClone( aCols[ 1 ] ) )
									aCols	:= aClone( aRdaCols )
									n		:= Len( aRdaCols )
							
									IF !( a270GdLinOk( NIL , .F. , 1 ) )
										aDel( aRdaCols , n )
										aSize( aRdaCols , --n )
									Else
										++nMaxCodDor
										IF ( lRdaGhostCol )
											aRdaCols[ n , nRdaGhostCol	] := GdNumItem( "GHOSTCOL" )
										EndIF
										IF ( lRdaColBmp )
											cInitPad := aRdaHeader[ nRdaColBmp , 12 ]
											bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
											IF ( CheckExecForm( bInitPad , .F. ) )
												aRdaCols[ n , nRdaColBmp ] := uInitPad
											EndIF
										EndIF
									EndIF
								EndIF
							EndDo
							
							nPosAux := aScan( aRdeCompAux , { |x| x[1]+x[2] == aRdeCols[ nRdeLoop , nRdeIteVis ] + aRdhCols[ nRdhLoop , nRdhNivel  ] .and. x[3] == aRdhCols[ nRdhLoop , nRdhNumNiv ] } )

							aRdeCompAux[nPosAux][5] := aClone(aTotPar)
							//Next nLoopRdeRd0

						Next nRdeLoops

					Next nRdhLoop

				EndIF

				IF ( aRdpCols[ nRdpLoop , nRdpStatus ] $ cRdpStSub )
					aRdpCols[ nRdpLoop , nRdpStatus ] := cRdpStGer
				EndIF
			Next nRdpLoop
		Next nRD0CLoop

	End Sequence

	IF !Empty( cMsgInfo )

		IF ( lShowProc )
			//"Aviso de Inconsist�ncia!"
			MsgInfo( OemToAnsi( cMsgInfo ) , STR0022 )
		EndIF

	Else

		IF (;
				lApda80BldAuto := (;
										( lRd9Modify := !ArrayCompare( aRd9SvCols , aRd9Cols ) );
										.or.;
										( lRdaModify := !ArrayCompare( aRdaSvCols , aRdaCols ) );
									);
			)

			IF ( lRd9Modify )
				/*/
				��������������������������������������������������������������Ŀ
				�Define o Bloco para Sort dos Avaliados        			   	   �
				����������������������������������������������������������������/*/
				bRd9Sort := { |x,y|	( x[ nRd9CodAdo ] + Dtos( x[ nRd9DtiAva] ) + IF( !x[ nRd9Delete ] , "0" , "1" ) );
									<;
									( y[ nRd9CodAdo ] + Dtos( y[ nRd9DtiAva] ) + IF( !y[ nRd9Delete ] , "0" , "1" ) );
							}
				aSort( aRd9Cols , NIL , NIL , bRd9Sort )
			EndIF

			IF ( lRdaModify )
				/*/
				��������������������������������������������������������������Ŀ
				�Define o Bloco para Sort dos Avaliadores      			   	   �
				����������������������������������������������������������������/*/
				bRdaSort := { |x,y|	( x[ nRdaCodAdo ] + Dtos( x[ nRdaDtiAva ] ) + x[ nRdaCodDor ] + IF( !x[ nRdaDelete ] , "0" , "1" ) );
									<;
									( y[ nRdaCodAdo ] + Dtos( y[ nRdaDtiAva ] ) + y[ nRdaCodDor ] + IF( !y[ nRdaDelete ] , "0" , "1" ) );
							}
				aSort( aRdaCols , NIL , NIL , bRdaSort )
			EndIF

		EndIF

	EndIF

	cEmpAnt := cSvEmpAnt
	cFilAnt := cSvFilAnt

	If cRdtAlias == "RDE"
		// FECHA O ALIAS CASO ESTEJA SENDO USADO.
		If Select(cArqPart) > 0
			(cArqPart)->(DbCloseArea())
		EndIf

		If Select(cArqTMP1) > 0
			(cArqTMP1)->(DbCloseArea())
		EndIf

		If oTabRDE <> Nil
			oTabRDE:Delete()
			oTabRDE := Nil
		EndIf
	EndIf
	
Return( lApda80BldAuto )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �a270IsInRdeVis	�Autor�Marinaldo de Jesus � Data �03/08/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verificar se Participante Esta Alocado em Determinada Visao �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function a270IsInRdeVis( cRdeCodPar , cRdeCodVis , cRdeStatus , cRdeFil )

Static nRdeOrder

DEFAULT cRdeCodPar	:= RD0->RD0_CODIGO
DEFAULT cRdeCodVis	:= GetMemVar( "RD6_CODVIS" )
DEFAULT cRdeStatus	:= "1"

DEFAULT nRdeOrder	:= RetOrdem( "RDE" , "RDE_FILIAL+RDE_CODPAR+RDE_CODVIS+RDE_STATUS" )

Return( ( PosAlias( "RDE" , ( cRdeCodPar + cRdeCodVis + cRdeStatus ) , xFilial( "RDE" , cRdeFil ) , "RDE_CODVIS" , nRdeOrder , .T. ) == cRdeCodVis ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GetRdeIteV		�Autor�Marinaldo de Jesus � Data �03/08/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Retorna o Item de Visao do Rde                              �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function a270GetRdeIteV( cRdeCodPar , cRdeCodVis , cRdeStatus , cRdeFil )

Local cRdeIteVis

IF a270IsInRdeVis( cRdeCodPar , cRdeCodVis , cRdeStatus , cRdeFil )
	cRdeIteVis := RDE->RDE_ITEVIS
Else
	cRdeIteVis := Space( GetSx3Cache( "RDE_ITEVIS" , "X3_TAMANHO" ) )
EndIF

Return( cRdeIteVis )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �APDA270CAL  � Autor � Eduardo Ju		    � Data � 17.03.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calculo do Resultado da Avaliacao Corrente                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�1- cAlias                                                   ���
���          �2- nReg                                                     ���
���          �3- nOpc                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function APDA270CAL(cAlias,nReg,nOpc)

	APDM010CALC(cAlias,nReg,nOpc,2)

Return Nil
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �APDA270BotCal� Autor � Eduardo Ju		    � Data � 17.03.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calculo do Resultado da Avaliacao para determinado Avaliado.���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�1- cAlias                                                   ���
���          �2- nReg                                                     ���
���          �3- nOpc                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function APDA270BotCal( nActFolder , aPages )

Local aSvKeys  			:= GetKeys()
Local cFolders 			:= AllTrim( Str( APDA270_FOLDER_AVALIADOS ) )
Local lAPDA270CalcAva 	:= .T.
Local oGdRd9 			:= NIL
Local cKeyRD9			:= ""

Begin Sequence

	IF !( AllTrim( Str( nActFolder ) ) $ cFolders )
		cMsgInfo := STR0115	//"Op��o dispon�vel apenas na(s) Pasta(s):"
		cMsgInfo += CRLF
		cMsgInfo += CRLF
		cMsgInfo += aPages[ APDA270_FOLDER_AVALIADOS ]
		MsgInfo( OemToAnsi( cMsgInfo ) , cCadastro )
		lAPDA270CalcAva := .F.
		Break
	EndIF

	oGdRd9			:= aFolders[ APDA270_FOLDER_AVALIADOS , APDA270_FOLDER_OBJECTS , 2 , APDA270_OBJ ]
	cKeyRD9			:= GdFieldGet( "RD9_CODAVA" , oGdRd9:oBrowse:nAt , .F. , oGdRd9:aHeader , oGdRd9:aCols )
	cKeyRD9			+= GdFieldGet( "RD9_CODADO" , oGdRd9:oBrowse:nAt , .F. , oGdRd9:aHeader , oGdRd9:aCols )
	cKeyRD9			+= GdFieldGet( "RD9_CODPRO" , oGdRd9:oBrowse:nAt , .F. , oGdRd9:aHeader , oGdRd9:aCols )
	cKeyRD9			+= DTOS(GdFieldGet( "RD9_DTIAVA" , oGdRd9:oBrowse:nAt , .F. , oGdRd9:aHeader , oGdRd9:aCols ))

	RD9->(dbSetOrder(1))
	RD9->(dbSeek(xFilial("RD9")+cKeyRD9))

	APDM010CALC("RD6",RD6->(Recno()),4,3)
//	APDM010CALC(cAlias,nReg,nOpc,3)

End Sequence

RestKeys( aSvKeys , .T. )

Return lAPDA270CalcAva

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �20/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APDA270                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function MenuDef()
/*/
	��������������������������������������������������������������Ŀ
	� Define Array contendo as Rotinas a executar do programa      �
	� ----------- Elementos contidos por dimensao ------------     �
	� 1. Nome a aparecer no cabecalho                              �
	� 2. Nome da Rotina associada                                  �
	� 3. Usado pela rotina                                         �
	� 4. Tipo de Transa��o a ser efetuada                          �
	�    1 - Pesquisa e Posiciona em um Banco de Dados             �
	�    2 - Simplesmente Mostra os Campos                         �
	�    3 - Inclui registros no Bancos de Dados                   �
	�    4 - Altera o registro corrente                            �
	�    5 - Remove o registro corrente do Banco de Dados          �
	����������������������������������������������������������������/*/

 Local aRotina :=	{;
								{ OemToAnsi( STR0002 ) , "PesqBrw"   	, 0 , 1,,.F.}	,; //"Pesquisar"
								{ OemToAnsi( STR0003 ) , "APDA270Mnt" 	, 0 , 2 }	,; //"Visualizar"
								{ OemToAnsi( STR0004 ) , "APDA270Mnt" 	, 0 , 3 }	,; //"Incluir"
								{ OemToAnsi( STR0005 ) , "APDA270Mnt" 	, 0 , 4 }	,; //"Alterar"
								{ OemToAnsi( STR0006 ) , "APDA270Mnt" 	, 0 , 5 }	,; //"Excluir"
								{ OemToAnsi( STR0141 ) , "APDA270Cal"	, 0 , 6 }  ;   //"Calcular"
							}
Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RetGrpUsr � Autor � Allyson Mesashi       � Data �11.08.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o(s) codigo(s) do(s) grupo(s) do usuario corrente. ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void RetGrpUsr()                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � RetC1  - Codigo(s) do(s) grupo(s) do usuario.              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APDA270()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RetGrpUsr()

Local aGrupos	:= UsrRetGrp( cUserName )
Local cCodGrp	:= ""

aEval( aGrupos , { |x| ( cCodGrp += ( x + "/" ) ) } )

Return ( cCodGrp )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MntThread � Autor � Leandro Drumond       � Data �19.03.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica existencia de Multi-Thread.                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRecAux                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APDA270()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MntThread(aRecGrv)
Local nQtdThread := SuperGetMv( "MV_APDMULT" , NIL , 0 )
Local aThreads	 := {}
Local nQtdRec	 := Len(aRecGrv)
Local nRegProc   := 0
Local nInicio	 := 1
Local nX		 := 0
Local nY		 := 0

If nQtdThread > 20
	nQtdThread := 20  //Nao pode ser maior que 20
EndIf

If Len(aRecGrv) > nQtdThread .and. nQtdThread > 1
	aThreads := Array(nQtdThread)

	For nX := 1 to nQtdThread
		// Quantidade de registros a processar
		nRegProc += IIf( nX == nQtdThread , nQtdRec - nRegProc, Int(nQtdRec/nQtdThread) )
		aThreads[nX] := {{}}

        For nY := nInicio to nRegProc
			aAdd(aThreads[nX,1],aRecGrv[nY])
        	nInicio := nRegProc
        Next nY
        nInicio++
	Next nX
Else
	aAdd(aThreads,aRecGrv)
EndIf

Return aThreads

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APDA270Thread � Autor � Leandro Drumond   � Data �19.03.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Job para execucao das multi-threads.                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � APDA270()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function APDA270Thread(cEmp,cFil,aRecnos,cJobFile,cThread,cPath)

Local nLoop	  	:= 0
Local nLoops   	:= 0

Default cPath := ""

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue("PD080"+cEmp+cFil+cThread, "1" )
GlbUnLock()

// Seta job para nao consumir licensas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'APD')

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("PD080"+cEmp+cFil+cThread, "2" )
GlbUnLock()

DbSelectArea('RDA')

ConOut(dtoc(Date())+" "+Time()+ " APDA270: " + STR0145 + " - " + cJobFile)

nLoops  := Len(aRecnos)

For nLoop := 1 to nLoops

	RDA->( dbGoto( aRecnos[nLoop][1] ) )

	If RDA->( RecLock( "RDA" , .F. ) )

		a270Rda2RdcPut(aRecnos[nLoop][2])

		RDA->( MsUnLock() )

		If !aRecnos[nLoop][2]
			RDA->( FkCommit() )
		EndIf
	EndIf
Next nLoop

ConOut(dtoc(Date())+" "+Time()+ " APDA270: " + STR0146 + " - " + cJobFile)

// STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("PD080"+cEmp+cFil+cThread,"3")
GlbUnLock()

Return

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodPerVld	 �Autor�Emerson Campos    � Data �24/01/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RB6_CODPER									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RB6_CODPER									�
�������������������������������������������������������������������������/*/
Function Rd6CodPerVld()

Local lRb6PeriodVld	:= .T.

Begin Sequence

	IF !( lRb6PeriodVld := ( NaoVazio() .And. ExistCpo("RDU", GetMemVar("RD6_CODPER") ) .And.;
		(AllTrim(Fdesc("RDU", GetMemVar("RD6_CODPER"), "RDU_TIPO")) == "4" .OR.;
		 AllTrim(Fdesc("RDU", GetMemVar("RD6_CODPER"), "RDU_TIPO")) == "5") ) )
		Break
	EndIF

End Sequence

Return( lRb6PeriodVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodProVld	 �Autor�Emerson Campos    � Data �29/01/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RB6_CODPRO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RB6_CODPRO									�
�������������������������������������������������������������������������/*/
Function Rd6CodProVld()
Local lRd6CodProVld := .T.

If !Empty(GetMemVar("RD6_CODPRO"))
	lRd6CodProVld := (NaoVazio() .and. ExistCpo("RDN", GetMemVar("RD6_CODPRO") ))
EndIf

Return( lRd6CodProVld )


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodAdoInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODADO					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODADO								�
�������������������������������������������������������������������������/*/
Function R270CodAdoInit()

Local cRdaCodAdoInit	:= Space( GetSx3Cache("RDA_CODADO","X3_TAMANHO" ) )

Local nRd9CodAdo
Local oGdRd9

IF ( Apda270Fldrs() )
	oGdRd9	:= oGdRd9Get( APDA270_FOLDER_AVALIADORES )
	IF ( ValType( oGdRd9 ) == "O" )
		IF ( ( nRd9CodAdo := GdFieldPos( "RD9_CODADO" , oGdRd9:aHeader ) ) > 0 )
			cRdaCodAdoInit	:= oGdRd9:aCols[ oGdRd9:nAt , nRd9CodAdo ]
		EndIF
	EndIF
EndIF

Return( cRdaCodAdoInit )


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodProInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODPRO					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODPRO								�
�������������������������������������������������������������������������/*/
Function R270CodProInit()

Local cRdaCodProInit := Space( GetSx3Cache("RDA_CODPRO","X3_TAMANHO" ) )

Local nRd9CodPro
Local oGdRd9

IF ( Apda270Fldrs() )
	oGdRd9	:= oGdRd9Get( APDA270_FOLDER_AVALIADORES )
	IF ( ValType( oGdRd9 ) == "O" )
		IF ( ( nRd9CodPro := GdFieldPos( "RD9_CODPRO" , oGdRd9:aHeader ) ) > 0 )
			cRdaCodProInit	:= oGdRd9:aCols[ oGdRd9:nAt , nRd9CodPro ]
		EndIF
	EndIF
EndIF

Return( cRdaCodProInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaDtiAvaInit    �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDA_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDA_DTIAVA								�
�������������������������������������������������������������������������/*/
Function R270DtiAvaInit()

Local dRdaDtiAvaInit	:= Ctod("//")

Local nRd9DatIni
Local oGdRd9

IF ( Apda270Fldrs() )
	oGdRd9 := oGdRd9Get()
	IF ( ValType( oGdRd9 ) == "O" )
		IF ( ( nRd9DatIni := GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader ) ) > 0 )
			dRdaDtiAvaInit	:= oGdRd9:aCols[ oGdRd9:nAt , nRd9DatIni ]
		EndIF
	EndIF
EndIF

Return( dRdaDtiAvaInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaDtfAvaInit    �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDA_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDA_DTFAVA								�
�������������������������������������������������������������������������/*/
Function R270DtfAvaInit()

Local dRdaDtfAvaInit	:= Ctod("//")

Local nRd9DatFim
Local oGdRd9

IF ( Apda270Fldrs() )
	oGdRd9 := oGdRd9Get()
	IF ( ValType( oGdRd9 ) == "O" )
		IF ( ( nRd9DatFim := GdFieldPos( "RD9_DTFAVA" , oGdRd9:aHeader ) ) > 0 )
			dRdaDtfAvaInit	:= oGdRd9:aCols[ oGdRd9:nAt , nRd9DatFim ]
		EndIF
	EndIF
EndIF

Return( dRdaDtfAvaInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNomeInit		 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_NOME						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_NOME								�
�������������������������������������������������������������������������/*/
Function R270NomeInit()

Local cRdaNomeInit		:= ""
Local nOrder			:= RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" , .F. )

Local cRdaCodDor
Local lGetDados
Local nRdaNome
Local oGdRda

lGetDados := IsInGetDados( { "RDA_NOME" , "RDA_CODDOR" } )

IF ( lGetDados )
	cRdaCodDor		:= GetMemVar( "RDA_CODDOR" )
	cRdaNomeInit	:= PosAlias( "RD0" , cRdaCodDor , xFilial( "RD9" ) , "RD0_NOME" , nOrder , .F. )
	oGdRda			:= oGdRdaGet( APDA270_FOLDER_AVALIADORES )
	IF (;
			Apda270Fldrs();
			.and.;
			( ValType( oGdRda ) == "O" );
		)
		IF ( ( nRdaNome := GdFieldPos( "RDA_NOME" , oGdRda:aHeader ) ) > 0 )
			IF !( InAddLine( "APDA270/__EXECUTE/RUNAPP/SIGAAPD/" ) )
				oGdRda:aCols[ oGdRda:nAt , nRdaNome ] := cRdaNomeInit
			EndIF
		EndIF
	EndIF
Else
	cRdaNomeInit	:= PosAlias( "RD0" , RDA->RDA_CODDOR , xFilial( "RD9" ) , "RD0_NOME" , nOrder , .F. )
EndIF

Return( cRdaNomeInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodNetInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODNET					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODNET								�
�������������������������������������������������������������������������/*/
Function R270CodNetInit()

Local cRdaCodNet	:= Space( GetSx3Cache("RDA_CODNET","X3_TAMANHO" ) )

Local nRdhCodNet
Local oGdRdh

IF ( Apda270Fldrs() )
	oGdRdh	:= oGdRdhGet( APDA270_FOLDER_AVALIADORES )
 	IF ( ValType( oGdRdh ) == "O" )
 		IF ( ( nRdhCodNet := GdFieldPos( "RDH_CODNET" , oGdRdh:aHeader ) ) > 0 )
			cRdaCodNet	:= oGdRdh:aCols[ oGdRdh:nAt , nRdhCodNet ]
		EndIF
	EndIF
EndIF

Return( cRdaCodNet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNivelInit	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_NIVEL					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_NIVEL								�
�������������������������������������������������������������������������/*/
Function R270NivelInit()

Local cRdaNivelInit	:= Space( GetSx3Cache("RDA_NIVEL","X3_TAMANHO" ) )

Local nRdhNivel
Local oGdNivel

IF ( Apda270Fldrs() )
	oGdNivel	:= aFolders[ APDA270_FOLDER_AVALIADORES , APDA270_FOLDER_OBJECTS , 2 , APDA270_OBJ ]
 	IF ( ValType( oGdNivel ) == "O" )
 		IF ( ( nRdhNivel := GdFieldPos( "RDH_NIVEL" , oGdNivel:aHeader ) ) > 0 )
			cRdaNivelInit	:= oGdNivel:aCols[ oGdNivel:nAt , nRdhNivel ]
		EndIF
	EndIF
EndIF

Return( cRdaNivelInit )
/*
RdaCodDorInit
RDA_TIPOAV   RdaTipoAvInit
RdaCodTipInit

*/
/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �R9270NomeIni	 �Autor�Fabio Gimenez	  � Data �03/04/2014�
�����������������������������������������������������������������������Ĵ
�Descri��o �Copia da Funcao RD9NomeInit() para atender >= R7			�
�          �Inicializadora Padrao do Campo RD9_NOME						�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD9_NOME								�
�������������������������������������������������������������������������/*/
Function R9270NomeIni()

Local cR9270NomeIni	:= ""
Local nOrder		:= RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" , .F. )

Local cRd9CodAdo
Local lGetDados
Local nRd9Nome
Local oGdRd9

lGetDados := IsInGetDados( { "RD9_NOME" , "RD9_CODADO" } )

IF ( lGetDados )
	cRd9CodAdo		:= GetMemVar( "RD9_CODADO" )
	cR9270NomeIni	:= PosAlias( "RD0" , cRd9CodAdo , xFilial( "RD9" ) , "RD0_NOME" , nOrder , .F. )
	oGdRd9			:= oGdRd9Get( APDA270_FOLDER_AVALIADOS )
	IF ( Apda270Fldrs() .and. ( ValType( oGdRd9 ) == "O" ) 	)
		IF ( ( nRd9Nome := GdFieldPos( "RD9_NOME" , oGdRd9:aHeader ) ) > 0 )
			IF !( InAddLine( "APDA270/__EXECUTE/RUNAPP/SIGAAPD/" ) )
				oGdRd9:aCols[ oGdRd9:nAt , nRd9Nome ] := cR9270NomeIni
			EndIF
		EndIF
	EndIF
Else
	cR9270NomeIni	:= PosAlias( "RD0" , RD9->RD9_CODADO , xFilial( "RD9" ) , "RD0_NOME" , nOrder , .F. )
EndIF

Return( cR9270NomeIni )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �R270NomeBrw		 �Autor�Fabio Gimenez	  � Data �03/04/2014�
�����������������������������������������������������������������������Ĵ
�Descri��o �Copia da Funcao R270NomeBrw() para atender >= R7			�
�          �Inicializador Padrao do Browse para o Campo RD9_NOME		�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_INIBRW do campo RD9_NOME									�
�������������������������������������������������������������������������/*/
Function R270NomeBrw()
Return( R9270NomeIni() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RD9DtInicAva     �Autor�Fabio Gimenez	  � Data �03/04/2014�
�����������������������������������������������������������������������Ĵ
�Descri��o �Copia da Funcao RD9DtInicAva() para atender R7				�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD9_DTIAVA								�
�������������������������������������������������������������������������/*/
Function RD9DtInicAva()

Local dRd9DtInicAva := Ctod( "//" )
Local oGdRdp

IF ( Apda270Fldrs() )
	oGdRdp := oGdRdpGet()
	IF ( ValType( oGdRdp ) == "O" )
		dRd9DtInicAva := GdFieldGet( "RDP_DATINI" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )
	EndIF
EndIF

Return( dRd9DtInicAva )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9DtFimAva   	 �Autor�Fabio Gimenez	  � Data �03/04/2014�
�����������������������������������������������������������������������Ĵ
�Descri��o �Copia da Funcao Rd9DtfAvaInit() para atender R7				�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD9_DTFAVA								�
�������������������������������������������������������������������������/*/
Function Rd9DtFimAva()

Local dRd9DtFimAva := Ctod( "//" )
Local oGdRdp

IF ( Apda270Fldrs() )
	oGdRdp := oGdRdpGet()
	IF ( ValType( oGdRdp ) == "O" )
		dRd9DtFimAva := GdFieldGet( "RDP_DATFIM" , oGdRdp:oBrowse:nAt , .F. , oGdRdp:aHeader , oGdRdp:aCols )
	EndIF
EndIF

Return( dRd9DtFimAva )

/*/
��������������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RetUsrFilter� Autor �Marinaldo de Jesus   � Data �10/01/2003�
��������������������������������������������������������������������������Ĵ
�Descri��o �Retornar Filtro para consulta ao RD6                           �
��������������������������������������������������������������������������Ĵ
�Sintaxe   �Rd6RetUsrFilter()											   �
��������������������������������������������������������������������������Ĵ
�Parametros�                                         					   �
��������������������������������������������������������������������������Ĵ
�Retorno   �cKeyFilter -> Chave para Filtro do RD6						   �
��������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	       �
��������������������������������������������������������������������������Ĵ
�Uso       �Generica                                                       �
����������������������������������������������������������������������������/*/
Function Rd6RetUsrFilter()
Local aGrupos		:= UsrRetGrp( cUserName )
Local cKeyFilter	:= ""
Local cSpaceUsr		:= Space( GetSx3Cache( "RD6_IDUSUA" , "X3_TAMANHO" ) )
Local cSpaceGrp		:= Space( GetSx3Cache( "RD6_GRUUSU" , "X3_TAMANHO" ) )
Local cUser			:= RetCodUsr()
Local cGrupos		:= ""

/*/
������������������������������������������������������������������������Ŀ
� Monta a String com os Grupos do Usuario								 �
��������������������������������������������������������������������������/*/
aEval( aGrupos , { |x| ( cGrupos += ( x + "/" ) ) } )

/*/
������������������������������������������������������������������������Ŀ
� Monta o Filtro de Acordo com o Usuario para uso na FilBrowse           �
��������������������������������������������������������������������������/*/
cKeyFilter	:= "("
cKeyFilter	+= 		"("
cKeyFilter	+=				"RD6_IDUSUA $ '" +	cUser		+ "'"
cKeyFilter	+=				".and."
cKeyFilter	+=				"RD6_GRUUSU $ '" + cSpaceGrp	+ "'"
cKeyFilter	+= 		")"
cKeyFilter	+= 			".or."
cKeyFilter	+= 		"("
cKeyFilter	+= 				"RD6_IDUSUA $ '" + cSpaceUsr	+ "'"
cKeyFilter	+= 				".and."
cKeyFilter	+= 				"RD6_GRUUSU $ '" + cGrupos		+ "'"
cKeyFilter	+= 		")"
cKeyFilter	+= 			".or."
cKeyFilter	+= 		"("
cKeyFilter	+= 				"RD6_IDUSUA $ '" + cSpaceUsr	+ "'"
cKeyFilter	+=				".and."
cKeyFilter	+=				"RD6_GRUUSU $ '" + cSpaceGrp	+ "'"
cKeyFilter	+= 		")"
cKeyFilter	+= 			".or."
cKeyFilter	+= 		"("
cKeyFilter	+= 				"RD6_IDUSUA $ '" + cUser		+ "'"
cKeyFilter	+=				".and."
cKeyFilter	+= 				"RD6_GRUUSU $ '" + cGrupos		+ "'"
cKeyFilter	+= 		")"
cKeyFilter	+= ")"

Return( cKeyFilter )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodigoVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODIGO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODIGO								�
�������������������������������������������������������������������������/*/
Function Rd6CodigoVld()

Local cRD6Codigo	:= GetMemVar( "RD6_CODIGO" )
Local lRd6CodTipOk	:= .T.

Begin Sequence

	IF !( lRd6CodTipOk := Rd6GetCodigo( @cRD6Codigo , .F. , .T. ) )
    	Break
    EndIF

	SetMemVar( "RD6_CODIGO" , cRD6Codigo )

End Sequence

Return( lRd6CodTipOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6GetCodigo �Autor�Marinaldo de Jesus    � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem Numeracao Valida para o RD6_CODIGO                    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Obter Numeracao valida para o RD6_CODIGO                 	�
�������������������������������������������������������������������������/*/
Function Rd6GetCodigo( cRD6Codigo , lExistChav , lShowHelp )
Return(;
			GetNrExclOk(	@cRD6Codigo 			,;
							"RD6"					,;
							"RD6_CODIGO"			,;
							"RD6_FILIAL+RD6_CODIGO" ,;
							NIL						,;
							lExistChav				,;
							lShowHelp	 			 ;
						);
		)

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodigoInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD6_CODIGO					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_CODIGO								�
�������������������������������������������������������������������������/*/
Function Rd6CodigoInit()
Local cRD6Codigo
Rd6GetCodigo( @cRD6Codigo , .F. , .F. )
Return( cRD6Codigo )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DescriVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_DESC									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_DESC									�
�������������������������������������������������������������������������/*/
Function Rd6DescriVld()
Return( NaoVazio() .and. Texto() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodTipVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODTIP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODTIP								�
�������������������������������������������������������������������������/*/
Function Rd6CodTipVld()
Return( NaoVazio() .and. ExistCpo( "RD5" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodVisVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODVIS									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODVIS								�
�������������������������������������������������������������������������/*/
Function Rd6CodVisVld()

Local lRd6CodVisVld

Begin Sequence

	IF !( lRd6CodVisVld := NaoVazio() )
		Break
	EndIF

	IF !( lRd6CodVisVld := ExistCpo( "RD4" ) )
		Break
	EndIF

End Sequence

Return( lRd6CodVisVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodModVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODMOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODMOD								�
�������������������������������������������������������������������������/*/
Function Rd6CodModVld()

Local cReadVar		:= &( ReadVar() )
Local lRd6CodModVld := .T.
Local nRd3Order		:= RD3->( IndexOrd() )

Begin Sequence

	IF !( lRd6CodModVld := NaoVazio() )
		Break
	EndIF

	IF !( lRd6CodModVld := ExistCpo( "RD3" ) )
		Break
	EndIF

	RD3->( dbSetOrder( RetOrdem( "RD3" , "RD3_FILIAL+RD3_CODIGO" ) ) )
	IF RD3->( MsSeek( xFilial( "RD3" ) + cReadVar , .F. ) )
		SetMemVar( "RD6_CODCOM" , RD3->RD3_CODCOM )
	EndIF

End Sequence

RD3->( dbSetOrder( nRd3Order ) )

Return( lRd6CodModVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodComVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODCOM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODCOM								�
�������������������������������������������������������������������������/*/
Function Rd6CodComVld()

Local lRd6CodComOk := .T.

Begin Sequence
	IF !( lRd6CodComOk := NaoVazio() )
		Break
	EndIF
	IF !( lRd6CodComOk := ExistCpo( "RDM" ) )
		Break
	EndIF
End Sequence

Return( lRd6CodComOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtIniVld		 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_DTINI									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_DTINI									�
�������������������������������������������������������������������������/*/
Function Rd6DtIniVld()

Local lRd6DtIniVld

Begin Sequence

	IF !( lRd6DtIniVld := Rd6DateValid() )
		Break
	EndIF

End Sequence

Return( lRd6DtIniVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtIniWhen	 �Autor�Marinaldo de Jesus� Data �15/10/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �When para o Campo RD6_DTINI									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do campo RD6_DTINI									�
�������������������������������������������������������������������������/*/
Function Rd6DtIniWhen( lShowMsg )

Local lRd6DtIniWhen := .T.

Local dRd6DtIni

Begin Sequence

	IF !( "RD6_DTINI" $ Upper( ReadVar() ) )
		Break
	EndIF

	dRd6DtIni := GetMemVar( "RD6_DTINI" )
	IF Empty( dRd6DtIni )
		Break
	EndIF

	lRd6DtIniWhen		:= Rd6DtChkEnv( "RD6_DTINI" , dRd6DtIni )
	DEFAULT lShowMsg	:= .F.
	IF (;
			( lShowMsg );
		 	.and.;
			!( lRd6DtIniWhen );
		)
		cMsgInfo := STR0137 //"O Campo:"
		cMsgInfo += " "
		cMsgInfo += AllTrim( PosAlias( "SX3" , "RD6_DTINI" , NIL , "X3Titulo()" , 2 , .F. ) )
		cMsgInfo += " "
		cMsgInfo += STR0138	//"n�o pode ser alterado."
		cMsgInfo += CRLF
		cMsgInfo += STR0140	//"Existem Avalia��es anteriores a esta Data"
		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) ) //"Aviso de Inconsist�ncia!"
	EndIF

End Sequence

Return( lRd6DtIniWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtFimVld		 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_DTFIM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_DTFIM									�
�������������������������������������������������������������������������/*/
Function Rd6DtFimVld()

Local lRd6DtFimVld

Begin Sequence

	IF !( lRd6DtFimVld := Rd6DateValid() )
		Break
	EndIF

	IF !( lRd6DtFimVld := Rd6DtFimWhen( .T. ) )
		Break
	EndIF

End Sequence

Return( lRd6DtFimVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtFimWhen	 �Autor�Marinaldo de Jesus� Data �15/10/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �When para o Campo RD6_DTFIM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do campo RD6_DTFIM									�
�������������������������������������������������������������������������/*/
Function Rd6DtFimWhen( lShowMsg )

Local lRd6DtFimWhen := .T.

Local dRd6DtFim

Begin Sequence

	IF !( "RD6_DTFIM" $ Upper( ReadVar() ) )
		Break
	EndIF

	dRd6DtFim := GetMemVar( "RD6_DTFIM" )
	IF Empty( dRd6DtFim )
		Break
	EndIF

	lRd6DtFimWhen		:= Rd6DtChkEnv( "RD6_DTFIM" , dRd6DtFim )
	DEFAULT lShowMsg	:= .F.
	IF (;
			( lShowMsg );
		 	.and.;
		  	!( lRd6DtFimWhen );
		)
		cMsgInfo := STR0137 //"O Campo:"
		cMsgInfo += " "
		cMsgInfo += AllTrim( PosAlias( "SX3" , "RD6_DTFIM" , NIL , "X3Titulo()" , 2 , .F. ) )
		cMsgInfo += " "
		cMsgInfo += STR0138	//"n�o pode ser alterado."
		cMsgInfo += CRLF
		cMsgInfo += STR0139	//"Existem Avalia��es anteriores a esta Data"
		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) ) //"Aviso de Inconsist�ncia!"
	EndIF

End Sequence

Return( lRd6DtFimWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtChkEnv		 �Autor�Marinaldo de Jesus� Data �14/10/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se ja Existem Avaliacoes para o Periodo			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID dos campo RD6_DTINI e RD6_DTFIM					�
�������������������������������������������������������������������������/*/
Function Rd6DtChkEnv( cCpoVld , dDataChk )

Local aArea			:= GetArea()
Local aAreaRDC		:= RDC->( GetArea() )
Local aRdcHeader	:= {}
Local aRdcCols		:= {}
Local aRdcQuery		:= {}
Local aRdcFields	:= { "RDC_FILIAL" , "RDC_CODAVA" , IF( ( cCpoVld == "RD6_DTINI" ) , "RDC_DTIAVA" , "RDC_DTFAVA" ) }

Local bRdcAsc		:= { || NIL }

Local cRdcFilial	:= xFilial( "RDC" )
Local cRd6CodAva	:= IF( IsMemVar( "RD6_CODIGO" ) , GetMemVar( "RD6_CODIGO" ) , RD6->RD6_CODIGO )
Local cRdcKeySeek	:= ( cRdcFilial + cRd6CodAva )

Local lRd6ChkEnvA	:= .T.

Local nRdcOrder
Local nRdcDtIni
Local nRdcDtFim

CursorWait()

	Begin Sequence

		#IFDEF TOP

			aRdcQuery		:= Array( 07 )
			aRdcQuery[01]	:= "RDC_FILIAL='"+cRdcFilial+"'"
			aRdcQuery[02]	:= " AND "
			aRdcQuery[03]	:= "RDC_CODAVA='"+cRd6CodAva+"'"
			aRdcQuery[04]	:= " AND "
			IF ( cCpoVld == "RD6_DTINI" )
				aRdcQuery[05]	:= "RDC_DTIAVA<='"+Dtos( dDataChk )+"'"
			ElseIF ( cCpoVld == "RD6_DTFIM" )
				aRdcQuery[05]	:= "RDC_DTFAVA>'"+Dtos( dDataChk )+"'"
			EndIF
			aRdcQuery[06]	:= " AND "
			aRdcQuery[07]	:= "D_E_L_E_T_=' ' "

		#ENDIF

		nRdcOrder := RetOrdem( "RDC" , "RDC_FILIAL+RDC_CODAVA+DTOS(" + IF( ( cCpoVld == "RD6_DTINI" ) , "RDC_DTIAVA" , "RDC_DTFAVA" ) + ")" )
		RDC->( dbSetOrder( nRdcOrder ) )
		aRdcCols := GDBuildCols(	@aRdcHeader	,;	//01 -> Array com os Campos do Cabecalho da GetDados
									NIL			,;	//02 -> Numero de Campos em Uso
									NIL			,;	//03 -> [@]Array com os Campos Virtuais
									NIL			,;	//04 -> [@]Array com os Campos Visuais
									"RDC"		,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
									aRdcFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
									NIL			,;	//07 -> [@]Array unidimensional contendo os Recnos
									"RDC"		,;	//08 -> Alias do Arquivo Pai
									cRdcKeySeek	,;	//09 -> Chave para o Posicionamento no Alias Filho
									NIL			,;	//10 -> Bloco para condicao de Loop While
									NIL			,;	//11 -> Bloco para Skip no Loop While
									.F.			,;	//12 -> Se Havera o Elemento de Delecao no aCols
									.F.			,;	//13 -> Se Sera considerado o Inicializador Padrao
									.F.			,;	//14 -> Opcional, Carregar Todos os Campos
									.T.		 	,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
									aRdcQuery	,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
									.F.			,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
									.F.			,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
									.F.			,;	//19 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
									.T.			,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									.F.			,;	//21 -> Verifica se Deve Checar se o campo eh usado
									.F.			,;	//22 -> Verifica se Deve Checar o nivel do usuario
									.F.			,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									NIL			,;	//24 -> [@]Array que contera as chaves conforme recnos
									.F.			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
									.F.			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
									NIL			,;	//27 -> Numero maximo de Locks a ser efetuado
									.F.			,;	//28 -> Utiliza Numeracao na GhostCol
									.T.			,;	//29 -> Carrega os Campos de Usuario
									NIL			,;	//30 ->
									NIL			;	//31 ->
						)

		IF Empty( aRdcCols )
			Break
		EndIF

		#IFDEF TOP

			lRd6ChkEnvA := .F.

			Break

		#ELSE

			IF ( cCpoVld == "RD6_DTINI" )
				nRdcDtIni	:= GdFieldPos( "RDC_DTIAVA" , aRdcHeader )
				bRdcAsc		:= { |e| ( e[ nRdcDtIni ] <= dDataChk ) }
			ElseIF ( cCpoVld == "RD6_DTFIM" )
				nRdcDtFim	:= GdFieldPos( "RDC_DTFAVA" , aRdcHeader )
				bRdcAsc		:= { |e| ( e[ nRdcDtFim ] > dDataChk ) }
			EndIF

			lRd6ChkEnvA := ( aScan( aRdcCols , bRdcAsc ) == 0 )

		#ENDIF

	End Sequence

	RestArea( aAreaRDC )
	RestArea( aArea )

CursorArrow()

Return( lRd6ChkEnvA )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodVld 	 �Autor�Marinaldo de Jesus� Data �30/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_PERIOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RD6_PERIOD								�
�������������������������������������������������������������������������/*/
Function Rd6PeriodVld()

Local lRd6PeriodOK := .T.

Begin Sequence

	IF !( lRd6PeriodOK := NaoVazio() )
		Break
	EndIF

	IF !( lRd6PeriodOK := Pertence( OpBxPeriod( .T. ) ) )
		Break
	EndIF

End Sequence

valRd6Exit( )

Return( lRd6PeriodOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodInit 	 �Autor�Marinaldo de Jesus� Data �30/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD6_PERIOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD6_PERIOD								�
�������������������������������������������������������������������������/*/
Function Rd6PeriodInit()
Return( SubStr( OpBxPeriod( .T. ) , 1 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodBox 	 �Autor�Marinaldo de Jesus� Data �30/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �OpcBox do Campo RD6_PERIOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RD6_PERIOD									�
�������������������������������������������������������������������������/*/
Function Rd6PeriodBox()
Return( OpBxPeriod( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IntMesVld 	 �Autor�Marinaldo de Jesus� Data �30/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_INTMES									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RD6_INTMES								�
�������������������������������������������������������������������������/*/
Function Rd6IntMesVld()

Local lRd6IntMesOK := .T.
Local nRd6IntMesVld

Begin Sequence

	IF !( Rd6PeriodM() )
		Break
	EndIF

	IF !( lRd6IntMesOK := NaoVazio() )
		Break
	EndIF

	IF !( lRd6IntMesOK := Positivo() )
		Break
	EndIF

	nRd6IntMesVld := GetMemVar( "RD6_INTMES" )
	IF !( lRd6IntMesOK := ( ( nRd6IntMesVld >= 1 ) .and. ( nRd6IntMesVld <= 12 ) ) )
		//"N�mero de meses Inv�lido. Informe um valor no intervalo entre 1 a 12."
		//"Aviso de Inconsist�ncia!"
		MsgInfo( OemToAnsi( STR0102 ) , OemToAnsi( STR0022 ) )
		Break
	EndIF

End Sequence

Return( lRd6IntMesOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IntMesInit 	 �Autor�Marinaldo de Jesus� Data �30/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD6_INTMES									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD6_INTMES								�
�������������������������������������������������������������������������/*/
Function Rd6IntMesInit()
Return( 1 )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IntMesWhen 	 �Autor�Marinaldo de Jesus� Data �30/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �When do Campo RD6_INTMES									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do Campo RD6_INTMES									�
�������������������������������������������������������������������������/*/
Function Rd6IntMesWhen()

Local lRd6IntMesWhen := .T.

Begin Sequence

	IF !( Upper( AllTrim( ReadVar() ) ) == "M->RD6_INTMES" )
		Break
	EndIF

	lRd6IntMesWhen := Rd6PeriodM()

End Sequence

Return( lRd6IntMesWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodD	 	 �Autor�Marinaldo de Jesus� Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Conteudo do campo RD6_PERIOD eh Diario		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA080                   									�
�������������������������������������������������������������������������/*/
Static Function Rd6PeriodD()

Local cRd6Period := ""

IF ( IsInGetDados( { "RD6_PERIOD" } ) )
	cRd6Period	:= GdFieldGet( "RD6_PERIOD" )
ElseIF ( IsMemVar( "RD6_PERIOD" ) )
	cRd6Period	:= GetMemVar( "RD6_PERIOD" )
EndIF

Return( ( cRd6Period == SubStr( OpBxPeriod( .T. ) , 1 , 1 ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodS	 	 �Autor�Marinaldo de Jesus� Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Conteudo do campo RD6_PERIOD eh Semanal		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA080                   									�
�������������������������������������������������������������������������/*/
Static Function Rd6PeriodS()

Local cRd6Period := ""

IF ( IsInGetDados( { "RD6_PERIOD" } ) )
	cRd6Period	:= GdFieldGet( "RD6_PERIOD" )
ElseIF ( IsMemVar( "RD6_PERIOD" ) )
	cRd6Period	:= GetMemVar( "RD6_PERIOD" )
EndIF

Return( ( cRd6Period == SubStr( OpBxPeriod( .T. ) , 2 , 1 ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodQ	 	 �Autor�Marinaldo de Jesus� Data �01/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Conteudo do campo RD6_PERIOD eh Quinzenal		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA080                   									�
�������������������������������������������������������������������������/*/
Static Function Rd6PeriodQ()

Local cRd6Period := ""

IF ( IsInGetDados( { "RD6_PERIOD" } ) )
	cRd6Period	:= GdFieldGet( "RD6_PERIOD" )
ElseIF ( IsMemVar( "RD6_PERIOD" ) )
	cRd6Period	:= GetMemVar( "RD6_PERIOD" )
EndIF

Return( ( cRd6Period == SubStr( OpBxPeriod( .T. ) , 3 , 1 ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6PeriodM	 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Conteudo do campo RD6_PERIOD eh Mensal		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA080                   									�
�������������������������������������������������������������������������/*/
Static Function Rd6PeriodM()

Local cRd6Period := ""

IF ( IsInGetDados( { "RD6_PERIOD" } ) )
	cRd6Period	:= GdFieldGet( "RD6_PERIOD" )
ElseIF ( IsMemVar( "RD6_PERIOD" ) )
	cRd6Period	:= GetMemVar( "RD6_PERIOD" )
EndIF

Return( ( cRd6Period == SubStr( OpBxPeriod( .T. ) , 4 , 1 ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtCalcVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_DTCALC									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_DTCALC								�
�������������������������������������������������������������������������/*/
Function Rd6DtCalcVld()
Return( Rd6DateValid() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IniGerVld	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_INIGER									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_INIGER								�
�������������������������������������������������������������������������/*/
Function Rd6IniGerVld()

Local lRd6IniGerOK := .T.

Begin Sequence

	IF !( lRd6IniGerOK := Positivo() )
		Break
	EndIF

End Sequence

Return( lRd6IniGerOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IniRspVld	 �Autor�Marinaldo de Jesus� Data �06/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_INIRSP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_INIGER								�
�������������������������������������������������������������������������/*/
Function Rd6IniRspVld()

Local lRd6IniRspOk := .T.

Begin Sequence

	IF !( lRd6IniRspOk := Positivo() )
		Break
	EndIF

End Sequence

Return( lRd6IniRspOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6StatusVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_STATUS									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_STATUS								�
�������������������������������������������������������������������������/*/
Function Rd6StatusVld()
Return( Pertence( OpBxStatus( .T. ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6StatusBox �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_STATUS         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RD6_STATUS                         	�
�������������������������������������������������������������������������/*/
Function Rd6StatusBox()
Return( OpBxStatus( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6StatusInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD6_STATUS					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_STATUS								�
�������������������������������������������������������������������������/*/
Function Rd6StatusInit()
Return( SubStr( OpBxStatus( .T. ) , 1 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6GruUsuVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_GRUUSU									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_GRUUSU								�
�������������������������������������������������������������������������/*/
Function Rd6GruUsuVld()

Local lRd6GruUsuOk	:= .T.

Begin Sequence

	IF Empty( GetMemVar( "RD6_GRUUSU" ) )
		Break
	EndIF

	PswOrder( 01 )
	IF !( lRd6GruUsuOk := PswSeek( GetMemVar( "RD6_GRUUSU" ) , .F. ) )
		MsgInfo( OemToansi( STR0069 ) /*'Grupo de Usu�rios inv�lido'*/ , OemToAnsi( STR0022 ) /*'Aviso de Inconsist�ncia!*/ )
		Break
	EndIF

End Sequence

Return( lRd6GruUsuOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IdUsuaVld	 �Autor�Marinaldo de Jesus� Data �12/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_IDUSUA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_IDUSUA								�
�������������������������������������������������������������������������/*/
Function Rd6IdUsuaVld()

Local lRd6IdUsuaOk := .T.

Begin Sequence

	IF Empty( GetMemVar( "RD6_IDUSUA" ) )
		Break
	EndIF

	lRd6IdUsuaOk := UsrExist( GetMemVar( "RD6_IDUSUA" ) )

End Sequence

Return( lRd6IdUsuaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodCabVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODCAB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODCAB								�
�������������������������������������������������������������������������/*/
Function Rd6CodCabVld()

Local lRd6CodCabOk := .T.

lRd6CodCabOk := ( Vazio() .or. ExistCpo( "RDG" ) )

Return( lRd6CodCabOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodRodVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_CODROD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_CODROD								�
�������������������������������������������������������������������������/*/
Function Rd6CodRodVld()

Local lRd6CodRodOk := .T.

lRd6CodRodOk := ( Vazio() .or. ExistCpo( "RDG" ) )

Return( lRd6CodRodOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DiaSemVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RD6_DIASSEM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD6_DIASSEM								�
�������������������������������������������������������������������������/*/
Function Rd6DiaSemVld()
Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DateValid    �Autor�Marinaldo de Jesus � Data �04/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar as Datas no RD6                  					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Validacao do SX3 para os campos RD6_DTINI, RD6_DTFIM e  RD6_�
�          �DTCALC														�
�������������������������������������������������������������������������/*/
Function Rd6DateValid()

Local cVar		:= Upper( AllTrim( ReadVar() ) )
Local cMsgInfo		:= ""
Local lDateOk	:= .T.

Begin Sequence

	IF ( "RD6_DTINI" $ cVar )
		IF !( lDateOk := NaoVazio() )
			Break
		EndIF
		IF ( !Empty( GetMemVar( "RD6_DTFIM" ) ) )
			IF !( lDateOk := ( GetMemVar( "RD6_DTINI" ) <= GetMemVar( "RD6_DTFIM" ) ) )
				cMsgInfo := ( STR0094 + " " + STR0095 ) //"Data Nao Pode Ser Vazia ou"###"Maior que Data Final."
				Break
			EndIF
		EndIF
	ElseIF ( "RD6_DTFIM" $ cVar )
		IF !( lDateOk := NaoVazio() )
			Break
		EndIF
		IF ( !Empty( GetMemVar( "RD6_DTINI" ) ) )
			IF !( lDateOk := ( GetMemVar( "RD6_DTFIM" ) >= GetMemVar( "RD6_DTINI" ) ) )
				cMsgInfo := ( STR0094 + " " + STR0096 ) //"Data Nao Pode Ser Vazia ou"###"Menor que Data Inicial."
				Break
			EndIF
		EndIF
	ElseIF ( "RD6_DTCALC" $ cVar )
		IF !( Vazio() )
			IF ( !Empty( GetMemVar( "RD6_DTFIM" ) ) )
				IF !( lDateOk := ( GetMemVar( "RD6_DTCALC" ) >= GetMemVar( "RD6_DTINI" ) ) )
					cMsgInfo := ( STR0097 ) //"Data de Calculo Menor que Data Inicial"
					Break
				EndIF
			EndIF
		EndIF
	EndIF

End Sequence

IF !( lDateOk )
	IF !( Empty( cMsgInfo ) )
		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0098 ) )	//"Data Inv�lida"
	EndIF
EndIF

Return( lDateOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtIniInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD6_DTINI					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_DTINI								�
�������������������������������������������������������������������������/*/
Function Rd6DtIniInit()
Return( SetMemVar( "RD6_DTINI" , Ctod("//") ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtFimInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD6_DTFIM					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_DTFIM								�
�������������������������������������������������������������������������/*/
Function Rd6DtFimInit()
Return( SetMemVar( "RD6_DTFIM" , Ctod("//") ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DtCalcInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD6_DTCALC					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_DTCALC								�
�������������������������������������������������������������������������/*/
Function Rd6DtCalcInit()
Return( SetMemVar( "RD6_DTCALC" , Ctod("//") ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6GruUsuInit	 �Autor�Marinaldo de Jesus� Data �11/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializador Padrao do Campo RD6_GRUUSU					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_GRUUSU								�
�������������������������������������������������������������������������/*/
Function Rd6GruUsuInit()
Return( SetMemVar( "RD6_GRUUSU" , Space( GetSx3Cache( "RD6_GRUUSU" , "X3_TAMANHO" ) ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6IdUsuaInit	 �Autor�Marinaldo de Jesus� Data �12/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializador Padrao do Campo RD6_IDUSUA					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_IDUSUA								�
�������������������������������������������������������������������������/*/
Function Rd6IdUsuaInit()
Return( SetMemVar( "RD6_IDUSUA" , Space( GetSx3Cache( "RD6_IDUSUA" , "X3_TAMANHO" ) ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6DescVld	     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_DESC										�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_DESC										�
�������������������������������������������������������������������������/*/
Function Rd6DescVld()

Local lRd6DescOk := .T.

Begin Sequence

	IF !( lRd6DescOk := NaoVazio() )
		Break
	EndIF

	IF !( lRd6DescOk := Texto() )
		Break
	EndIF

End Sequence

Return( lRd6DescOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CodRspVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_CODRSP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_CODRSP									�
�������������������������������������������������������������������������/*/
Function Rd6CodRspVld()

Local lRd6CodRspOk := .T.

Begin Sequence

	IF ( Vazio() )
		Break
	EndIF

	IF !( lRd6CodRspOk := ExistCpo( "RD0" ) )
		Break
	EndIF

	SetMemVar( "RD6_NOMRSP" , Rd6NomRspInit( &( ReadVar() ) ) )

End Sequence

Return( lRd6CodRspOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6NomRspVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_CODRSP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_CODRSP									�
�������������������������������������������������������������������������/*/
Function Rd6NomRspVld()

Local lRd6NomRspOk := .T.

Return( lRd6NomRspOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6NomRspInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD6_NOMRSP					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD6_NOMRSP								�
�������������������������������������������������������������������������/*/
Function Rd6NomRspInit( cCodigo )

Local nOrder := RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" , .F. )

DEFAULT cCodigo := RD6->RD6_CODRSP

Return( PosAlias( "RD0" , cCodigo , xFilial( "RD6" ) , "RD0_NOME" , nOrder , .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6AutoAvVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_AUTOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_AUTOAV									�
�������������������������������������������������������������������������/*/
Function Rd6AutoAvVld()

Local lRd6AutoAvOk := .T.

Begin Sequence

	IF !( lRd6AutoAvOk := Pertence( OpBxSimNao( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRd6AutoAvOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6AutoAvBox �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_AUTOAV         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RD6_AUTOAV                         	�
�������������������������������������������������������������������������/*/
Function Rd6AutoAvBox()
Return( OpBxSimNao( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6AutoAvInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_AUTOAV         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RD6_AUTOAV                         	�
�������������������������������������������������������������������������/*/
Function Rd6AutoAvInit()
Return( SubStr( OpBxSimNao( .T. ) , 2 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6SimultVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_SIMULT									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_SIMULT									�
�������������������������������������������������������������������������/*/
Function Rd6SimultVld()

Local lRd6SimultOk := .T.

Begin Sequence

	IF !( lRd6SimultOk := Pertence( OpBxSimNao( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRd6SimultOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6SimultBox �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_SIMULT         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RD6_SIMULT                         	�
�������������������������������������������������������������������������/*/
Function Rd6SimultBox()
Return( OpBxSimNao( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6SimultInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_SIMULT         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RD6_SIMULT                         	�
�������������������������������������������������������������������������/*/
Function Rd6SimultInit()
Return( SubStr( OpBxSimNao( .T. ) , 2 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6MontagVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_MONTAG									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_MONTAG									�
�������������������������������������������������������������������������/*/
Function Rd6MontagVld()

	Local lRd6MontagOk := .T.

	Begin Sequence

		IF !( lRd6MontagOk := Pertence( Rd6MontagBox( .T. ) ) )
			Break
		EndIF

		IF lRd6MontagOk .And. GetMemVar("RD6_MONTAG") == "3" .And. GetMemVar("RD6_AUTOAV") != "1"
			// "INCONSISTENCIA" ## "Quando a Montagem for Autom�tica, o valor do campo " ## " deve ser 1 - Sim."
			Help("" , 1, OemToAnsi(STR0171), Nil, + CRLF + OemToAnsi(STR0169) + AllTrim(FWX3Titulo("RD6_AUTOAV")) + OemToAnsi(STR0170), 1 , 0)
			lRd6MontagOk := .F.
			Break
		EndIF

	End Sequence

Return lRd6MontagOk

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6MontagBox �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_MONTAG         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RD6_MONTAG                         	�
�������������������������������������������������������������������������/*/
Function Rd6MontagBox( lValid , lRetDesc , cOpcDesc )

Local cOpcBox

DEFAULT lValid		:= .F.
DEFAULT lRetDesc	:= .F.

IF !( lValid )

	IF !( lRetDesc )

		cOpcBox := ( "1=" + STR0047 + ";" )	//"Manual"
		cOpcBox += ( "2=" + STR0048 + ";" )	//"Semi-Automatica"
		cOpcBox += ( "3=" + STR0049       )	//"Automatica"

	Else

		Do Case
			Case ( cOpcDesc == "1" ) ; ( cOpcBox := STR0047 )	//"Manual"
			Case ( cOpcDesc == "2" ) ; ( cOpcBox := STR0048 )	//"Semi-Automatica"
			Case ( cOpcDesc == "3" ) ; ( cOpcBox := STR0049 )	//"Automatica"
		End Case

	EndIF

Else

	cOpcBox := "123"

EndIF

Return( cOpcBox )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6MontagInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RD6_MONTAG         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RD6_MONTAG                         	�
�������������������������������������������������������������������������/*/
Function Rd6MontagInit()
Return( SubStr( Rd6MontagBox( .T. ) , 1 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6CriterVld     �Autor�Marinaldo de Jesus� Data �15/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_CRITER									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD6_CRITER									�
�������������������������������������������������������������������������/*/
Function Rd6CriterVld()

Local lRd6CriterVld := .T.

Begin Sequence

	IF ( GetMemVar( "RD6_MONTAG" ) == "1" )
		IF !( lRd6CriterVld := Vazio() )
			//"Este campo dever� ser preenchido apenas quando a Montagem for Autom�tica ou Semi-Autom�tica"
			Help( "" , 1 , OemToAnsi(STR0171) , NIL , OemToAnsi(STR0093) , 1 , 0 )
			Break
		Else
			Break
		EndIF
		lRd6CriterVld := ExistCpo( "RDS" )
	Else
		IF ( Vazio() )
		lRd6CriterVld := .F.
			//"Este campo dever� ser preenchido quando a Montagem for Autom�tica ou Semi-Autom�tica"
			Help( "" , 1 , OemToAnsi(STR0171) , NIL , OemToAnsi(STR0093) , 1 , 0 )
			Break
		Else
			Break
		EndIF
	EndIF



End Sequence

Return( lRd6CriterVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RspAdoVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_RSPADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RD6_RSPADO								�
�������������������������������������������������������������������������/*/
Function Rd6RspAdoVld()

Local lRd6RspAdoOk := .T.

Begin Sequence

	IF !( lRd6RspAdoOk := Positivo() )
		Break
	EndIF

End Sequence

Return( lRd6RspAdoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RspAdoInit 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD6_RSPADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD6_RSPADO								�
�������������������������������������������������������������������������/*/
Function Rd6RspAdoInit()
Return( 0 )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RspDorVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_RSPDOR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RD6_RSPDOR								�
�������������������������������������������������������������������������/*/
Function Rd6RspDorVld()

Local lRd6RspDorOk := .T.

Begin Sequence

	IF !( lRd6RspDorOk := Positivo() )
		Break
	EndIF

End Sequence

Return( lRd6RspDorOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RspDorInit 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD6_RSPDOR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD6_RSPDOR								�
�������������������������������������������������������������������������/*/
Function Rd6RspDorInit()
Return( 0 )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RspConVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_RSPCON									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RD6_RSPCON								�
�������������������������������������������������������������������������/*/
Function Rd6RspConVld()

Local lRd6RspConOk := .T.

Begin Sequence

	IF !( lRd6RspConOk := Positivo() )
		Break
	EndIF

End Sequence

Return( lRd6RspConOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd6RspConInit	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD6_RSPCON									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD6_RSPCON								�
�������������������������������������������������������������������������/*/
Function Rd6RspConInit()
Return( 0 )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpCodAvaVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_CODAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_CODAVA								�
�������������������������������������������������������������������������/*/
Function RdpCodAvaVld()

Local lRdpCodAvaOK := .T.

Begin Sequence

	IF !( lRdpCodAvaOK := NaoVazio() )
		Break
	EndIF

	IF !( lRdpCodAvaOK := ExistCpo( "RD6" ) )
		Break
	EndIF

End Sequence

Return( lRdpCodAvaOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpCodAvaInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDP_CODAVA					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDP_CODAVA								�
�������������������������������������������������������������������������/*/
Function RdpCodAvaInit()
Local cRdpCodAvaInit := IF(IsMemVar("RD6_CODIGO"),GetMemVar( "RD6_CODIGO" ),Space(GetSx3Cache("RDP_CODAVA","X3_TAMANHO")))
Return( SetMemVar( "RDP_CODAVA" , cRdpCodAvaInit ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatIniVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_DATINI									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_DATINI								�
�������������������������������������������������������������������������/*/
Function RdpDatIniVld()

Local lRdpDatIniOK := .T.

Local aRd9Cols
Local aRd9Header
Local aRdaCols
Local aRdaHeader

Local lGetDados

Local dRd6DtIni
Local dRd6DtFim
Local dRdpDatIni
Local dRdpDatFim
Local dLstRdpDatIni

Local nRdpDatIni
Local nRdpDelete
Local nRd9DtIAva
Local nRdaDtIAva

Local oGdRd9
Local oGdRda

Begin Sequence

	IF !( lRdpDatIniOK := NaoVazio() )
		Break
	EndIF

	IF !( IsMemVar( "RD6_DTINI" ) .and. IsMemVar( "RD6_DTFIM" ) )
		Break
	EndIF
	dRd6DtIni	:= GetMemVar( "RD6_DTINI"  )
	dRd6DtFim	:= GetMemVar( "RD6_DTFIM"  )

	lGetDados := IsInGetDados( { "RDP_DATINI" , "RDP_DATFIM" } )

	/*
	��������������������������������������������������������������Ŀ
	� Verifica Se RDP_DATINI esta dentro do Periodo da Avaliacao   �
	����������������������������������������������������������������*/
	IF ( lGetDados )
		dRdpDatFim		:= GdFieldGet( "RDP_DATFIM" )
		dLstRdpDatIni	:= GdFieldGet( "RDP_DATINI" )
		nRdpDatIni		:= GdFieldPos( "RDP_DATINI" )
		nRdpDelete		:= GdFieldPos( "GDDELETED"  )
	Else
		dRdpDatFim := GetMemVar( "RDP_DATFIM" )
	EndIF
	dRdpDatIni	:= GetMemVar( "RDP_DATINI" )

	/*
	��������������������������������������������������������������Ŀ
	� Data Inicial Nao Podera ser Maior que Data Final             �
	����������������������������������������������������������������*/
	IF !Empty( dRdpDatFim )
		IF !( lRdpDatIniOK := ( dRdpDatIni <= dRdpDatFim ) )
			//"Data Nao Pode Ser Vazia ou"###"Maior que Data Final."
			MsgInfo( ( STR0094 + " " + STR0095 ) , OemToAnsi( STR0098 ) ) //"Data Inv�lida"
			Break
		EndIF
	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Data Inicial Devera Estar No Periodo da Avaliacao            �
	����������������������������������������������������������������*/
	IF !( lRdpDatIniOK := ( ( dRdpDatIni >= dRd6DtIni ) .and. ( dRdpDatIni <= dRd6DtFim ) ) )
		cMsgInfo	:= STR0120	//"O conte�do do campo"
		cMsgInfo	+= " "
		cMsgInfo	+= aHeader[ GdFieldPos( "RDP_DATINI" ) , 01 ]
		cMsgInfo	+= " "
		cMsgInfo	+= STR0121	//"deve estar dentro do per�odo definido para a Avalia��o."
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
   		cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
		cMsgInfo 	+= CRLF
		cMsgInfo 	+= CRLF
   		cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia!'
    	Break
	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Se ocorreu Alteracao na Data Inicial, Altera o RD9 e RDA     �
	����������������������������������������������������������������*/
	MyCursorWait()
		IF (;
				!Empty( dLstRdpDatIni );
				.and.;
				( dLstRdpDatIni <> dRdpDatIni );
				.and.;
				Apda080Fldrs();
			)
			IF ( ( nRdpDatIni > 0 ) .and. ( nRdpDelete > 0 ) )
				IF ( aScan( aCols , { |x,y| (;
												( x[ nRdpDatIni ] == dLstRdpDatIni );
												.and.;
												( y <> n );
												.and.;
												!( x[ nRdpDelete ] );
											);
									 };
						  ) > 0;
				   )
					MyCursorArrow()
					Break
				EndIF
			EndIF
			aRd9Header	:= Rd9HeaderGet()
			IF ( ( nRd9DtIAva := GdFieldPos( "RD9_DTIAVA" , aRd9Header ) ) > 0 )
				aRd9Cols := Rd9ColsGet()
				aEval( aRd9Cols , { |aElem| aElem[ nRd9DtIAva ] := dRdpDatIni } )
			EndIF
			oGdRd9 := oGdRd9Get()
			IF ( ( nRd9DtIAva := GdFieldPos( "RD9_DTIAVA" , oGdRd9:aHeader ) ) > 0 )
				aEval( oGdRd9:aCols , { |aElem| aElem[ nRd9DtIAva ] := dRdpDatIni } )
			EndIF
			aRdaHeader := RdaHeaderGet()
			IF ( ( nRdaDtIAva := GdFieldPos( "RDA_DTIAVA" , aRdaHeader ) ) > 0 )
				aRdaCols := RdaColsGet()
				aEval( aRdaCols , { |aElem| aElem[ nRdaDtIAva ] := dRdpDatIni } )
			EndIF
			oGdRda := oGdRdaGet()
			IF ( ( nRdaDtIAva := GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader ) ) > 0 )
				aEval( oGdRda:aCols , { |aElem| aElem[ nRdaDtIAva ] := dRdpDatIni } )
			EndIF
		EndIF
	MyCursorArrow()

End Sequence

Return( lRdpDatIniOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatIniInit 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_DATINI									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_DATINI								�
�������������������������������������������������������������������������/*/
Function RdpDatIniInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatIniWhen 	 �Autor�Marinaldo de Jesus� Data �05/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �When do Campo RDP_DATINI									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do Campo RDP_DATINI									�
�������������������������������������������������������������������������/*/
Function RdpDatIniWhen()

Local cReadVar			:= ReadVar()
Local lRdpDatIniWhen	:= .T.

Local lGetDados
Local cRdpStatus

Begin Sequence

	IF !( "RDP_DATINI" $ cReadVar )
		Break
	EndIF

	IF ( Vazio() )
		Break
	EndIF

	lGetDados := IsInGetDados( { "RDP_STATUS" } )

	IF( lGetDados )
		cRdpStatus	:= GdFieldGet( "RDP_STATUS" )
	Else
		cRdpStatus	:= GetMemVar( "RDP_STATUS" )
	EndIF

	lRdpDatIniWhen := ( cRdpStatus $ SubStr( RdpStatusBox( .T. ) , 1 , 3 ) )
	IF ( lRdpDatIniWhen )
		lRdpDatIniWhen := RdpGdDelOk( 4 , .T. , .F. , .F. )
		IF !( lRdpDatIniWhen )
			GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 5 , 1 ) )
		EndIF
	EndIF

End Sequence

Return( lRdpDatIniWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatFimVld 	 �Autor�Marinaldo de Jesus� Data �06/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_DATFIM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_DATFIM								�
�������������������������������������������������������������������������/*/
Function RdpDatFimVld()

Local lRdpDatFimOK := .T.

Local aRd9Header
Local aRd9Cols
Local aRdaHeader
Local aRdaCols

Local lGetDados

Local dRd6DtIni
Local dRd6DtFim
Local dRdpDatIni
Local dRdpDatFim
Local dLstRdpDatFim

Local nRdpDatFim
Local nRdpDelete

Local oGdRd9
Local oGdRda

Begin Sequence

	IF !( lRdpDatFimOK := NaoVazio() )
		Break
	EndIF

	IF !( IsMemVar( "RD6_DTINI" ) .and. IsMemVar( "RD6_DTFIM" ) )
		Break
	EndIF
	dRd6DtIni	:= GetMemVar( "RD6_DTINI"  )
	dRd6DtFim	:= GetMemVar( "RD6_DTFIM"  )

	lGetDados := IsInGetDados( { "RDP_DATINI" , "RDP_DATFIM" } )

	/*
	��������������������������������������������������������������Ŀ
	� Verifica Se RDP_DATFIM esta dentro do Periodo da Avaliacao   �
	����������������������������������������������������������������*/
	IF ( lGetDados )
		dRdpDatIni 		:= GdFieldGet( "RDP_DATINI" )
		dLstRdpDatFim	:= GdFieldGet( "RDP_DATFIM" )
		nRdpDatFim		:= GdFieldPos( "RDP_DATFIM" )
		nRdpDelete		:= GdFieldPos( "GDDELETED"  )
	Else
		dRdpDatIni := GetMemVar( "RDP_DATINI" )
	EndIF
	dRdpDatFim	:= GetMemVar( "RDP_DATFIM" )

	/*
	��������������������������������������������������������������Ŀ
	� Data Final Nao Podera ser Menor que Data Inicial             �
	����������������������������������������������������������������*/
	IF !Empty( dRdpDatIni )
		IF !( lRdpDatFimOK := ( dRdpDatFim >= dRdpDatIni ) )
			//"Data Nao Pode Ser Vazia ou"###"Menor que Data Inicial."
			MsgInfo( ( STR0094 + " " + STR0096 ) , OemToAnsi( STR0098 ) ) //"Data Inv�lida"
			Break
		EndIF
	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Data Inicial Devera Estar No Periodo da Avaliacao            �
	����������������������������������������������������������������*/
	IF !( lRdpDatFimOK := ( ( dRdpDatFim >= dRd6DtIni ) .and. ( dRdpDatFim <= dRd6DtFim ) ) )
		cMsgInfo	:= STR0120	//"O conte�do do campo"
		cMsgInfo	+= " "
		cMsgInfo	+= aHeader[ GdFieldPos( "RDP_DATFIM" ) , 01 ]
		cMsgInfo	+= " "
		cMsgInfo	+= STR0121	//"deve estar dentro do per�odo definido para a Avalia��o."
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
   		cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
		cMsgInfo 	+= CRLF
		cMsgInfo 	+= CRLF
   		cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
		MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )	//'Aviso de Inconsist�ncia!'
    	Break
	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Se ocorreu Alteracao na Data Inicial, Altera o RD9 e RDA     �
	����������������������������������������������������������������*/
	MyCursorWait()
		IF (;
				!Empty( dLstRdpDatFim );
				.and.;
				( dLstRdpDatFim <> dRdpDatFim );
				.and.;
				Apda080Fldrs();
			)
			IF ( ( nRdpDatFim > 0 ) .and. ( nRdpDelete > 0 ) )
				IF ( aScan( aCols , { |x,y| (;
												( x[ nRdpDatFim ] == dLstRdpDatFim );
												.and.;
												( y <> n );
												.and.;
												!( x[ nRdpDelete ] );
											);
									 };
						  ) > 0;
				   )
					MyCursorArrow()
					Break
				EndIF
			EndIF
			aRd9Header := Rd9HeaderGet()
			IF ( ( nRd9DtFAva := GdFieldPos( "RD9_DTFAVA" , aRd9Header ) ) > 0 )
				aRd9Cols := Rd9ColsGet()
				aEval( aRd9Cols , { |aElem| aElem[ nRd9DtFAva ] := dRdpDatFim } )
			EndIF
			oGdRd9 := oGdRd9Get()
			IF ( ( nRd9DtFAva := GdFieldPos( "RD9_DTFAVA" , oGdRd9:aHeader ) ) > 0 )
				aEval( oGdRd9:aCols , { |aElem| aElem[ nRd9DtFAva ] := dRdpDatFim } )
			EndIF
			aRdaHeader	:= RdaHeaderGet()
			IF ( ( nRdaDtFAva	:= GdFieldPos( "RDA_DTFAVA" , aRdaHeader ) ) > 0 )
				aRdaCols := RdaColsGet()
				aEval( aRdaCols , { |aElem| aElem[ nRdaDtFAva ] := dRdpDatFim } )
			EndIF
			oGdRda := oGdRdaGet()
			IF ( ( nRdaDtFAva := GdFieldPos( "RDA_DTFAVA" , oGdRda:aHeader ) ) > 0 )
				aEval( oGdRda:aCols , { |aElem| aElem[ nRdaDtFAva ] := dRdpDatFim } )
			EndIF
		EndIF
	MyCursorArrow()

End Sequence

Return( lRdpDatFimOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatFimInit 	 �Autor�Marinaldo de Jesus� Data �06/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_DATFIM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_DATFIM								�
�������������������������������������������������������������������������/*/
Function RdpDatFimInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatFimWhen 	 �Autor�Marinaldo de Jesus� Data �06/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �When do Campo RDP_DATFIM									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do Campo RDP_DATFIM									�
�������������������������������������������������������������������������/*/
Function RdpDatFimWhen()

Local cReadVar			:= ReadVar()
Local lRdpDatFimWhen	:= .T.

Local lGetDados
Local cRdpStatus

Begin Sequence

	IF !( "RDP_DATFIM" $ cReadVar )
		Break
	EndIF

	IF ( Vazio() )
		Break
	EndIF

	lGetDados := IsInGetDados( { "RDP_STATUS" } )

	IF( lGetDados )
		cRdpStatus	:= GdFieldGet( "RDP_STATUS" )
	Else
		cRdpStatus	:= GetMemVar( "RDP_STATUS" )
	EndIF

	lRdpDatFimWhen := ( cRdpStatus $ SubStr( RdpStatusBox( .T. ) , 1 , 3 ) )
	IF ( lRdpDatFimWhen )
		lRdpDatFimWhen := RdpGdDelOk( 4 , .T. , .F. , .F. )
		IF !( lRdpDatFimWhen )
			GdFieldPut( "RDP_STATUS" , SubStr( RdpStatusBox( .T. ) , 5 , 1 ) )
		EndIF
	EndIF

End Sequence

Return( lRdpDatFimWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpIniRspVld 	 �Autor�Marinaldo de Jesus� Data �06/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_INIRSP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_INIRSP								�
�������������������������������������������������������������������������/*/
Function RdpIniRspVld()

Local lRdpIniRspOK := .T.

Local lGetDados
Local dRdpIniRsp
Local dRdpDatIni

Begin Sequence

	IF !( lRdpIniRspOK := NaoVazio() )
		Break
	EndIF

	lGetDados := IsInGetDados( { "RDP_INIRSP" , "RDP_DATINI" } )

	IF ( lGetDados )

		dRdpIniRsp	:= GetMemVar( "RDP_INIRSP" )
		dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )

	Else

		dRdpIniRsp	:= GetMemVar( "RDP_INIRSP" )
		dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )

	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Verifica Se RDP_INIRSP eh maior ou igual ao Inicial da Avalia�
	� cao														   �
	����������������������������������������������������������������*/
	IF !( lRdpIniRspOK := ( dRdpIniRsp >= dRdpDatIni ) )
		//"Data de Inicio das Respostas dever� ser maior ou igual a Data de In�cio."
		//"Aviso de Inconsistencia!"
		MsgInfo( OemToAnsi( STR0136 ) , OemToAnsi( STR0022 ) )
		Break
	EndIF

End Sequence

Return( lRdpIniRspOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpDatGerVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_DATGER									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_DATGER								�
�������������������������������������������������������������������������/*/
Function RdpDatGerVld()

Local lRdpDatGerOK := .T.

Local lGetDados
Local dRdpDatGer
Local dRdpDatIni

Begin Sequence

	IF !( lRdpDatGerOK := NaoVazio() )
		Break
	EndIF

	lGetDados := IsInGetDados( { "RDP_DATGER" , "RDP_DATINI" } )

	IF ( lGetDados )

		dRdpDatGer	:= GetMemVar( "RDP_DATGER" )
		dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )

	Else

		dRdpDatGer	:= GetMemVar( "RDP_DATGER" )
		dRdpDatIni	:= GdFieldGet( "RDP_DATINI" )

	EndIF

	/*
	��������������������������������������������������������������Ŀ
	� Verifica Se RDP_DATGER eh menor ou igual ao Inicial da Avalia�
	� cao														   �
	����������������������������������������������������������������*/
	IF !( lRdpDatGerOK := ( dRdpDatGer <= dRdpDatIni ) )
		//"Data de Gera��o dever� ser menor ou igual a Data de In�cio."
		//"Aviso de Inconsistencia!"
		MsgInfo( OemToAnsi( STR0131 ) , OemToAnsi( STR0022 ) )
		Break
	EndIF

End Sequence

Return( lRdpDatGerOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    � RdpDatGerInit	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_DATGER									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_DATGER								�
�������������������������������������������������������������������������/*/
Function RdpDatGerInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpIniRspInit 	 �Autor�Marinaldo de Jesus� Data �06/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_INIRSP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_INIRSP								�
�������������������������������������������������������������������������/*/
Function RdpIniRspInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpRspAdoVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_RSPADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_RSPADO								�
�������������������������������������������������������������������������/*/
Function RdpRspAdoVld()
Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpRspAdoInit 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_RSPADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_RSPADO								�
�������������������������������������������������������������������������/*/
Function RdpRspAdoInit()
Return( Ctod( "//" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpRspDorVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_RSPDOR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_RSPDOR								�
�������������������������������������������������������������������������/*/
Function RdpRspDorVld()
Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpRspDorInit 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_RSPDOR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_RSPDOR								�
�������������������������������������������������������������������������/*/
Function RdpRspDorInit()
Return( Ctod( "//" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpRspConVld 	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_RSPCON									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_RSPCON								�
�������������������������������������������������������������������������/*/
Function RdpRspConVld()
Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpRspConInit	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_RSPCON									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_RSPCON								�
�������������������������������������������������������������������������/*/
Function RdpRspConInit()
Return( Ctod( "//" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipEnvVld	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_TIPENV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_TIPENV								�
�������������������������������������������������������������������������/*/
Function RdpTipEnvVld()

Local lRdpTipEnvVld := .T.
Local nAviso		:= 0
Local lCpoAgend		:= ( RD6->(ColumnPos( "RD6_AGDSCH" )) == 0 ) .Or. ( RD6->(ColumnPos( "RD6_AGDENV" )) == 0 )

Begin Sequence

	IF !( lRdpTipEnvVld := Pertence( RdpTipEnvBox( .T. ) ) )
		Break
	EndIF

	IF ( GetMemVar( "RDP_TIPENV" ) == "2" ) //"Avaliacao"
		IF IsInGetDados( { "RDP_TIPENV" , "RDP_MSGAVA" } )
			GdFieldPut( "RDP_MSGAVA" , Space( GetSx3Cache( "RDP_MSGAVA" , "X3_TAMANHO" ) ) )
		Else
			SetMemVar( "RDP_MSGAVA" , Space( GetSx3Cache( "RDP_MSGAVA" , "X3_TAMANHO" ) ) )
		EndIF
	EndIF

	If lCpoAgend .And. GetMemVar( "RDP_TIPENV" ) $ "1|2"
		lRdpTipEnvVld := .F.
		nAviso := Aviso( STR0161, STR0162 + CRLF + CRLF +; // "Workflow" #  "Problema"
		STR0163 + CRLF + CRLF +; // "Para utilizar os tipos de envio 1 - Mensagem, ou 2 - Avalia��o � necess�rio que os campos RD6_AGDSCH e RD6_AGDENV existam no ambiente."
		STR0164 + CRLF + CRLF +; // "Solu��o"
		STR0165 + CRLF +; // "A documenta��o com processo para a atualiza��o do ambiente e a cria��o dos campos est� dispon�vel no TDN."
		STR0166, {STR0167, STR0168}, 3 ) //"Pode acessar a documenta��o utilizando o bot�o abaixo." # "Documenta��o" # "Fechar"
		If nAviso == 1
			OpenLink("https://tdn.totvs.com/x/cy_uHg")
		EndIf
	EndIf

End Sequence

Return( lRdpTipEnvVld )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipEnvInit	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_TIPENV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_TIPENV								�
�������������������������������������������������������������������������/*/
Function RdpTipEnvIni()
Return( SubStr( RdpTipEnvBox( .T. ) , 1 , 1 ) )	//"Aviso"

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipEnvBox	 �Autor�Marinaldo de Jesus� Data �26/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Box do Campo RDP_TIPENV										�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RDP_TIPENV									�
�������������������������������������������������������������������������/*/


/*/{Protheus.doc} RdpTipEnvBox
ComboBox do Campo RDP_TIPENV
@author Marinaldo de Jesus
@since 26/04/2004
@history C�cero Alves, 11/09/2019, Retirada a op��o 2- avalia��o
/*/
Function RdpTipEnvBox( lValid, lRetDesc, cOpcDesc )

	Local cOpcBox

	DEFAULT lValid		:= .F.
	DEFAULT lRetDesc	:= .F.

	IF !( lValid )

		IF !( lRetDesc )
			cOpcBox := ( "1=" + STR0132 + ";" )	//"Aviso"
			cOpcBox += ( "3=" + STR0144       )	//"Nao Enviar"
		Else
			Do Case
				Case ( cOpcDesc == "1" ) ; ( cOpcBox := STR0132 )	//"Aviso
				Case ( cOpcDesc == "3" ) ; ( cOpcBox := STR0144 )	//"Nao Enviar"
			End Case
		EndIF
	Else
		cOpcBox := "13"
	EndIF

Return( cOpcBox )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpMsgAvaVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_MSGAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_MSGAVA								�
�������������������������������������������������������������������������/*/
Function RdpMsgAvaVld()

Local lRdpMsgAvaOK := .T.

Local cRdpTipEnv

Begin Sequence

	IF IsInGetDados( { "RDP_TIPENV" , "RDP_MSGAVA" } )
		cRdpTipEnv := GdFieldGet( "RDP_TIPENV" )
	Else
		cRdpTipEnv := GetMemVar( "RDP_TIPENV" )
	EndIF

	IF (;
			( cRdpTipEnv == "2" );	//Avaliacao
			.and.;
			Vazio();
		)
		Break
	EndIF

	IF !( lRdpMsgAvaOK := ExistCpo( "RDG" ) )
		Break
	EndIF

End Sequence

Return( lRdpMsgAvaOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpMsgAvaWhen 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_MSGAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_MSGAVA								�
�������������������������������������������������������������������������/*/
Function RdpMsgAvaWhen()

Local cReadVar			:= ReadVar()
Local lRdpMsgAvaWhen	:= .T.

IF ( SubStr( cReadVar , 4 ) == RDP_MSGAVA )
	IF IsInGetDados( { "RDP_TIPENV" } )
		lRdpMsgAvaWhen := ( GdFieldGet( "RDP_TIPENV" ) == "1" )
	Else
		lRdpMsgAvaWhen := ( GetMemVar( "RDP_TIPENV" ) == "1" )
	EndIF
EndIF

Return( lRdpMsgAvaWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipCobVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_TIPCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_TIPCOB								�
�������������������������������������������������������������������������/*/
Function RdpTipCobVld()

Local lRdpTipCobOK := .T.

Begin Sequence

	IF !( lRdpTipCobOK := Pertence( OpBxTipCob( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdpTipCobOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipCobInit 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_TIPCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_TIPCOB								�
�������������������������������������������������������������������������/*/
Function RdpTipCobInit()
Return( SubStr( OpBxTipCob( .T. ) , 2 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipCobBox  	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Box do Campo RDP_TIPCOB										�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RDP_TIPCOB									�
�������������������������������������������������������������������������/*/
Function RdpTipCobBox()
Return( OpBxTipCob( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpTipCobWhen 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �When do Campo RDP_TIPCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do Campo RDP_TIPCOB									�
�������������������������������������������������������������������������/*/
Function RdpTipCobWhen()

Local lWhen := .T.

IF ( Upper( AllTrim( ReadVar() ) ) == "M->RDP_TIPCOB" )
	lWhen := .T.
EndIF

Return( lWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpQtdCobVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_QTDCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_QTDCOB								�
�������������������������������������������������������������������������/*/
Function RdpQtdCobVld()

Local lRdpQtdCobOK := .T.

Begin Sequence

	IF !( lRdpQtdCobOK := Positivo() )
		Break
	EndIF

End Sequence

Return( lRdpQtdCobOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpQtdCobInit 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDP_QTDCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDP_QTDCOB								�
�������������������������������������������������������������������������/*/
Function RdpQtdCobInit()
Return( 0 )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpQtdCobWhen 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �When do Campo RDP_QTDCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_WHEN do Campo RDP_QTDCOB									�
�������������������������������������������������������������������������/*/
Function RdpQtdCobWhen()

Local lWhen := .T.

IF ( Upper( AllTrim( ReadVar() ) ) == "M->RDP_QTDCOB" )
	lWhen := .T.
EndIF

Return( lWhen )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpMemCobVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_MEMCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_MEMCOB								�
�������������������������������������������������������������������������/*/
Function RdpMemCobVld()

Local lRdpMemCobOK := .T.

Begin Sequence

	IF ( !( RdpMTipCob() ) .and. Vazio() )
		Break
	EndIF

	IF !( lRdpMemCobOK := NaoVazio() )
		Break
	EndIF

	IF !( lRdpMemCobOK := ExistCpo( "RDG" ) )
		Break
	EndIF

End Sequence

Return( lRdpMemCobOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpMemCobVld 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDP_MEMCOB									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDP_MEMCOB								�
�������������������������������������������������������������������������/*/
Function RdpMemRspVld()

Local lRdpMemRspOK := .T.

Begin Sequence

	IF ( Vazio() )
		Break
	EndIF

	IF !( lRdpMemRspOK := ExistCpo( "RDG" ) )
		Break
	EndIF

End Sequence

Return( lRdpMemRspOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpMTipCob	 	 �Autor�Marinaldo de Jesus� Data �05/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se deve enviar Mensagem de acordo com RDP_TIPCOB	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA080                   									�
�������������������������������������������������������������������������/*/
Static Function RdpMTipCob()

Local lMsgCob	:= .F.

IF ( IsInGetDados( { "RDP_TIPCOB" } ) )
	lMsgCob	:= (;
					( GdFieldGet( "RDP_TIPCOB" ) == SubStr( OpBxTipCob( .T. ) , 1 , 1 ) );
					.or.	;
					( GdFieldGet( "RDP_TIPCOB" ) == SubStr( OpBxTipCob( .T. ) , -1 ) );
				)
ElseIF ( IsMemVar( "RDP_TIPCOB" ) )
	lMsgCob	:= (;
					( GetMemVar( "RDP_TIPCOB" ) == SubStr( OpBxTipCob( .T. ) , 1 , 1 ) );
					.or.	;
					( GetMemVar( "RDP_TIPCOB" ) == SubStr( OpBxTipCob( .T. ) , -1 ) );
				)
EndIF

Return( lMsgCob )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpStatusVld 	 �Autor�Marinaldo de Jesus� Data �03/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD6_PERIOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RD6_PERIOD								�
�������������������������������������������������������������������������/*/
Function RdpStatusVld()

Local lRdpStatusOK := .T.

Begin Sequence

	IF !( lRdpStatusOK := NaoVazio() )
		Break
	EndIF

	IF !( lRdpStatusOK := Pertence( RdpStatusBox( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdpStatusOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpStatusInit 	 �Autor�Marinaldo de Jesus� Data �03/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD6_PERIOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD6_PERIOD								�
�������������������������������������������������������������������������/*/
Function RdpStatusInit()
Return( SubStr( RdpStatusBox( .T. ) , 1 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdpStatusBox 	 �Autor�Marinaldo de Jesus� Data �03/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �OpcBox do Campo RD6_PERIOD									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RD6_PERIOD									�
�������������������������������������������������������������������������/*/
Function RdpStatusBox( lValid , lRetDesc , cOpcDesc )

Local cOpcBox

DEFAULT lValid		:= .F.
DEFAULT lRetDesc	:= .F.

IF !( lValid )

	IF !( lRetDesc )

		cOpcBox := ( "1=" + STR0103 + ";" )	//"Nao Gerada"
		cOpcBox += ( "2=" + STR0122 + ";" )	//"Excluida"
		cOpcBox += ( "3=" + STR0104 + ";" )	//"Nao Enviada"
		cOpcBox += ( "4=" + STR0105 + ";" )	//"Enviada"
		cOpcBox += ( "5=" + STR0106 + ";" )	//"Respondida"
		cOpcBox += ( "6=" + STR0134       )	//"Encerrada"

	Else

		Do Case
			Case ( cOpcDesc == "1" ) ; ( cOpcBox := STR0103 )	//"Nao Gerada"
			Case ( cOpcDesc == "2" ) ; ( cOpcBox := STR0106 )	//"Excluida"
			Case ( cOpcDesc == "3" ) ; ( cOpcBox := STR0104 )	//"Nao Enviada"
			Case ( cOpcDesc == "4" ) ; ( cOpcBox := STR0105 )	//"Enviada"
			Case ( cOpcDesc == "5" ) ; ( cOpcBox := STR0106 )	//"Respondida"
			Case ( cOpcDesc == "6" ) ; ( cOpcBox := STR0134 )	//"Encerrada"
		End Case

	EndIF

Else

	cOpcBox := "123456"

EndIF

Return( cOpcBox )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9CodAvaInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD9_CODAVA					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD9_CODAVA								�
�������������������������������������������������������������������������/*/
Function Rd9CodAvaInit()
Local cRd9CodAvaInit := IF(IsMemVar("RD6_CODIGO"),GetMemVar("RD6_CODIGO"),Space(GetSx3Cache("RD9_CODAVA","X3_TAMANHO")))
Return( SetMemVar( "RD9_CODAVA" , cRd9CodAvaInit ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9CodAvaVld	 �Autor�Marinaldo de Jesus� Data �17/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD9_CODAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD9_CODAVA								�
�������������������������������������������������������������������������/*/
Function Rd9CodAvaVld()

Local lRd9CodAvaOk := .T.

Begin Sequence

	IF !( lRd9CodAvaOk := NaoVazio() )
		Break
	EndIF

	IF !( lRd9CodAvaOk := ExistCpo( "RD6" ) )
		Break
	EndIF

End Sequence

Return( lRd9CodAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9CodAdoVld 	 �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD9_CODADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD9_CODADO									�
�������������������������������������������������������������������������/*/
Function Rd9CodAdoVld()

Local lRd9CodAdoOk	:= .T.

Local cMsgInfo
Local dRd6DtIni
Local dRd6DtFim

Begin Sequence

	IF !( lRd9CodAdoOk := NaoVazio() )
		Break
	EndIF

	IF !( lRd9CodAdoOk := ExistCpo( "RD0" ) )
		Break
	EndIF

	dRd6DtIni := GetMemVar( "RD6_DTINI" )
	dRd6DtFim := GetMemVar( "RD6_DTFIM" )

	IF ( !Empty( dRd6DtIni ) .and. !Empty( dRd6DtFim ) )
		RD0->( dbSetOrder( RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" ) ) )
		IF RD0->( MsSeek( xFilial( "RD0" ) + GetMemVar( "RD9_CODADO" ) , .F. ) )
			IF !( lRd9CodAdoOk := ( RD0->RD0_DTADMI <= dRd6DtFim ) )
				cMsgInfo	:= STR0099	//"Este participante n�o pode ser Constar nesta Avalia��o"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0100	//"Data de Admiss�o: "
				cMsgInfo	+= Dtoc( RD0->RD0_DTADMI )
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
				MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
				Break
			EndIF
		EndIF
	EndIF
	R9270NomeIni()

End Sequence

Return( lRd9CodAdoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9DtiAvaVld     �Autor�Marinaldo de Jesus� Data �11/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD9_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD9_DTIAVA									�
�������������������������������������������������������������������������/*/
Function Rd9DtiAvaVld()

Local lRd9DtiAvaOk := .T.

Local cRd9CodPro
Local dRd9DtiAva
Local dRd9DtfAva
Local lGetDados

Begin Sequence

	IF !( lRd9DtiAvaOk := NaoVazio() )
		Break
	EndIF

	MyCursorWait()

		lGetDados := IsInGetDados( { "RD9_CODADO" , "RD9_CODPRO" , "RD9_DTIAVA" , "RD9_DTFAVA" } )

		IF ( lGetDados )
			cRd9CodPro	:= GdFieldGet( "RD9_CODPRO" )
			dRd9DtiAva	:= GetMemVar(  "RD9_DTIAVA" )
			dRd9DtfAva	:= GdFieldGet( "RD9_DTFAVA" )
			IF !Empty( dRd9DtfAva )
				IF !( lRd9DtiAvaOk := ( dRd9DtiAva <= dRd9DtfAva ) )
			    	MyCursorArrow()
			    	//'A Data Inicial n�o pode ser maior que a Data Final'###'Aviso de Inconsist�ncia!'
			    	MsgInfo( OemToAnsi( STR0072 ) , OemToAnsi( STR0022 ) )
					Break
				EndIF
			EndIF
			Rd9GdChgInfo( cRd9CodPro , dRd9DtiAva , dRd9DtfAva )
		EndIF
	MyCursorArrow()

End Sequence

Return( lRd9DtiAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9DtiAvaInit    �Autor�Marinaldo de Jesus� Data �11/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD9_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD9_DTIAVA								�
�������������������������������������������������������������������������/*/
Function Rd9DtiAvaInit()

Local dRd9DtiAvaInit := Ctod( "//" )
Local oGdRdp

dRd9DtiAvaInit := RD9DtInicAva()


Return( dRd9DtiAvaInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9DtfAvaVld     �Autor�Marinaldo de Jesus� Data �11/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RD9_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RD9_DTFAVA									�
�������������������������������������������������������������������������/*/
Function Rd9DtfAvaVld()

Local lRd9DtfAvaOk := .T.

Local cRd9CodPro
Local dRd9DtiAva
Local dRd9DtfAva
Local lGetDados

Begin Sequence

	IF !( lRd9DtfAvaOk := NaoVazio() )
		Break
	EndIF

	MyCursorWait()

		lGetDados := IsInGetDados( { "RD9_CODADO" , "RD9_CODPRO" , "RD9_DTIAVA" , "RD9_DTFAVA" } )

		IF ( lGetDados )
			cRd9CodPro	:= GdFieldGet( "RD9_CODPRO" )
			dRd9DtiAva	:= GdFieldGet( "RD9_DTIAVA" )
			dRd9DtfAva	:= GetMemVar(  "RD9_DTFAVA" )
			IF !Empty( dRd9DtiAva )
				IF !( lRd9DtiAvaOk := ( dRd9DtiAva <= dRd9DtfAva ) )
			    	MyCursorArrow()
			    	//'A Data Inicial n�o pode ser maior que a Data Final'###'Aviso de Inconsist�ncia!'
			    	MsgInfo( OemToAnsi( STR0072 ) , OemToAnsi( STR0022 ) )
					Break
				EndIF
			EndIF
			Rd9GdChgInfo( cRd9CodPro , dRd9DtiAva , dRd9DtfAva )
		EndIF
	MyCursorArrow()

End Sequence

Return( lRd9DtfAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9DtfAvaInit    �Autor�Marinaldo de Jesus� Data �11/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RD9_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RD9_DTFAVA								�
�������������������������������������������������������������������������/*/
Function Rd9DtfAvaInit()

Local dRd9DtfAvaInit := Ctod( "//" )

dRd9DtfAvaInit	:= Rd9DtFimAva()

Return( dRd9DtfAvaInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9NomeInit		 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RD9_NOME						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RD9_NOME								�
�������������������������������������������������������������������������/*/
Function Rd9NomeInit()

Local cRd9NomeInit	:= ""
Local nOrder		:= RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" , .F. )

Local cRd9CodAdo
Local lGetDados
Local nRd9Nome
Local oGdRd9

lGetDados := IsInGetDados( { "RD9_NOME" , "RD9_CODADO" } )

IF ( lGetDados )
	cRd9CodAdo		:= GetMemVar( "RD9_CODADO" )
	cRd9NomeInit	:= PosAlias( "RD0" , cRd9CodAdo , xFilial( "RD9" ) , "RD0_NOME" , nOrder , .F. )
	oGdRd9			:= oGdRd9Get( APDA270_FOLDER_AVALIADOS )
	IF ( Apda080Fldrs() .and. ( ValType( oGdRd9 ) == "O" ) 	)
		IF ( ( nRd9Nome := GdFieldPos( "RD9_NOME" , oGdRd9:aHeader ) ) > 0 )
			IF !( InAddLine( "APDA270/__EXECUTE/RUNAPP/SIGAAPD/" ) )
				oGdRd9:aCols[ oGdRd9:nAt , nRd9Nome ] := cRd9NomeInit
			EndIF
		EndIF
	EndIF
Else
	cRd9NomeInit	:= PosAlias( "RD0" , RD9->RD9_CODADO , xFilial( "RD9" ) , "RD0_NOME" , nOrder , .F. )
EndIF

Return( cRd9NomeInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9NomeBrw		 �Autor�Marinaldo de Jesus� Data �23/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Browse para o Campo RD9_NOME		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_INIBRW do campo RD9_NOME									�
�������������������������������������������������������������������������/*/
Function Rd9NomeBrw()
Return( Rd9NomeInit() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9CodProVld	 �Autor�Marinaldo de Jesus� Data �02/09/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid para o Campo RD9_CODPRO            					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RD9_CODPRO   								�
�������������������������������������������������������������������������/*/
Function Rd9CodProVld()

Local lRd9CodProOk := .T.

Local dRd6DtIni
Local dRd6DtFim
Local dDtiAvaOk
Local dDtfAvaOk
Local lGetDados
Local cRd5Tipo		:= Posicione("RD5",1,xFilial("RD5")+GetMemVar( "RD6_CODTIP" ),"RD5_TIPO")

Begin Sequence

	If cRd5Tipo="3".and.Vazio()
		lRd9CodProOk :=.F.
		Break
	EndIF

	IF !( lRd9CodProOk := ExistCpo( "RDN" ) )
		Break
	EndIF

	MyCursorWait()
		IF ( ( IsMemVar( "RD6_DTINI" ) ) .and. ( IsMemVar( "RD6_DTFIM" ) ) )

			dRd6DtIni := GetMemVar( "RD6_DTINI" )
			dRd6DtFim := GetMemVar( "RD6_DTFIM" )
			IF !( RDN->( RDN_FILIAL + RDN_CODIGO ) == ( xFilial( "RDN" ) + GetMemVar( "RD9_CODPRO" ) ) )
				RDN->( dbSetOrder( RetOrdem( "RDN" , "RDN_FILIAL+RDN_CODIGO" ) ) )
				RDN->( dbSeek( ( xFilial( "RDN" ) + GetMemVar( "RD9_CODPRO" ) ) , .F. ) )
			EndIF
			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se a Data Inicial e Final estao Dentro do Periodo de�
			� finido para a Avalliacao									   �
			����������������������������������������������������������������/*/
			IF !( lRd9CodProOk := Apda080DtOk( dRd6DtIni , dRd6DtFim , RDN->RDN_DTIPRO , RDN->RDN_DTFPRO ) )
				cMsgInfo	:= STR0079	//'O per�odo do Projeto selecionado est� fora do per�odo definido para a Avalia��o'
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0080	//'Per�odo definido para o Projeto: '
				cMsgInfo	+= ( Dtoc( RDN->RDN_DTIPRO ) + " - " + Dtoc( RDN->RDN_DTFPRO ) )
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
				cMsgInfo	+= " "
				cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
				MyCursorArrow()
				MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
				Break
			EndIF

			lGetDados := IsInGetDados( { "RD9_CODPRO" , "RD9_CODADO" , "RD9_DTIAVA" , "RD9_DTFAVA" } )

			dDtiAvaOk := Max( RDN->RDN_DTIPRO , dRd6DtIni )
			dDtfAvaOk := Min( RDN->RDN_DTFPRO , dRd6DtFim )

			RD0->( dbSetOrder( RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" ) ) )
			IF RD0->( MsSeek( xFilial( "RD0" ) + IF( lGetDados , GdFieldGet( "RD9_CODADO" ) , GetMemVar( "RD9_CODADO" ) ) , .F. ) )
				dDtiAvaOk := Max( dDtiAvaOk , RD0->RD0_DTADMI )
			EndIF
			IF !( lRd9CodProOk := Apda080DtOk( dRd6DtIni , dRd6DtFim , dDtiAvaOk , dDtfAvaOk  ) )
				cMsgInfo	:= STR0099	//"Este participante n�o pode ser Constar nesta Avalia��o"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0100	//"Data de Admiss�o: "
				cMsgInfo	+= Dtoc( RD0->RD0_DTADMI )
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
				MyCursorArrow()
				MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
				Break
			EndIF

			IF ( lGetDados )
				Rd9GdChgInfo( GetMemVar( "RD9_CODPRO" ) , dDtiAvaOk , dDtfAvaOk )
	 			GdFieldPut( "RD9_DTIAVA" , dDtiAvaOk )
				GdFieldPut( "RD9_DTFAVA" , dDtfAvaOk )
			EndIF

		 	SetMemVar( "RD9_DTIAVA" , dDtiAvaOk )
			SetMemVar( "RD9_DTFAVA" , dDtfAvaOk )

		EndIF
	MyCursorArrow()

End Sequence

Return( lRd9CodProOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9CodProInit	 �Autor�Marinaldo de Jesus� Data �25/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializador padrao para o campo RD9_CODPRO				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO DO campo RD9_CODPRO   							�
�������������������������������������������������������������������������/*/
Function Rd9CodProInit()
Local cRd9CodProIni := Space( GetSx3Cache("RD9_CODPRO","X3_TAMANHO" ) )
Return( SetMemVar( "RD9_CODPRO" , cRd9CodProIni ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNomeInit		 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_NOME						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_NOME								�
�������������������������������������������������������������������������/*/
Function RdaNomeInit()

Local cRdaNomeInit		:= ""


	cRdaNomeInit	:= R270NomeInit()


Return( cRdaNomeInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNomeBrw		 �Autor�Marinaldo de Jesus� Data �23/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Browse para o Campo RDA_NOME		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_INIBRW do campo RDA_NOME									�
�������������������������������������������������������������������������/*/
Function RdaNomeBrw()
Return( RdaNomeInit() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodAvaVld	 �Autor�Marinaldo de Jesus� Data �17/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDA_CODAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDA_CODAVA								�
�������������������������������������������������������������������������/*/
Function RdaCodAvaVld()

Local lRdaCodAvaOk := .T.

Begin Sequence

	IF !( lRdaCodAvaOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdaCodAvaOk := ExistCpo( "RD6" ) )
		Break
	EndIF

End Sequence

Return( lRdaCodAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodTipVld	 �Autor�Marinaldo de Jesus� Data �27/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDA_CODTIP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDA_CODTIP								�
�������������������������������������������������������������������������/*/
Function RdaCodTipVld()

Local lRdaCodTipOk := .T.

Begin Sequence

	IF !( lRdaCodTipOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdaCodTipOk := ExistCpo( "RD5" ) )
		Break
	EndIF

End Sequence

Return( lRdaCodTipOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodNetVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDA_CODNET									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDA_CODNET								�
�������������������������������������������������������������������������/*/
Function RdaCodNetVld()

Local lRdaCodNetOk := .T.

Local cRdaCodTip
Local cRdaCodNet
Local nRdhOrder

Begin Sequence

	IF !( lRdaCodNetOk := NaoVazio() )
		Break
	EndIF

	IF ( IsInGetDados( { "RDA_CODTIP" } ) )
		cRdaCodTip := GdFieldGet( "RDA_CODTIP" )
	Else
		cRdaCodTip := GetMemVar( "RDD_CODTIP" )
	EndIF
	cRdaCodNet := GetMemVar( ReadVar() )

	nRdhOrder := RetOrdem( "RDH" , "RDH_FILIAL+RDH_CODTIP+RDH_CODNET" )
	IF !( lRdaCodNetOk := ExistCpo( "RDH" , cRdaCodTip + cRdaCodNet , nRdhOrder ) )
		Break
	EndIF

End Sequence

Return( lRdaCodNetOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNivelVld		 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDA_NIVEL									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDA_NIVEL									�
�������������������������������������������������������������������������/*/
Function RdaNivelVld()

Local lRdaNivelOk := .T.

Begin Sequence

	IF !( lRdaNivelOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdaNivelOk := Pertence( OpBxNivel( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdaNivelOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodAdoVld 	 �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDA_CODADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDA_CODADO									�
�������������������������������������������������������������������������/*/
Function RdaCodAdoVld()

Local lRdaCodAdoOk	:= ( NaoVazio() .and. ExistCpo( "RD0" ) )

Return( lRdaCodAdoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodDorVld 	 �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDA_CODDOR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDA_CODDOR									�
�������������������������������������������������������������������������/*/
Function RdaCodDorVld()

Local nPosDor		:= GdFieldPos("RDA_CODDOR")
Local lRdaCodDorOk	:= .T.

If !Inclui .And. !Empty(aCols[n][nPosDor]) //Se nao for inclusao nao permite alterar codigo.
	lRdaCodDorOk := .F.
Else
	IF ( lRdaCodDorOk := ( NaoVazio() .and. ExistCpo( "RD0" ) ) )
		RdaNomeInit()
	EndIF
EndIf

Return( lRdaCodDorOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodProVld	 �Autor�Marinaldo de Jesus� Data �02/09/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid para o Campo RDA_CODPRO            					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDA_CODPRO   								�
�������������������������������������������������������������������������/*/
Function RdaCodProVld()

Local lRdaCodProOk := .T.

Local dRd6DtIni
Local dRd6DtFim
Local dDtiAvaOk
Local dDtfAvaOk
Local lGetDados

Begin Sequence

	IF ( Vazio() )
		Break
	EndIF

	IF !( lRdaCodProOk := ExistCpo( "RDN" ) )
		Break
	EndIF

	IF ( ( IsMemVar( "RD6_DTINI" ) ) .and. ( IsMemVar( "RD6_DTFIM" ) ) )
		dRd6DtIni := GetMemVar( "RD6_DTINI" )
		dRd6DtFim := GetMemVar( "RD6_DTFIM" )
		IF !( RDN->( RDN_FILIAL + RDN_CODIGO ) == ( xFilial( "RDN" ) + GetMemVar( "RDA_CODPRO" ) ) )
			RDN->( dbSetOrder( RetOrdem( "RDN" , "RDN_FILIAL+RDN_CODIGO" ) ) )
			RDN->( dbSeek( ( xFilial( "RDN" ) + GetMemVar( "RDA_CODPRO" ) ) , .F. ) )
		EndIF
		/*/
		��������������������������������������������������������������Ŀ
		� Verifica Se a Data Inicial e Final estao Dentro do Periodo de�
		� finido para a Avalliacao									   �
		����������������������������������������������������������������/*/
		IF !( lRdaCodProOk := Apda080DtOk( dRd6DtIni , dRd6DtFim , RDN->RDN_DTIPRO , RDN->RDN_DTFPRO ) )
			cMsgInfo	:= STR0079	//'O per�odo do Projeto selecionado est� fora do per�odo definido para a Avalia��o'
			cMsgInfo	+= CRLF
			cMsgInfo	+= CRLF
			cMsgInfo	+= STR0080	//'Per�odo definido para o Projeto: '
			cMsgInfo	+= ( Dtoc( RDN->RDN_DTIPRO ) + " - " + Dtoc( RDN->RDN_DTFPRO ) )
			cMsgInfo	+= CRLF
			cMsgInfo	+= CRLF
			cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
			cMsgInfo 	+= CRLF
			cMsgInfo 	+= CRLF
			cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
			Break
		EndIF

		lGetDados := IsInGetDados( { "RDA_CODPRO" , "RDA_CODADO" , "RDA_DTIAVA" , "RDA_DTFAVA" } )

		dDtiAvaOk := Max( RDN->RDN_DTIPRO , dRd6DtIni )
		dDtfAvaOk := Min( RDN->RDN_DTFPRO , dRd6DtFim )

		RD0->( dbSetOrder( RetOrdem( "RD0" , "RD0_FILIAL+RD0_CODIGO" ) ) )
		IF RD0->( MsSeek( xFilial( "RD0" ) + IF( lGetDados , GdFieldGet( "RDA_CODADO" ) , GetMemVar( "RDA_CODADO" ) ) , .F. ) )
			dDtiAvaOk := Max( dDtiAvaOk , RD0->RD0_DTADMI )
		EndIF
		IF !( lRdaCodProOk := Apda080DtOk( dRd6DtIni , dRd6DtFim , dDtiAvaOk , dDtfAvaOk  ) )
			cMsgInfo	:= STR0099	//"Este participante n�o pode ser Constar nesta Avalia��o"
			cMsgInfo	+= CRLF
			cMsgInfo	+= CRLF
			cMsgInfo	+= STR0100	//"Data de Admiss�o: "
			cMsgInfo	+= Dtoc( RD0->RD0_DTADMI )
			cMsgInfo	+= CRLF
			cMsgInfo	+= CRLF
			cMsgInfo	+= STR0078	//'Per�odo definido para a Avalia��o: '
			cMsgInfo	+= CRLF
			cMsgInfo	+= CRLF
			cMsgInfo	+= ( Dtoc( dRd6DtIni ) + " - " + Dtoc( dRd6DtFim ) )
			MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0022 ) )//'Aviso de Inconsist�ncia!'
			Break
		EndIF

		IF ( lGetDados )
 			GdFieldPut( "RDA_DTIAVA" , dDtiAvaOk )
			GdFieldPut( "RDA_DTFAVA" , dDtfAvaOk )
		EndIF

	 	SetMemVar( "RDA_DTIAVA" , dDtiAvaOk )
		SetMemVar( "RDA_DTFAVA" , dDtfAvaOk )

	EndIF

End Sequence

Return( lRdaCodProOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodProInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODPRO					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODPRO								�
�������������������������������������������������������������������������/*/
Function RdaCodProInit()

Local cRdaCodProInit := Space( GetSx3Cache("RDA_CODPRO","X3_TAMANHO" ) )
cRdaCodProInit	:= R270CodProInit()


Return( cRdaCodProInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodAvaInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODAVA					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODAVA								�
�������������������������������������������������������������������������/*/
Function RdaCodAvaInit()
Return( IF(IsMemVar("RD6_CODIGO"),GetMemVar("RD6_CODIGO"),Space(GetSx3Cache("RDA_CODAVA","X3_TAMANHO"))))

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodAdoInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODADO					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODADO								�
�������������������������������������������������������������������������/*/
Function RdaCodAdoInit()

Local cRdaCodAdoInit	:= Space( GetSx3Cache("RDA_CODADO","X3_TAMANHO" ) )

cRdaCodAdoInit	:= R270CodAdoInit()

Return( cRdaCodAdoInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodDorInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODDOR					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODDOR								�
�������������������������������������������������������������������������/*/
Function RdaCodDorInit()
Return( Space( GetSx3Cache("RDA_CODDOR","X3_TAMANHO" ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodTipInit	 �Autor�Marinaldo de Jesus� Data �27/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODTIP					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODTIP								�
�������������������������������������������������������������������������/*/
Function RdaCodTipInit()
Return( GetMemVar( "RD6_CODTIP" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaCodNetInit	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_CODNET					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_CODNET								�
�������������������������������������������������������������������������/*/
Function RdaCodNetInit()

Local cRdaCodNet	:= Space( GetSx3Cache("RDA_CODNET","X3_TAMANHO" ) )
cRdaCodNet := R270CodNetInit()


Return( cRdaCodNet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNivelInit	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDA_NIVEL					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDA_NIVEL								�
�������������������������������������������������������������������������/*/
Function RdaNivelInit()

Local cRdaNivelInit	:= Space( GetSx3Cache("RDA_NIVEL","X3_TAMANHO" ) )
cRdaNivelInit	:= R270NivelInit()


Return( cRdaNivelInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaDtiAvaVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDA_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDA_DTIAVA									�
�������������������������������������������������������������������������/*/
Function RdaDtiAvaVld()

Local lRdaDtiAvaOk := .T.

Begin Sequence

	IF !( lRdaDtiAvaOk := NaoVazio() )
		Break
	EndIF

End Sequence

Return( lRdaDtiAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaDtiAvaInit    �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDA_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDA_DTIAVA								�
�������������������������������������������������������������������������/*/
Function RdaDtiAvaInit()

Local dRdaDtiAvaInit	:= Ctod("//")
dRdaDtiAvaInit	:= R270DtiAvaInit()


Return( dRdaDtiAvaInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaDtfAvaVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDA_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDA_DTFAVA									�
�������������������������������������������������������������������������/*/
Function RdaDtfAvaVld()

Local lRdaDtfAvaOk := .T.

Begin Sequence

	IF !( lRdaDtfAvaOk := NaoVazio() )
		Break
	EndIF

End Sequence

Return( lRdaDtfAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaDtfAvaInit    �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDA_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDA_DTFAVA								�
�������������������������������������������������������������������������/*/
Function RdaDtfAvaInit()

Local dRdaDtfAvaInit	:= Ctod("//")
dRdaDtfAvaInit	:= R270DtfAvaInit()

Return( dRdaDtfAvaInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaNivelBox		 �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Box do Campo RDA_NIVEL										�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RDA_NIVEL  								�
�������������������������������������������������������������������������/*/
Function RdaNivelBox()
Return( OpBxNivel( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaTipoAvVld 	 �Autor�Marinaldo de Jesus� Data �02/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDA_TIPOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDA_TIPOAV								�
�������������������������������������������������������������������������/*/
Function RdaTipoAvVld()

Local lRdaTipoAvOK := .T.

Local bInitPad
Local cInitPad
Local cMsgInfo
Local nPosColBmp
Local uInitPad

Begin Sequence

	IF !( lRdaTipoAvOK := NaoVazio() )
		Break
	EndIF

	IF !( lRdaTipoAvOK := Pertence( OpBxTipoAv( .T. ) ) )
		Break
	EndIF

	IF Apda080Fldrs()
		IF IsInGetDados( { "COLBMP" , "RDA_TIPOAV" } )
			IF !( lRdaTipoAvOK := RdaGdDelOk( 4 , .T. , .F. ) )
				cMsgInfo := STR0052	//"O Campo:"
				cMsgInfo += aHeader[ GdFieldPos( "RDA_TIPOAV") , 01  ]
				cMsginfo += " "
				cMsginfo += STR0053	//"n�o pode ser alterado."
				cMsginfo += CRLF
				cMsgInfo += STR0054	//"J� existe avalia��o respondida com esse tipo."
				//"Aviso de Inconsistencia!"
				MsgInfo( OemToAnsi( cMsgInfo ) , STR0022 )
				Break
			EndIF
			nPosColBmp	:= GdFieldPos( "COLBMP" )
			IF ( nPosColBmp > 0 )
				cInitPad	:= aHeader[ nPosColBmp , 12 ]
				IF !Empty( cInitPad )
					GdFieldPut( "RDA_TIPOAV" , GetMemVar( "RDA_TIPOAV" ) )
					bInitPad := &( " { || uInitPad := " + cInitPad + " } " )
					IF CheckExecForm( bInitPad , .F. )
						GdFieldPut( "COLBMP" , uInitPad )
					EndIF
				EndIF
			EndIF
		EndIF
	EndIF

End Sequence

Return( lRdaTipoAvOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaTipoAvInit 	 �Autor�Marinaldo de Jesus� Data �02/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDA_TIPOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDA_TIPOAV								�
�������������������������������������������������������������������������/*/
Function RdaTipoAvInit()
Return( GetTpAvDor() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdaTipoAvBox 	 �Autor�Marinaldo de Jesus� Data �02/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �OpcBox do Campo RDA_TIPOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RDA_TIPOAV									�
�������������������������������������������������������������������������/*/
Function RdaTipoAvBox()
Return( OpBxTipoAv( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodAvaVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDC_CODAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDC_CODAVA									�
�������������������������������������������������������������������������/*/
Function RdcCodAvaVld()

Local lRdcCodAvaOk := .T.

Begin Sequence

	IF !( lRdcCodAvaOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdcCodAvaOk := ExistCpo( "RD6" ) )
		Break
	EndIF

End Sequence

Return( lRdcCodAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodAdoVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDC_CODADO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDC_CODADO									�
�������������������������������������������������������������������������/*/
Function RdcCodAdoVld()

Local lRdcCodAdoOk := .T.

Begin Sequence

	IF !( lRdcCodAdoOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdcCodAdoOk := ExistCpo( "RD0" ) )
		Break
	EndIF

End Sequence

Return( lRdcCodAdoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodProVld	 �Autor�Marinaldo de Jesus� Data �02/09/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid para o Campo RdC_CODPRO            					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RdC_CODPRO   								�
�������������������������������������������������������������������������/*/
Function RdcCodProVld()

Local lRdcCodProOk := .T.

Begin Sequence

	IF ( Vazio() )
		Break
	EndIF

	IF !( lRdcCodProOk := ExistCpo( "RDN" ) )
		Break
	EndIF

End Sequence

Return( lRdcCodProOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodDorVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDC_CODDOR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDC_CODDOR									�
�������������������������������������������������������������������������/*/
Function RdcCodDorVld()

Local lRdcCodDorOk := .T.

Begin Sequence

	IF !( lRdcCodDorOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdcCodDorOk := ExistCpo( "RD0" ) )
		Break
	EndIF

End Sequence

Return( lRdcCodDorOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDtiAvaVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDC_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDC_DTIAVA									�
�������������������������������������������������������������������������/*/
Function RdcDtiAvaVld()

Local lRdcDtiAvaOk := .T.

Begin Sequence

	IF !( lRdcDtiAvaOk := NaoVazio() )
		Break
	EndIF

End Sequence

Return( lRdcDtiAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDtiAvaInit    �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDC_DTIAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDC_DTIAVA								�
�������������������������������������������������������������������������/*/
Function RdcDtiAvaInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDtfAvaVld     �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDC_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Valid do Campo RDC_DTFAVA									�
�������������������������������������������������������������������������/*/
Function RdcDtfAvaVld()

Local lRdcDtfAvaOk := .T.

Begin Sequence

	IF !( lRdcDtfAvaOk := NaoVazio() )
		Break
	EndIF

End Sequence

Return( lRdcDtfAvaOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDtfAvaInit    �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDC_DTFAVA									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDC_DTFAVA								�
�������������������������������������������������������������������������/*/
Function RdcDtfAvaInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodNetVld	 �Autor�Marinaldo de Jesus� Data �22/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_CODNET									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_CODNET								�
�������������������������������������������������������������������������/*/
Function RdcCodNetVld()

Local lRdcCodNetOk := .T.

Local cRdcCodTip
Local cRdcCodNet
Local nRdhOrder

Begin Sequence

	IF !( lRdcCodNetOk := NaoVazio() )
		Break
	EndIF

	IF ( IsInGetDados( { "RDC_CODTIP" } ) )
		cRdcCodTip := GdFieldGet( "RDC_CODTIP" )
	Else
		cRdcCodTip := GetMemVar( "RDC_CODTIP" )
	EndIF
	cRdcCodNet := GetMemVar( ReadVar() )

	nRdhOrder := RetOrdem( "RDH" , "RDH_FILIAL+RDH_CODTIP+RDH_CODNET" )
	IF !( lRdcCodNetOk := ExistCpo( "RDH" , cRdcCodTip + cRdcCodNet , nRdhOrder ) )
		Break
	EndIF

End Sequence

Return( lRdcCodNetOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcNivelVld		 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_NIVEL									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_NIVEL									�
�������������������������������������������������������������������������/*/
Function RdcNivelVld()

Local lRdcNivelOk := .T.

Begin Sequence

	IF !( lRdcNivelOk := NaoVazio() )
		Break
	EndIF

	IF !( lRdcNivelOk := Pertence( OpBxNivel( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdcNivelOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcNivelBox		 �Autor�Marinaldo de Jesus� Data �21/11/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Box do Campo RDC_NIVEL										�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RDC_NIVEL  								�
�������������������������������������������������������������������������/*/
Function RdcNivelBox()
Return( OpBxNivel( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcChkEnvVld	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_CHKENV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_CHKENV								�
�������������������������������������������������������������������������/*/
Function RdcChkEnvVld()

Local lRdcChkEnvOk := .T.

Begin Sequence

	IF !( lRdcChkEnvOk := Pertence( OpBxSimNao( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdcChkEnvOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcChkEnvBox �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_CHKENV         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RDC_CHKENV                         	�
�������������������������������������������������������������������������/*/
Function RdcChkEnvBox()
Return( OpBxSimNao( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcChkEnvInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_CHKENV         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_CHKENV                         	�
�������������������������������������������������������������������������/*/
Function RdcChkEnvInit()
Return( SubStr( OpBxSimNao( .T. ) , 2 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcAtivoVld	 	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_ATIVO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_ATIVO									�
�������������������������������������������������������������������������/*/
Function RdcAtivoVld()
Return( Rd6StatusVld() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcAtivoBox  �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_ATIVO         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RDC_ATIVO   	                      	�
�������������������������������������������������������������������������/*/
Function RdcAtivoBox()
Return( Rd6StatusBox() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcAtivoInit �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_ATIVO         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_ATIVO                         	�
�������������������������������������������������������������������������/*/
Function RdcAtivoInit()

Local cRdcAtivoInit

IF IsMemVar( "RD6_STATUS" )
	cRdcAtivoInit := GetMemVar( "RD6_STATUS" )
Else
	cRdcAtivoInit := RD6->RD6_STATUS
EndIF

Return( cRdcAtivoInit )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcTipoVld	 	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_TIPO									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_TIPO									�
�������������������������������������������������������������������������/*/
Function RdcTipoVld()

Local lRdcTipoOk := .T.

Begin Sequence

	IF !( lRdcTipoOk := Pertence( OpBxPdEnRt( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdcTipoOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcTipoBox   �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_TIPO         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX para o campo RDC_TIPO   	                      	�
�������������������������������������������������������������������������/*/
Function RdcTipoBox()
Return( OpBxPdEnRt( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcTipoInit  �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_TIPO         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_TIPO                         	�
�������������������������������������������������������������������������/*/
Function RdcTipoInit()
Return( SubStr( OpBxPdEnRt( .T. ) , 1 , 1 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDatEnvVld 	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_DATENV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_DATENV								�
�������������������������������������������������������������������������/*/
Function RdcDatEnvVld()

Local lRdcDatEnvOk := .T.

Return( lRdcDatEnvOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDatEnvInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_DATENV         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_DATENV                         	�
�������������������������������������������������������������������������/*/
Function RdcDatEnvInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDatRetVld 	 �Autor�Marinaldo de Jesus� Data �17/12/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_DATRET									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_DATRET								�
�������������������������������������������������������������������������/*/
Function RdcDatRetVld()

Local lRdcDatRetOk := .T.

Return( lRdcDatRetOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDatRetInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_DATRET         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_DATRET                         	�
�������������������������������������������������������������������������/*/
Function RdcDatRetInit()
Return( Ctod("//") )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcIdentVld  �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Validar o Conteudo do Campo RDC_IDENT         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID para o campo RDC_IDENT                         	�
�������������������������������������������������������������������������/*/
Function RdcIdentVld()
Return( .T. )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcIdentInit �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_IDENT         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_IDENT                         	�
�������������������������������������������������������������������������/*/
Function RdcIdentInit()
Return( Space( GetSx3Cache( "RDC_IDENT" , "X3_TAMANHO" ) ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcQtdCobVld �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Validar o Conteudo do Campo RDC_QTDCOB         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID para o campo RDC_QTDCOB                         	�
�������������������������������������������������������������������������/*/
Function RdcQtdCobVld()

Local lRdcQtdCobOk := .T.

Begin Sequence

	IF !( lRdcQtdCobOk := Positivo() )
		Break
	EndIF

End Sequence

Return( lRdcQtdCobOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcUserVld   �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Validar o Conteudo do Campo RDC_USER         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID para o campo RDC_USER	                         	�
�������������������������������������������������������������������������/*/
Function RdcUserVld()

Local lRdcUserOk := .T.

Begin Sequence

	IF ( Vazio() )
		Break
	EndIF

	IF !( lRdcUserOk := UsrExist( GetMemVar( "RDC_USER" ) ) )
		Break
	EndIF

End Sequence

Return( lRdcUserOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcUsrNamInit�Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Retornar as Opcoes do Campo RDC_USRNAM         	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_USRNAM                         	�
�������������������������������������������������������������������������/*/
Function RdcUsrNamInit( cCodUser )

DEFAULT cCodUser := RDC->RDC_USER

Return( UsrRetName( cCodUser ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcTipoAvVld 	 �Autor�Marinaldo de Jesus� Data �02/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valid do Campo RDC_TIPOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do Campo RDC_TIPOAV								�
�������������������������������������������������������������������������/*/
Function RdcTipoAvVld()

Local lRdcTipoAvOK := .T.

Begin Sequence

	IF !( lRdcTipoAvOK := NaoVazio() )
		Break
	EndIF

	IF !( lRdcTipoAvOK := Pertence( OpBxTipoAv( .T. ) ) )
		Break
	EndIF

End Sequence

Return( lRdcTipoAvOK )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcTipoAvInit 	 �Autor�Marinaldo de Jesus� Data �02/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Init do Campo RDC_TIPOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do Campo RDC_TIPOAV								�
�������������������������������������������������������������������������/*/
Function RdcTipoAvInit()
Return( GetTpAvDor() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcTipoAvBox 	 �Autor�Marinaldo de Jesus� Data �02/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �OpcBox do Campo RDC_TIPOAV									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_CBOX do Campo RDC_TIPOAV									�
�������������������������������������������������������������������������/*/
Function RdcTipoAvBox()
Return( OpBxTipoAv( .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodTipVld	 �Autor�Marinaldo de Jesus� Data �20/07/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_CODTIP									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_CODTIP								�
�������������������������������������������������������������������������/*/
Function RdcCodTipVld()
Return( NaoVazio() .and. ExistCpo( "RD5" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcCodTipInit	 �Autor�Marinaldo de Jesus� Data �20/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDC_CODTIP					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDC_CODTIP								�
�������������������������������������������������������������������������/*/
Function RdcCodTipInit()
Return( GetMemVar( "RD6_CODTIP" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDtLimRVld	 �Autor�Marinaldo de Jesus� Data �20/07/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar o Campo RDC_DTLIMR									�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID do campo RDC_DTLIMR								�
�������������������������������������������������������������������������/*/
Function RdcDtLimRVld()
Return( NaoVazio() )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcDtLimRInit	 �Autor�Marinaldo de Jesus� Data �20/07/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializadora Padrao do Campo RDC_DTLIMR					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO do campo RDC_DTLIMR								�
�������������������������������������������������������������������������/*/
Function RdcDtLimRInit()
Return( Ctod( "//" ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcIdVld	 �Autor�Marinaldo de Jesus    � Data �22/09/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Validar o Conteudo do Campo RDC_ID          	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_VALID para o campo RDC_ID                         		�
�������������������������������������������������������������������������/*/
Function RdcIdVld()

Local cRdcId	:= GetMemVar( "RDC_ID" )
Local lRdcIDOk	:= .T.

Begin Sequence

	IF !( lRdcIDOk := RdcGetId( @cRdcId , .F. , .T. ) )
    	Break
    EndIF

    SetMemVar( "RDC_ID" , cRdcId )

End Sequence

Return( lRdcIDOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcGetId 	 �Autor�Marinaldo de Jesus    � Data �22/09/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem Numeracao Valida para o RDC_ID                    	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Obter Numeracao valida para o RDC_ID                 		�
�������������������������������������������������������������������������/*/
Function RdcGetId( cRdcId , lExistChav , lShowHelp )
Return(;
			GetNrExclOk(	@cRdcId 			,;
							"RDC"				,;
							"RDC_ID"			,;
							"RDC_FILIAL+RDC_ID" ,;
							NIL					,;
							lExistChav			,;
							lShowHelp	 		,;
							xFilial("RDC")		,;
							"P"					 ;
						);
		)

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RdcIdInit	 �Autor�Marinaldo de Jesus    � Data �06/10/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializador padrao para o Campo RDC_ID          			�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �X3_RELACAO para o campo RDC_ID                         		�
�������������������������������������������������������������������������/*/
Function RdcIdInit()

Local IsInGetDados	:= IsInGetDados( { "RDC_ID" } )
Local cRdcId

IF ( IsInGetDados )
	CursorWait()
	cRdcId := GdNumItem( "RDC_ID" )
EndIF

If Empty(RDC->RDC_ID)
	RdcGetId( @cRdcId , .F. , .F. )
Endif

IF ( IsInGetDados )
	CursorArrow()
EndIF

Return( cRdcId )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apda080DtOk� Autor �Marinaldo de Jesus    � Data �27/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida as Datas para a Avaliacao                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Apda080()	                                                �
�������������������������������������������������������������������������/*/
Static Function Apda080DtOk( dPerIni , dPerFim , dDataIni , dDataFim )

Local lApda080DtOk := .F.

Begin Sequence

	IF ( dDataFim < dPerIni )
		Break
	EndIF

	IF ( dDataIni > dPerFim )
		Break
	EndIF

	lApda080DtOk := .T.

End Sequence

Return( lApda080DtOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Rd9GdChgInfo	 �Autor�Marinaldo de Jesus� Data �05/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Change nas Alteracoes dos Campos chaves do RD9				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APDA080                        								�
�������������������������������������������������������������������������/*/
Static Function Rd9GdChgInfo( cRd9NewCodPro , dRd9NewDtiAva , dRd9NewDtfAva )

Local bAeval
Local cRd9CodAdo
Local cRd9LstCodPro
Local dRd9LstDtiAva
Local dRd9LstDtfAva
Local nRdaCodAdo
Local nRdaCodPro
Local nRdaDtiAva
Local nRdaDtfAva

Begin Sequence

	IF !( Apda080Fldrs() )
		Break
	EndIF

	cRd9CodAdo		:= GdFieldGet( "RD9_CODADO" )
	cRd9LstCodPro	:= GdFieldGet( "RD9_CODPRO" )
	dRd9LstDtiAva	:= GdFieldGet( "RD9_DTIAVA" )
	dRd9LstDtfAva	:= GdFieldGet( "RD9_DTFAVA" )

	oGdRda			:= oGdRdaGet( APDA270_FOLDER_AVALIADORES )
	aRdaColsAll		:= RdaColsGet()
	nRdaCodAdo		:= GdFieldPos( "RDA_CODADO" , oGdRda:aHeader )
	nRdaCodPro		:= GdFieldPos( "RDA_CODPRO" , oGdRda:aHeader )
	nRdaDtiAva		:= GdFieldPos( "RDA_DTIAVA" , oGdRda:aHeader )
	nRdaDtfAva		:= GdFieldPos( "RDA_DTFAVA" , oGdRda:aHeader )

	bAeval			:= { |x| IF(;
									( x[nRdaCodAdo] == cRd9CodAdo 	 ) .and. ;
									( x[nRdaCodPro] == cRd9LstCodPro ) .and. ;
									( x[nRdaDtiAva] == dRd9LstDtiAva ) .and. ;
									( x[nRdaDtfAva] == dRd9LstDtfAva )		,;
										(;
											( x[nRdaCodPro] := cRd9NewCodPro ),;
											( x[nRdaDtiAva] := dRd9NewDtiAva ),;
											( x[nRdaDtfAva] := dRd9NewDtfAva );
										),;
									NIL;
								 );
					  }

	aEval( oGdRda:aCols , bAeval )
	aEval( aRdaColsAll	, bAeval )

End Sequence

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apda080Fldrs  �Autor �Marinaldo de Jesus  � Data �11/08/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica a Existencia do aFoldes                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Apda080()	                                                �
�������������������������������������������������������������������������/*/
Static Function Apda080Fldrs()
Return(;
		( Type( "aFolders" ) == "A" );
		.and.;
		!Empty( aFolders );
		.and.;
		( Len( aFolders ) == APDA270_ELEMENTOS_FOLDER );
	  )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �fOpcRepBox  �Autor �Marcelo Faria � Data �23/06/2016       �
�����������������������������������������������������������������������Ĵ
�Descri��o �fop��o para controle de consenso                           �
�������������������������������������������������������������������������/*/
Function fOpcRepBox()
Local cOpcBox	:= ""

	cOpcBox += ( "1=" + OemToAnsi( STR0157 ) + ";"	)	//"1=N�o Replicar;"
	cOpcBox += ( "2=" + OemToAnsi( STR0158 ) + ";"	)	//"2=Replicar e liberar resposta/justificativa;"
	cOpcBox += ( "3=" + OemToAnsi( STR0159 ) + ";"	)	//"3=Replicar, bloquear resposta e liberar justificativa;"
	cOpcBox += ( "4=" + OemToAnsi( STR0160 ) 	     	)	//"4= Replicar e bloquear resposta/justificativa;"

Return( cOpcBox )

/*/{Protheus.doc} OpenLink
Abre o navegador padr�o com a p�gina passada por par�metro, por padr�o abre o TDN (http://tdn.totvs.com)
@author cicero.pereira
@since 10/09/2019
@param cURL, caractere, URL da p�gina que ser� aberta
@version 12.1.17
/*/
Function OpenLink(cURL)

	Default cURL := "http://tdn.totvs.com"

	shellExecute("Open", cURL, "", "", SW_NORMAL)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} fBuscPart
Funcao que retorna os participantes alocados na vis�o respeitando os filtros do criterio.

@author		Silvio C. Stecca
@since		09/11/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fBuscPart(cRdeFil, cRd6CodVis, cRdeStatus, cRdtCriter)

	Local aArea		:= GetArea()
	Local cCriterio	:= ""
	Local cQryRDE	:= ""
	Local aCposTMP	:= {}	

	cCriterio := StrTran(cRdtCriter	, "->"		, ".")
	cCriterio := StrTran(cCriterio	, "("		, "")
	cCriterio := StrTran(cCriterio	, ")"		, "")
	cCriterio := StrTran(cCriterio	, "=="		, "=")
	cCriterio := StrTran(cCriterio	, '"'		, "'")

	If "AND" $ cCriterio
		cCriterio := StrTran(cCriterio	, ".AND.", " AND ")
	EndIf

	If "OR" $ cCriterio
		cCriterio := StrTran(cCriterio	, ".OR.", " OR ")
	EndIf

	// FECHA O ALIAS CASO ESTEJA SENDO USADO.
	If (Select(cArqPart) > 0)
		(cArqPart)->(DbCloseArea())
	EndIf

	// Cria tabela tempor�ria RDE com C�d. Vis�o do pergunte e status ativo
	aAdd(aCposTMP, {"RDE_FILIAL"	, "C", FwSizeFilial()		 		, 0 })
	aAdd(aCposTMP, {"RDE_CODPAR"	, "C", TamSX3("RDE_CODPAR")[1]	 	, 0 })
	aAdd(aCposTMP, {"RDE_CODVIS"	, "C", TamSX3("RDE_CODVIS")[1]	 	, 0 })
	aAdd(aCposTMP, {"RDE_ITEVIS"	, "C", TamSX3("RDE_ITEVIS")[1]	 	, 0 })
	aAdd(aCposTMP, {"RDE_DATA"		, "C", TamSX3("RDE_DATA")[1]	 	, 0 })
	aAdd(aCposTMP, {"RDE_STATUS"	, "C", TamSX3("RDE_STATUS")[1]	 	, 0 })
	aAdd(aCposTMP, {"RDE_RESP"		, "C", TamSX3("RDE_RESP")[1]		, 0 })

	oTabRDE := FWTemporaryTable():New(cArqTMP1, aCposTMP)
	oTabRDE:AddIndex("01", {'RDE_FILIAL', 'RDE_CODPAR', 'RDE_CODVIS', 'RDE_ITEVIS'})
	oTabRDE:AddIndex("02", {'RDE_FILIAL', 'RDE_CODVIS', 'RDE_ITEVIS', 'RDE_STATUS', 'RDE_CODPAR'})
	oTabRDE:Create()

	cQryRDE := "SELECT RDE_FILIAL, RDE_CODPAR, RDE_CODVIS, RDE_ITEVIS, RDE_DATA, RDE_STATUS, RDE_RESP"	+ CRLF
	cQryRDE += "FROM " + RetSqlName("RDE") + " RDE"														+ CRLF
	cQryRDE += "INNER JOIN " + RetSQLName("RD0") + " RD0"												+ CRLF
	cQryRDE += "ON "																					+ CRLF
	cQryRDE += "RD0.RD0_FILIAL = RDE.RDE_FILIAL"														+ CRLF
	cQryRDE += "AND RD0.RD0_CODIGO = RDE.RDE_CODPAR"													+ CRLF
	cQryRDE += "AND " + cCriterio																		+ CRLF
	cQryRDE += "AND RD0.D_E_L_E_T_ = ''"																+ CRLF
	cQryRDE += "WHERE" 																					+ CRLF
	cQryRDE += "RDE.RDE_FILIAL = '" + cRdeFil + "'"														+ CRLF
	cQryRDE += "AND RDE.RDE_CODVIS = '" + cRd6CodVis + "'"												+ CRLF
	cQryRDE += "AND RDE.RDE_STATUS = '" + cRdeStatus + "'"												+ CRLF
	cQryRDE += "AND RDE.D_E_L_E_T_ = ''"																+ CRLF
	cQryRDE += "ORDER BY RDE_FILIAL, RDE_CODPAR"														+ CRLF

	cQryRDE := ChangeQuery(cQryRDE)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryRDE), cArqPart, .T., .T.)

	dbSelectArea(cArqPart)
	(cArqPart)->(dbGoTop())

	While !(cArqPart)->(Eof())
		RecLock(cArqTMP1, .T.)
			(cArqTMP1)->RDE_FILIAL	:= (cArqPart)->RDE_FILIAL
			(cArqTMP1)->RDE_CODPAR	:= (cArqPart)->RDE_CODPAR
			(cArqTMP1)->RDE_CODVIS	:= (cArqPart)->RDE_CODVIS
			(cArqTMP1)->RDE_ITEVIS	:= (cArqPart)->RDE_ITEVIS
			(cArqTMP1)->RDE_DATA	:= (cArqPart)->RDE_DATA
			(cArqTMP1)->RDE_STATUS	:= (cArqPart)->RDE_STATUS
			(cArqTMP1)->RDE_RESP	:= (cArqPart)->RDE_RESP
		MsUnLock()

		(cArqPart)->(dbSkip())

	EndDo
	
	// RESTAURA A AREA.
	RestArea(aArea)

Return Nil
