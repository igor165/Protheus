#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "CSAA120.CH" 

/*
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Funca��o     � CSAA120  � Autor � Emerson Grassi Rocha  � Data � 19/08/03 ���
����������������������������������������������������������������������������Ĵ��
���Descrica��o  � Gravar Classe Salarial nos Cargos.                         ���
����������������������������������������������������������������������������Ĵ��
���Uso          � CSAA120                                                    ���
����������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS  �  Motivo da Alteracao                      ���
����������������������������������������������������������������������������Ĵ��
���Cecilia Car. �07/07/14�TPZVTW �Incluido o fonte da 11 para a 12 e efetuada���
���             �        �       � a limpeza.                                ��� 
���Oswaldo L    �08-05-17�DRHPONTP11  �Projeto SOYUZ ajuste Ctree            ���
�����������������������������������������������������������������������������ı�
��������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSAA120
LOCAL cFiltra	:= ""				//Variavel para filtro
LOCAL aIndFil	:= {}				//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
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
//�    6 - Altera o registro corrente sem permitir inclusao      �
//����������������������������������������������������������������
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0004)		//"Classificacao de Cargos"

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RA1") 
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RBF","1")
bFiltraBrw 	:= {|| FilBrowse("RBF",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("RBF") 
dbGoTop()

mBrowse(6, 1, 22, 75, "RBF")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RBF",aIndFil)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CS120Lan      � Autor �  Emerson Grassi  � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa Lancamento Coletivo de Cursos para Cargos. 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CS120Lan()	                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CS120Lan(cAlias,nReg,nOpc)
Local aSaveArea	:= GetArea()
Local aSays   	:= {}
Local aButtons	:= {}
Local nOpca		:= 0
Local cPerg		:= "CSA120"

Private cClasse		:= RBF->RBF_CLASSE
Private cDesClasse	:= RBF->RBF_DESC
Private cCadastro   := OemToAnsi(STR0004) // "Classificacao de Cargos"

Pergunte(cPerg, .F.)

aAdd(aSays,OemToAnsi( STR0018 ) )// "Esta rotina permite relacionar os Cargos em determinada"
aAdd(aSays,OemToAnsi( STR0019 ) )// "Classe Salarial."

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpca := 1, FechaBatch() }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
IF nOpca == 1
	CS120Rot(cAlias,nReg,nOpc)
EndIF

RestArea(aSaveArea)
Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CS120Rot  � Autor � Emerson Grassi Rocha � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o Lancamento de Cursos.	                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA120       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CS120Rot(cAlias,nReg,nOpc)
Local aSaveArea	:= GetArea()
Local lRetorna	:= .T. 
Local nOpcao	:= 0

//��������������������������������������������������������������Ŀ
//� Variaveis para Tratar Design da Tela                         �
//����������������������������������������������������������������
Local oDlgMain
Local oOk, oNo, o1Ok  
Local c1Lbx   	:= ""
Local c2Lbx   	:= ""
Local oSay

//��������������������������������������������������������������Ŀ
//� Variaveis para Dimensionar Tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}         
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords	:= {}

Local oFont
Local oGroup1
Local oGroup2
Local oBmp

Private oArqNtxTmp	

// ListBox1
Private oArq1Tmp	
Private o1Lbx

Private cNtxAlias := GetNextAlias()

// ListBox2
Private oArq2Tmp
Private o2Lbx

Private oBtn1, oBtn2, oBtn3, oBtn4

//��������������������������������������������������������������Ŀ
//� Variaveis de Perguntas				                         �
//����������������������������������������������������������������
Private FilialDe	:= ""  	
Private FilialAte 	:= ""
Private CargoDe    	:= ""
Private CargoAte   	:= ""
Private CcDe      	:= ""
Private CcAte     	:= ""
Private GrupoDe   	:= ""
Private GrupoAte  	:= ""
Private Ordem     	:= 1

//��������������������������������������������������������������Ŀ
//� Obtem Parametros para Selecao de Cargos			             �
//����������������������������������������������������������������
// mv_par01		- Filial De
// mv_par02		- Filial Ate
// mv_par03		- Cargo De
// mv_par04		- Cargo Ate
// mv_par05		- Centro Custo de
// mv_par06		- Centro Custo ate
// mv_par07		- Grupo De
// mv_par08     - Grupo Ate
// mv_par09     - Ordem 1-Cargo 2-Descricao

Pergunte("CSA120",.F.)


FilialDe  	:= If(xFilial("SQ3") == Space(FWGETTAMFILIAL),Space(FWGETTAMFILIAL),FWxFilial("SQ3",mv_par01))
FilialAte 	:= mv_par02
CargoDe    	:= mv_par03
CargoAte   	:= mv_par04
CcDe      	:= mv_par05
CcAte     	:= mv_par06
GrupoDe   	:= mv_par07
GrupoAte  	:= mv_par08
Ordem     	:= mv_par09

//�����������������������������������������������������������������������������������Ŀ
//� Botoes de Selecao: Carrega Imagens                                                �
//�������������������������������������������������������������������������������������

oOk 	:= LoadBitmap( GetResources(), "BR_CINZA" )
oNo 	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
o1Ok 	:= LoadBitmap( GetResources(), "BR_VERDE" )

//��������������������������������������������������������������������������������Ŀ
//� ListBox: Cria arquivos temporarios                                             �
//����������������������������������������������������������������������������������
CS120CriaArq()

//��������������������������������������������������������������������������������Ŀ
//� ListBox: Preenche com Cargos Filtrados conforme Parametros   		           �
//����������������������������������������������������������������������������������
Processa({||lRetorna:=CS120Monta(cAlias)},OemToAnsi(STR0022)+OemToAnsi(STR0021)) //"Aguarde..."###" Montando tela para Classificacao de Cargos"
//Verifica se foram encontrados funcionarios de acordo com os parametros
If !lRetorna  
   Alert(OemtoAnsi(STR0005)) //"ATENCAO: Nao Foram Encontrados Cargos de Acordo com os Parametros Especificados "
   //-- Nao Foram Encontrados
   Fecha120(aSaveArea,oOK,oNo,o1OK)
   
   Return .F.
Endif
					 
/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aAdd( aObj1Coords , { 015 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords, , .T. )

aAdv2Size		:= aClone(aObj1Size[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 10 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T., .T. } )
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords )

aAdv3Size		:= aClone(aObj1Size[3])
aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 10 }
aAdd( aObj3Coords , { 000 , 000 , .T. , .T., .T. } )
aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords )

//��������������������������������������������������������������������������������Ŀ
//� Dialogo: Exibe Caixa para conter os objetos                                    �
//����������������������������������������������������������������������������������
DEFINE MSDIALOG oDlgMain Title cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

// Classe
@ aObjSize[1,1]+5, aObjSize[1,2]+5 SAY oSay PROMPT OemToAnsi(STR0023)+": "+cClasse+" - "+cDesClasse SIZE 200,8 FONT oFont Of oDlgMain PIXEL //"Classe"

// Groups
@ aObj1Size[1,1], aObj1Size[1,2] GROUP oGroup1 TO aObj1Size[1,3], aObj1Size[1,4] LABEL OemToAnsi(STR0024) OF oDlgMain PIXEL	// "Cargos"
oGroup1:oFont:= oFont
@ aObj1Size[3,1] , aObj1Size[3,2] GROUP oGroup2 TO aObj1Size[3,3], aObj1Size[3,4] LABEL OemToAnsi(STR0025) OF oDlgMain PIXEL	// "Cargos Classificados"
oGroup2:oFont:= oFont

//Legenda - Cinza 
@ aObjSize[3,1], aObjSize[3,2]+10 BITMAP oBmp RESNAME "BR_CINZA" oF oDlgMain SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ aObjSize[3,1], aObjSize[3,2]+17 SAY " - "+STR0027 OF oDlgMain PIXEL SIZE 100,009 FONT oFont	//"Disponivel para Classificar"

//Legenda - Verde
@ aObjSize[3,1], aObjSize[3,2]+110 BITMAP oBmp RESNAME "BR_VERDE" oF oDlgMain SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ aObjSize[3,1], aObjSize[3,2]+117 SAY " - "+STR0028 OF oDlgMain PIXEL SIZE 100,009 FONT oFont	//"Classificado nesta Classe"

//Legenda - Vermelho
@ aObjSize[3,1], aObjSize[3,2]+210 BITMAP oBmp RESNAME "BR_VERMELHO" oF oDlgMain SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ aObjSize[3,1], aObjSize[3,2]+217 SAY " - "+STR0029 OF oDlgMain PIXEL SIZE 100,009 FONT oFont	//"Classificado em outra Classe"

// ListBox-1 (Esquerda) 
@ aObj2Size[1,1],aObj2Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS ALIAS "TR1";
		 HEADER    						    "",;	//Em Branco para Selecao	
							OemtoAnsi(STR0008),;	//"Cargo"
							OemtoAnsi(STR0007),;	//"Descricao"
							OemtoAnsi(STR0009),;	//"Centro Custo"
							OemtoAnsi(STR0010),;	//"Descr. Centro Custo"  
							OemtoAnsi(STR0006),;	//"Fil."
							OemtoAnsi(STR0023);		//"Classe"
		COLSIZES 			GetTextWidth(0,"W"),;
							GetTextWidth(0,"BBBBB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BBBBBBBBB"),;			
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),; 
							GetTextWidth(0, Replicate("B", FWGETTAMFILIAL)),;
							GetTextWidth(0,"BBB");
					        SIZE aObj2Size[1,3],aObj2Size[1,4] OF oDlgMain PIXEL
	  
	o1Lbx:bLine:= {||{If(		TR1->TR1_MARCA==1,o1Ok,If(TR1->TR1_MARCA==0,oOk,oNo) ),;
								TR1->TR1_CARGO,;
								TR1->TR1_DESC,;
								TR1->TR1_CC,;
								TR1->TR1_DESCCC,;
								TR1->TR1_FILIAL,;
								TR1->TR1_CLASSE}}

// ListBox-2 (Direita)
@ aObj3Size[1,1],aObj3Size[1,2] LISTBOX o2Lbx VAR c2Lbx FIELDS ALIAS "TR2";
		 HEADER    			OemtoAnsi(STR0008),;	//"Cargo"
							OemtoAnsi(STR0007),;	//"Descricao"
							OemtoAnsi(STR0009),;	//"Centro Custo"
							OemtoAnsi(STR0010),;	//"Descr. Centro Custo"  
							OemtoAnsi(STR0006);		//"Fil."
		COLSIZES 			GetTextWidth(0,"BBBBB"),;  		
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BBBBBBBBB"),;			
							GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),; 
							GetTextWidth(0,"BB");
					        SIZE aObj3Size[1,3],aObj3Size[1,4] OF oDlgMain PIXEL
	  
	o2Lbx:bLine:= {||{			TR2->TR2_CARGO,;   	
								TR2->TR2_DESC,;    								
								TR2->TR2_CC,;
								TR2->TR2_DESCCC,;
								TR2->TR2_FILIAL}}

//-- Botoes de Movimentacao de Funcionario				
@ aObj1Size[3,1]*2+010,aObj1Size[3,2]*1.89 BTNBMP oBtn1 RESOURCE "NEXT"   SIZE 25,25 PIXEL DESIGN ACTION fMvToLbx2(.F.) OF oDlgMain
oBtn1:CTOOLTIP := STR0015 //###"Classificar Cargo"

@ aObj1Size[3,1]*2+040,aObj1Size[3,2]*1.89 BTNBMP oBtn3 RESOURCE "PREV"   SIZE 25,25 PIXEL DESIGN ACTION fMvToLbx1(.F.) OF oDlgMain
oBtn3:CTOOLTIP := STR0002 //###"Reclassificar Cargo"

@ aObj1Size[3,1]*2+070,aObj1Size[3,2]*1.89 BTNBMP oBtn2 RESOURCE "PGNEXT" SIZE 25,25 PIXEL DESIGN ACTION Processa({||fMvToLbx2(.T.)},OemToAnsi(STR0022)+OemToAnsi(STR0012)) ;//"Aguarde..."###"Classificando Cargo"
                        OF oDlgMain
oBtn2:CTOOLTIP := STR0015 //###"Classificar Cargo"

@ aObj1Size[3,1]*2+100,aObj1Size[3,2]*1.89 BTNBMP oBtn4 RESOURCE "PGPREV" SIZE 25,25 PIXEL DESIGN ACTION Processa({||fMvToLbx1(.T.)},OemToAnsi(STR0022)+OemToAnsi(STR0012)); //"Aguarde..."###"Classificando Cargo"
                        OF oDlgMain
oBtn4:CTOOLTIP := STR0002 //###"Reclassificar Cargo"

nOpcao := 0      

ACTIVATE MSDIALOG oDlgMain  On INIT EnchoiceBar(oDlgMain, {||nOpcao := 1, oDlgMain:End()},; 
							{|| nOpcao := 2, If(CS120Sai(), oDlgMain:End(), Nil) } ) //"Confirma Abandono da rotina?"###"Aten��o"
                            
If nOpcao == 1 
	Processa({|| CS120Grava(),OemToAnsi(STR0022)+OemToAnsi(STR0016) }) //"Aguarde..."###"Atualizando Cargos"
EndIf
	
Fecha120(oOK,oNo,o1OK)

RestArea(aSaveArea)

Return Nil   

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fecha120  � Autor � Emerson Grassi Rocha  � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Finaliza CSAA120	                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA120                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Fecha120(oOK,oNo,o1OK)

// ListBox 1
dbSelectArea("TR1")
dbCloseArea()

If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf

// ListBox 2
dbSelectArea("TR2") 
dbCloseArea()


If oArq2Tmp <> Nil
	oArq2Tmp:Delete()
	Freeobj(oArq2Tmp)
EndIf

// Filtro - Cargos      
dbSelectArea("SQ3") 
Set Filter To
RetIndex("SQ3") 
dbSetOrder(1)

dbSelectArea(cNtxAlias)
DbCloseArea()

If oArqNtxTmp <> Nil
	oArqNtxTmp:Delete()
	Freeobj(oArqNtxTmp)
EndIf

DeleteObject(oOk)
DeleteObject(oNo)
DeleteObject(o1Ok)

Return Nil
                                               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CS120Monta� Autor � Emerson Grassi Rocha � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtra arquivo de Cargos para Montar o listbox-1           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CS120Monta(ExpC1,ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA120       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function CS120Monta(cAlias) 
Local aSaveArea := GetArea()
Local lRet		:= .T.
Local cIndCond 	:= ""
Local cFor		:= ""
Local cDescCC	:= ""
Local nBMarca	:= 0
Local nIndex	:= 0
Local cAcessaSQ3:= &("{ || " + ChkRH(FunName(),"SQ3","2") + "}")
Local aStruSQ3 := {}
Local nTotLoop
Local nLoop 
Local aFields := {}
                  
dbSelectArea("SQ3") 
dbGoTop()

If Ordem == 1	       // Cargo
	dbSetOrder(1)
	cIndCond    := "Q3_FILIAL+Q3_CARGO+Q3_CC"
	cFor		:= '(Q3_FILIAL+Q3_CARGO+Q3_CC >="'
	cFor		+=  FilialDe+CargoDe+CcDe+'") .And.'
	cFor		+= '(Q3_FILIAL+Q3_CARGO+Q3_CC <="'
	cFor		+=  FilialAte+CargoAte+CcAte+'")'
	
ElseIf Ordem == 2		// Descricao
	dbSetOrder(3)
	cIndCond    := "Q3_FILIAL+Q3_DESCSUM+Q3_CC"
	cFor		:= '(Q3_FILIAL+Q3_CARGO+Q3_CC >="'
	cFor		+=  FilialDe+CargoDe+CcDe+'") .And.'
	cFor		+= '(Q3_FILIAL+Q3_CARGO+Q3_CC <="'
	cFor		+=  FilialAte+CargoAte+CcAte+'")'
EndIf	

 
aStruSQ3 := SQ3->(dbStruct())
nTotLoop	:= Len(aStruSQ3)  

For nLoop:=1 To nTotLoop
	AADD(aFields,{	aStruSQ3[nLoop,1]   ,;
       		        aStruSQ3[nLoop,2]  	,;
			        aStruSQ3[nLoop,3]  	,;
			        aStruSQ3[nLoop,4]    }    )  
Next

oArqNtxTmp := RhCriaTrab(cNtxAlias, aFields, Nil)


IndRegua("SQ3",cNtxAlias,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."


nIndex := RetIndex("SQ3") 

dbSetOrder(nIndex+1)    
dbGoTop()
           
ProcRegua(SQ3->(Reccount()))

While !Eof() 	

	IncProc(STR0013+" / "+STR0008+": "+SQ3->Q3_FILIAL+" / "+SQ3->Q3_CARGO+" - "+Left(SQ3->Q3_DESCSUM,25)) // Filial / Cargo

	//��������������������������������������������������������������Ŀ
	//� Consiste controle de acessos e filiais validas				 |
	//����������������������������������������������������������������
    If !(SQ3->Q3_FILIAL $ fValidFil("SQ3")) .Or. !Eval(cAcessaSQ3)
       dbSkip()
       Loop
    EndIf
    
	If 	SQ3->Q3_FILIAL 	< FilialDe 	.Or. SQ3->Q3_FILIAL	> FilialAte	.Or.;
		SQ3->Q3_CARGO 	< CargoDe 	.Or. SQ3->Q3_CARGO 	> CargoAte 	.Or.;
 		SQ3->Q3_CC 		< CCDe 		.Or. SQ3->Q3_CC 	> CCAte		.Or.;
		SQ3->Q3_GRUPO	< GrupoDe	.Or. SQ3->Q3_GRUPO	> GrupoAte
       
		dbSkip()
		Loop
	EndIf

	If cClasse == SQ3->Q3_CLASSE
		nBMarca := 1	//Classe igual

	ElseIf Empty(SQ3->Q3_CLASSE)
		nBMarca	:= 0	//Desmarcado

	Else
		nBMarca := 2	//Classe Diferente
	EndIf
		
	dbSelectArea("SQ3")
	cDescCC	 := FDesc("CTT",SQ3->Q3_CC,"CTT->CTT_DESC01",30)
	
	// Monta ListBox-1
	
	RecLock("TR1",.T.)  

		TR1->TR1_MARCA		:= nBMarca
		TR1->TR1_FILIAL		:= SQ3->Q3_FILIAL
		TR1->TR1_CARGO		:= SQ3->Q3_CARGO
		TR1->TR1_DESC		:= SQ3->Q3_DESCSUM
		TR1->TR1_CC			:= SQ3->Q3_CC
		TR1->TR1_DESCCC		:= cDescCC                               
		TR1->TR1_CLASSE		:= SQ3->Q3_CLASSE
		
	TR1->( MsUnlock() )
     
	// Monta Listbox-2            
	If cClasse == SQ3->Q3_CLASSE
	
	
		RecLock("TR2",.T.)  

			TR2->TR2_FILIAL		:= SQ3->Q3_FILIAL
			TR2->TR2_CARGO		:= SQ3->Q3_CARGO
			TR2->TR2_DESC		:= SQ3->Q3_DESCSUM
			TR2->TR2_CC			:= SQ3->Q3_CC
			TR2->TR2_DESCCC		:= cDescCC                               
			TR2->TR2_REC		:= TR1->( Recno() )                              
	
		TR2->( MsUnlock() )		
		
	EndIf   
	
	dbSelectArea("SQ3")
	dbSkip()
EndDo



//-- Se nao foram encontrados cargos de acordo com os parametros passados
//-- retorna .f. para abandonar rotina
If TR1->(LastRec()) < 1
	lRet:=.F.
Endif          

dbSelectArea("TR1")
dbGotop()

dbSelectArea("TR2") 
dbGotop()

RestArea(aSaveArea)

Return lRet


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CS120CriaArq� Autor �Emerson Grassi Rocha � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria arquivos para dados do listbox 1 e 2 	              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA120                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CS120CriaArq()
Local aSaveArea	:= GetArea()
Local a1Stru	:= {}
Local a2Stru	:= {}
Local cCond		:= ""
Local aLstIndices := {}

// Arquivo do ListBox1
Aadd(a1Stru,{"TR1_MARCA"	,"N",01,0})  
Aadd(a1Stru,{"TR1_CARGO"	,"C",05,0})
Aadd(a1Stru,{"TR1_DESC"		,"C",30,0})
Aadd(a1Stru,{"TR1_CC"		,"C",09,0})
Aadd(a1Stru,{"TR1_DESCCC"	,"C",30,0})
Aadd(a1Stru,{"TR1_FILIAL"	,"C",FWGETTAMFILIAL,0})
Aadd(a1Stru,{"TR1_CLASSE"	,"C",03,0})

//Ordem 1-Cargo 2-Descricao 
If Ordem == 1				// Cargo
	AAdd( aLstIndices, {"TR1_FILIAL","TR1_CARGO","TR1_CC"})
ElseIf Ordem == 2			// Descricao
	AAdd( aLstIndices, {"TR1_FILIAL","TR1_DESC","TR1_CC"})
EndIf

oArq1Tmp := RhCriaTrab('TR1', a1Stru, aLstIndices)



// Arquivo do ListBox2
Aadd(a2Stru,{"TR2_CARGO"	,"C",05,0})
Aadd(a2Stru,{"TR2_DESC"		,"C",30,0})
Aadd(a2Stru,{"TR2_CC"		,"C",09,0})
Aadd(a2Stru,{"TR2_DESCCC"	,"C",30,0})
Aadd(a2Stru,{"TR2_FILIAL"	,"C",FWGETTAMFILIAL,0})
Aadd(a2Stru,{"TR2_REC"		,"N",05,0})

aLstIndices := {}

//Ordem 1-Cargo 2-Descricao 
If Ordem == 1				// Cargo
	AAdd( aLstIndices, {"TR2_FILIAL","TR2_CARGO","TR2_CC"})
ElseIf Ordem == 2			// Descricao
	AAdd( aLstIndices, {"TR2_FILIAL","TR2_DESC","TR2_CC"})
EndIf

oArq2Tmp := RhCriaTrab('TR2', a2Stru, aLstIndices)

RestArea(aSaveArea)
Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CS120Grava� Autor � Emerson Grassi Rocha  � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava Classe Salarial nos Cargos.				              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 				                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA120                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CS120Grava()

Local aSaveArea	:= GetArea()

dbSelectArea("TR1")
dbGoTop() 
ProcRegua( TR1->( Reccount() ) )
While !Eof()
    IncProc()	

	If Empty(TR1->TR1_CLASSE) .Or. TR1->TR1_CLASSE == cClasse
	
		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(TR1->TR1_FILIAL+TR1->TR1_CARGO+TR1->TR1_CC)
			RecLock("SQ3",.F.)
	
				SQ3->Q3_CLASSE := TR1->TR1_CLASSE
			
			SQ3->( MsUnlock() )
		EndIf
    
  	EndIf
  
	dbSelectArea("TR1") 
	dbSkip()
EndDo

RestArea(aSaveArea) 
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CS120Sai  � Autor � Emerson Grassi Rocha  � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se abandona Rotina                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CSAA120                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CS120Sai()
Local lRet := .T.

//-- Se existir pelo menos 1 funcionario selecionado 
If ! Empty(TR2->TR2_CARGO)
	//-- Verifica Se NAO Abandona, entao, retorna a geracao de treinamentos coletivos
	If !MsgYesNo(OemtoAnsi(STR0020),OemtoAnsi(STR0014)) //#"Confirma Abandono da rotina?" #"Aten��o"
	   lRet := .F.
	Endif   
Endif
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fMvToLbx2     � Autor �Emerson Grassi    � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Move Classe para Cargo.		                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fMvToLbx2(lTodos)                                          ���
���          �            lTodos         .T. move Todos os Funcionarios.  ���
���          �                           .F. move Funcinario Atual.       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fMvToLbx2(lTodos)                
Local aSaveArea	:= GetArea()
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.

Default lTodos	:= .F.

dbSelectArea("TR1") 
nRecno	:= nInicio	:= TR1->(Recno())

//-- Determina a Abrangencia
If lTodos
   dbGoTop()               
   nInicio	:= 1
   nFim		:= TR1->(LastRec())

    //-- Implementa Regua somente para movimentacao coletiva
   ProcRegua(nFim)
Else
   nFim := TR1->(Recno())
Endif     

If !lTodos .And. !Empty(TR1->TR1_CLASSE) .And. TR1->TR1_CLASSE != cClasse
	Aviso(OemToAnsi(STR0014), OemToAnsi(STR0026), {"Ok"}	) //"Atencao"###"Este Cargo ja tem outra Classe Informada."
	lRet := .F.   
	RestArea(aSaveArea)
	Return lRet
EndIf

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)
For nRec := nInicio To nFim
	//-- Incrementa Regua somente para movimentacao coletiva
	If lTodos
		IncProc()
	Endif
	If TR1->TR1_MARCA == 0	//Desmarcado
		//-- Adiciona Funcionario
		//-- Altera Cor indicando que funcionario foi selecionado
		CS120Marca()
		
		//-- Preenche-o com as informacoes
		
	
		RecLock("TR2",.T.)
			TR2->TR2_FILIAL	:= TR1->TR1_FILIAL
			TR2->TR2_CARGO	:= TR1->TR1_CARGO
			TR2->TR2_DESC	:= TR1->TR1_DESC
			TR2->TR2_CC		:= TR1->TR1_CC
			TR2_REC			:= TR1->( RECNO() )
		TR2->( MsUnlock() )
		                           
		// Grava a Classe do Cargo na ListBox-1.
		RecLock("TR1",.F.)
			TR1->TR1_CLASSE := cClasse
		TR1->( MsUnlock() )
				    
		lRet := .T.
	Endif
	
	TR1->(DbSkip())
Next nRec
    
dbSelectArea("TR2")
dbGoTop()
o2Lbx:Refresh(.T.)

TR1->(DbGoto(nRecno))
o1Lbx:Refresh(.T.)

RestArea(aSaveArea)

Return lREt         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fMvToLbx1   	 � Autor �Emerson Grassi    � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Remove Cargo da ListBox-2	                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fMvToLbx1(lTodos)                                          ���
���          �            lTodos         .T. move Todos os Cargos.	      ���
���          �                           .F. move Cargo Atual.       	  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fMvToLbx1(lTodos)                
Local aSaveArea	:= GetArea()
Local nRecno	:= 0
Local lRet		:= .T.    

//-- Se Nao Existirem elementos na ListBox-2 nao Move Nada
If Empty(TR2->TR2_CARGO)
   Return lRet
Endif
   
Default lTodos:=.F.

dbSelectArea("TR1") 
nRecno := TR1->( Recno() )

If lTodos
   
    //-- Implementa Regua somente para movimentacao coletiva
   ProcRegua( TR2->( LastRec() ) )

	dbSelectArea("TR2")
	dbGoTop()
	While ! Eof()
		
		TR1->( dbGoto(TR2->TR2_REC) )
       
		// Limpa a Classe do Cargo.
		RecLock("TR1",.F.)
			TR1->TR1_CLASSE := Space(3)
		TR1->( MsUnlock() )
		
	    //-- Incrementa Regua somente para movimentacao coletiva
	    IncProc()
	    CS120Marca()

		// Elimina registros da listbox-2
		RecLock("TR2",.F.)
			TR2->( dbDelete() )
		TR2->( MsUnlock() )
	
		TR2->( dbSkip() )
	EndDo

Else
	TR1->( dbGoto(TR2->TR2_REC) )
	RecLock("TR1",.F.)
		TR1->TR1_CLASSE := Space(3)
	TR1->( MsUnlock() ) 
	
	CS120Marca()
	
	RecLock("TR2",.F.)
		TR2->( dbDelete() )
	TR2->( MsUnlock() ) 
	
Endif

TR1->( dbGoto(nRecno) )
o1Lbx:Refresh(.T.)

TR2->( dbGoto(1) )
o2Lbx:Refresh(.T.)

RestArea(aSaveArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CS120Marca    � Autor �Emerson Grassi    � Data � 19/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca Cargo.		                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CS120Marca()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CSAA120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CS120Marca()
Local aSaveArea	:= GetArea()

RecLock("TR1",.F.)
	TR1->TR1_MARCA := IIF(TR1->TR1_MARCA == 1, 0, 1)
TR1->(MsUnlock())

RestArea(aSaveArea)
Return Nil

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �28/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �CSAA120                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina :=   {	{ STR0001,'PesqBrw'		, 0,1,,.F.},;	//"Pesquisar"
						{ STR0003,'CS120Lan'	, 0,6}}		//"Lancamento"

Return aRotina

