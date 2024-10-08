#INCLUDE "RWMAKE.CH" 
#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"

#define STR0001 "Pesquisar"
#define STR0002 "Captura Foto"
#define STR0003 "Impress�o de Crach�s"
#define STR0004 "Obtem foto"
#define STR0005 "Foto"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CAPFOTO  � Autor � Equipe RH             � Data � 05/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Captura de fotos.                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CAPFOTO()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��� Equipe RH  �22/08/06�------� Transformado em RDMAKE.                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function GPER1018()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cFiltraSRA			//Variavel para filtro
LOCAL aIndexSRA	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro
Private	cPerg	:= "PNA900"
Private aInfo	:= {}
Private nDepen	:= 0
Private aRegs	:= {}


//��������������������������������������������������������������Ŀ
//� Define array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina := { 	{ STR0001 , "PesqBrw"  , 0 , 1},;  //"Pesquisar" 
						{ STR0002 , "pn900Capt", 0 , 4}} //"Captura da Foto"
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0003)  //"Impressao de Crachas"
//��������������������������������������������������������������Ŀ
//� Verifica se o Arquivo Esta Vazio                             �
//����������������������������������������������������������������
If !ChkVazio("SRA")
	Return
Endif
	
//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh := CHKRH("CAPFOTO","SRA","1")
cFiltraRh := cFiltraRh + if(empty(cFiltraRh),'RA_SITFOLH <> "D"','.AND. RA_SITFOLH <> "D"')
bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
Eval(bFiltraBrw)
	
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SRA")
dbGoTop()
mBrowse( 6, 1,22,75,"SRA" , NIL , NIL , NIL , NIL , NIL , fCriaCor() )
	
//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SRA",aIndexSra)

return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � pn900Capt� Autor � Equipe RH             � Data � 09/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa captura e inclusao de fotos no repositorio de     ���
���          � imagens e no cadastro de funcionarios.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � pn900Capt(cAlias,nReg,nOpc)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAlias  Alias do arquivo                                   ���
���          � nReg    Numero do registro                                 ���
���          � nOpc    Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � pn900Capt                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function pn900Capt(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local aSvKeys		:= GetKeys()
Local aEnchoice		:= {}
Local aFields		:= {}
Local aAltera		:= {}
Local aNaoAltera	:= {}
Local aVirtChoice	:= {}
Local aVisual		:= {}
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aBotoes		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local nOpcAlt		:= 0.00
Local nX			:= 0.00
Local nXs			:= 0.00
Local oDlg			:= NIL
Local oEnchoice		:= NIL	
Local lGravouFoto	:= .F.     //Variavel Se Gravou a Foto

Private aFotos		:= {}		//Variavel para Fotos Capturadas
Private bGetFoto	:= { || NIL }

Private aGets[0]
Private aTela[0][0]

Begin Sequence
	
	/*
	��������������������������������������������������������������Ŀ
	� Monta os Dados para a Enchoice							   �
	����������������������������������������������������������������*/
	
	aEnChoice := SRA->( GdMontaHeader( NIL , @aVirtChoice , @aVisual , NIL , { "RA_FILIAL","RA_MAT","RA_CC","RA_DESCCC","RA_NOME","RA_ADMISSA","RA_BITMAP","RA_APELIDO"},,,,.T.,,,,.F. ) ) 
	
	/*
	��������������������������������������������������������������Ŀ
	� Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar�
	� quivo														   �
	����������������������������������������������������������������*/
	nXs := Len( aEnChoice )
	For nX := 1 To nXs
		aAdd( aFields , aEnchoice[ nX , 02 ] )
		IF ( aScan( aVirtChoice , { |cVirt| cVirt ==  aEnchoice[ nX , 02 ] } ) == 0.00 )
			&( "M->"+aEnchoice[ nX , 02 ] ) := SRA->( &( aEnchoice[ nX , 02 ] ) )
		Else
			&( "M->"+aEnchoice[ nX , 02 ] ) := CriaVar( aEnchoice[ nX , 02 ] )
		EndIF
		/*
		��������������������������������������������������������������Ŀ
		�Neste Ponto Carrega os Inicializadores padroes para campos  vi�
		�suais														   �
		����������������������������������������������������������������*/
		IF ( aScan( aVisual , { |cVisu| cVisu ==  aEnchoice[ nX , 02 ] } ) > 0.00 )
			IF Empty( &( "M->"+aEnchoice[ nX , 02 ] ) )
				&( "M->"+aEnchoice[ nX , 02 ] ) := CriaVar( aEnchoice[ nX , 02 ] )
			EndIF
		EndIF
	Next nX

	Aadd(aFields ,"NOUSER" )
	
	/*
	��������������������������������������������������������������Ŀ
	�Define os Campos Editaveis na Enchoice Apenas na Alteracao(4) �
	����������������������������������������������������������������*/
	IF nOpc == 4

		/*
		��������������������������������������������������������������Ŀ
		� Define os Campos Editaveis								   �
		����������������������������������������������������������������*/
		nXs := Len( aVisual )
		For nX := 1 To nXs
			aAdd( aNaoAltera , aVisual[ nX ] )
		Next nX
		aAdd( aNaoAltera , "RA_MAT" )
		aAdd( aNaoAltera , "RA_CC" )
		aAdd( aNaoAltera , "RA_NOME" )
		aAdd( aNaoAltera , "RA_ADMISSA" )
		aAdd( aNaoAltera , "RA_RG" )
		aAdd( aNaoAltera , "RA_CIC" )
		aAdd( aNaoAltera , "RA_APELIDO" )
		nXs := Len( aFields )
		For nX := 1 To nXs
			IF ( aScan( aNaoAltera , { |cNaoA| cNaoA == aFields[ nX ] } ) == 0.00 )
				aAdd( aAltera , aFields[ nX ] )
			EndIF
		Next nX
	
	EndIF
	
	/*
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 300 , .T. , .T. } ) 
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	/*
	��������������������������������������������������������������Ŀ
	� Monta o Dialogo Principal para a Manutencao das Formulas	   �
	����������������������������������������������������������������*/
	nOpcAlt := 0.00
	SetaPilha()
		DEFINE MSDIALOG oDlg TITLE OemToAnsi( cCadastro ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
			oEnchoice	:= MsmGet():New( "SRA" , nReg , nOpc , NIL , NIL , NIL , aFields  , aObjSize[1] , aAltera  , NIL , NIL , NIL , oDlg , NIL , .F. )
			bSet15		:= { || IF( Obrigatorio( aGets , aTela ) , ( nOpcAlt := 1.00 , oDlg:End() ) , ( nOpcAlt := 0.00 , .F. ) ) }
			bSet24		:= { || ( nOpcAlt := 0.00 , oDlg:End() ) }
			bGetFoto	:= { || lGravouFoto:= Pn900GetFoto((xFilial("SRA")+M->RA_MAT), @aFotos, @oEnchoice)}
			aAdd(; 
					aBotoes	,;
					{;
						"MAQFOTO"			 ,;	
						bGetFoto			 ,;
						OemToAnsi( STR0004 ) ,;	//"Obtem Foto <F4>..."
						OemToAnsi( STR0005 ) ;	//"Foto"
					};
				)	    

		 SetKEY(VK_F4,bGetFoto)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ,, aBotoes ) CENTERED
	SetaPilha()
	
	/*
	��������������������������������������������������������������Ŀ
	�Quando Confirmada a Opcao e Nao for Visualizacao Grava ou   Ex�
	�clui as Informacoes do SRA         				   		   �
	����������������������������������������������������������������*/
	IF ( ( nOpcAlt == 1 ) .and. ( nOpc != 2 ) )
		/*
		��������������������������������������������������������������Ŀ
		� Gravando a foto no campo RA_BITMAP do funcionario.           �
		����������������������������������������������������������������*/
		Pn900Grava(nOpc,nReg,lGravouFoto)
	EndIF

End Sequence
	
/*
��������������������������������������������������������������Ŀ
�Restaura os Dados de Entrada								   �
����������������������������������������������������������������*/
( RestKeys( aSvKeys ) , RestArea( aArea ) )

Return( nOpcAlt )

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Funcao    �Pn900GetFoto	 � Autor � Equipe RH             � Data �06.04.2004���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao p/ Captura de Foto								       ���
������������������������������������������������������������������������������Ĵ��
���Retorno   � 			                                                       ���
������������������������������������������������������������������������������Ĵ��
���Parametros�						   		  								   ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             	   ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     	   ���
������������������������������������������������������������������������������Ĵ��
���            �        �      �                                               ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������/*/   
Static function Pn900GetFoto(cIdFile, aFotos, oEnchoice)
                                    
Local lRet		:= .T.

Local cFileJpg	:= '' 
Local cPathSrv	:= ''
Local cPathFile	:= ''
Local cDestFile := ''

Local nHDImgDll	:= 0  
Local nRet		:= 0                                 

cPathSrv	:= Upper(GetTempPath())
cFileJpg	:=	Alltrim(cIdFile)+'.jpg'
cPathFile	:= UPPER(cPathSrv+cFileJpg)

Begin Sequence
  
  	RPCSETTYPE(3)
	
	nHDImgDll := ExecInDLLOpen("IMAGELOAD.DLL")
	If nHDImgDLL == -1
	   Alert("Falha ao carregar a DLL 'IMAGELOAD.DLL'.") 
       lRet	:=.F.
	   Break
	EndIf           
	                                             
	// Passar como par�metro, o diret�rio na m�quina CLIENTE + NOME �NICO
	nRet:=ExeDLLRun2( nHDImgDll, 0, cPathFile) 
	If nRet == -1
	   Alert("Falha ao carregar o arquivo "+cPathFile) 
       lRet	:=.F.
	   Break
	EndIf 
	
	ExecInDLLClose( nHDImgDll)
	
    Pn900IncFoto(cIdFile)
    M->RA_BITMAP:=cIdFile  
    oEnchoice:aEntryCtrls[ 1 ]:Refresh()
    oEnchoice:Refresh()
    
    //-- Armazena Fotos para Posterior Eliminacao
    aadd(aFotos,{cPathFile, cDestFile } )
    
    //-- Verifica se Gravou em um dos Locais
    lRet:= ( File(cPathFile) .OR. File(cDestFile) )
End  

Return lRet
            
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �Pn900IncFoto � Autor � Equipe RH             � Data � 06/04/04 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Coloca a Foto no Repositorio        						  	 ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �Pn900IncFoto(cIdFile)										     ���
����������������������������������������������������������������������������Ĵ��
���Parametros� cIdFile - Identificador da Foto (xFilial("SRA")+M->RA_MAT)    ���
����������������������������������������������������������������������������Ĵ��
���Retorno   � lFile - Logico de Retorno de Sucesso da Inclusao da Foto      ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Pona900                                                       ���
����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             	 ���
����������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     	 ���
����������������������������������������������������������������������������Ĵ��
���            �        �      �                                             ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/
Static Function Pn900IncFoto(cIdFile)

Local cDirAtu	:= ""

Local lFile		:= .T.
Local oDlg8
Local oBmp

/*
��������������������������������������������������������������Ŀ
� Inclui a Foto              								   �
����������������������������������������������������������������*/

DEFINE MSDIALOG oDlg8   FROM -1000,400 TO 1600,800  PIXEL 

@ 000, 000 REPOSITORY oBmp SIZE 60, 73 OF oDlg8    

lFile	:= fPutFoto(@oBmp, cIdFile )

ACTIVATE MSDIALOG oDlg8 ON INIT (oBmp:lStretch := .T.,oDlg8:End())

Return lFile

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fPutFoto  � Autor � Equipe RH             � Data � 06/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Insere  a Foto no Repositorio          					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fPutFoto(oBmp,cIdFile)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cIdFile 	- Caminho do \RootPath							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lFile - Logico representado que Incluiu a Foto             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Pona900                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fPutFoto(oBmp,cIdFile)
Local lFile 	:= .T. 
Local cFileJpg	:= '' 
Local lIncluiu	:= .F.

cFileJpg		:=	Alltrim(cIdFile)+'.jpg'
cPathPict   	:= Upper(GetTempPath()+cFileJpg) 

		
IF !Empty( cPathPict)
	IF ( lFile	:= File( cPathPict) )                
		
		lFile	:= !Empty(oBmp:InsertBmp(cPathPict,,@lIncluiu))

		IF lFile .AND. lIncluiu
			oBmp:LoadBmp(cPathPict)
			oBmp:Refresh()
		Else
			Alert("Falha ao Incluir a Imagem no Repositorio") 
		Endif
		
	EndIF
EndIF

Return (lFile)

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Pn900Grava   �Autor� Equipe RH            � Data �09/08/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Pona900()	                                                �
�������������������������������������������������������������������������*/
Static Function Pn900Grava(		nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( SRA )
							 	lGravouFoto  ;  //Se Capturou a Foto
							  )


Local lLock			:= .F.

DEFAULT nOpc		:= 0.00
DEFAULT nReg		:= 0.00

/*
��������������������������������������������������������������Ŀ
� Se for Inclusao/Alteracao ( nOpc == 3 .or. nOpc == 4 )	   �
����������������������������������������������������������������*/
IF nOpc == 4
	Begin Transaction
		IF !Empty( nReg )
			SRA->( MsGoto( nReg ) )
			lLock := RecLock( "SRA" , .F. , .F. )
		EndIF 
        
		IF !( lLock )
			Break
		EndIF

		//-- Inclui a Foto no Repositorio 	
        If lGravouFoto
			//-- Atualiza identifcador do BMP
			M->RA_BITMAP	:= xFilial("SRA")+M->RA_MAT
			SRA->RA_BITMAP	:= xFilial("SRA")+M->RA_MAT
		Endif
		
		SRA->( MsUnLock() )
	End Transaction
EndIF

Return( NIL )
