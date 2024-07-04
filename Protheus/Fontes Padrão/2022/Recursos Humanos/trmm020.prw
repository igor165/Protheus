#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRMM020.CH" 

/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o       � Trmm020  � Autor � Mauricio MR             � Data � 28.01.02 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o    � Registro de Treinamento Coletivo                             ���
������������������������������������������������������������������������������Ĵ��
���Uso          � Trmm020                                                      ���
������������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS   �  Motivo da Alteracao                       ���
������������������������������������������������������������������������������Ĵ��
���Cecilia Car. �28/07/14�TPZWA0  �Incluido o fonte da 11 para a 12 e efetuada ���
���             �        �        �a limpeza.                                  ���
���Flavio Correa�16/12/14�TRBLDD  �Retirada de Ajusta dos fontes			   ���
���Oswaldo L   �01/03/17�DRHPONTP-9�Nova funcionalidade de tabelas temporarias  ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function Trmm020

LOCAL cFiltra	:= ""			//Variavel para filtro
LOCAL aIndFil	:= {}			//Variavel Para Filtro
LOCAL aArea		:= GetArea()

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private aFldOfusca 	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

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
//����������������������������������������������������������������

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro 	:= OemtoAnsi(STR0004)		//"Registrar Treinamentos Coletivos"
Private oTmpTabFO1
Private cTr1Alias := GetNextAlias()
Private aVetor := {}
Private o1Ok,oNo

oNo 	:= LoadBitmap( GetResources(), "LBNO" )
o1Ok 	:= LoadBitmap( GetResources(), "LBOK" )

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("RA1")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA1","1")
bFiltraBrw 	:= {|| FilBrowse("RA1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("RA1")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA1")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RA1",aIndFil)

DeleteObject(oNo)
DeleteObject(o1Ok)

RestArea(aArea)
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020Reg      � Autor �  Emerson Grassi  � Data � 30/09/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa Registro de Treinamento Coletivo 	   			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020Reg()	                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr020Reg(cAlias,nReg,nOpc)  

Local aSaveArea	:= GetArea()
Local aSays   	:= {}
Local aButtons	:= {}
Local nOpca		:= 0         

Local bProcess	  	:=	{|oSelf| Tr020Rot( cAlias, nReg, nOpc, oSelf )}
Local cFunction		:=	"TRMM020"
Local cDescription	:=	OemToAnsi(STR0044) +" "+;	//"Esta rotina permite o registro de treinamento coletivo correspondente"
						OemToAnsi(STR0045) 			//"ao curso escolhido."
Local cPerg			:=	"TRM020"

Private lAbortPrint := .F.

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TRM020", .F.)
    
tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg) 

RestArea(aSaveArea) 

Return( NIL )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Tr020Rot  � Autor � Mauricio MR          � Data � 28.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o Registro de Treinamentos                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020Rot(cAlias,nReg,nOpc,oSelf)

Local aArea		:= GetArea()
Local lRetorna	:= .T.
Local aFields	:= {}

//��������������������������������������������������������������Ŀ
//� Variaveis para Tratar Enchoice                               �
//����������������������������������������������������������������
Local aCampos		:= {}
Local aNaoAlterar	:= {}
Local aAlteraveis   := {}
Local cCurso		:= RA1->RA1_CURSO  
Local cDescCurso 	:= RA1->RA1_DESC
Local nDuraca		:= RA1->RA1_DURACA
Local cUnDuraca		:= RA1->RA1_UNDURA
Local nValor		:= RA1->RA1_VALOR
Local nHoras		:= RA1->RA1_HORAS 
Local lMostraCpo	:= .T.

//��������������������������������������������������������������Ŀ
//� Variaveis para Tratar Design da Tela                         �
//����������������������������������������������������������������
Local oDlgMain
Local oOk
Local oSubstitui
Local lSubstitui	:= .F.
Local c1Lbx   		:= ""

Local aMostrar:= {}
Local aAltera := {"RA4_NOTA","RA4_PRESEN"}      
Local n

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


//��������������������������������������������������������������Ŀ
//� Variaveis para campos memo (SYP) de usuario					 �
//����������������������������������������������������������������
Local aMemoRA4  := {}
Local nLoop	    := 0 

Private o1Lbx,oGet
Private oBtn1, oBtn2, oBtn3, oBtn4

//��������������������������������������������������������������Ŀ
//� Variaveis para Tratar a GetDados                             �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]
Private aHeader	:= {}
Private aCols	:= {}
Private aTr1Rec	:= {}
Private Continua:= .F.
Private nUsado  := 0
Private lMostra	:= .F.
Private aVirtual:= {}	
Private nOpcx	:= nOpc //Opcao para somente poder alterar os campos
Private nOpcGet	:= nOpc

Private aColsVazio  := {}
Private nPosFilial	:= 0
Private nPosMat		:= 0
Private nPosNome	:= 0
Private nPosNota	:= 0
Private nPosPresen	:= 0


//��������������������������������������������������������������������������������Ŀ
//� GetDados: Monta aHeader e aCols para receber funcionarios selecionados         �
//����������������������������������������������������������������������������������
aFields := Tr020NMostra()

Tr020Header(aFields)
nUsado 	:= Len(aHeader)

aCols	:= Array(1,nUsado+1) 
Tr020Cols(aFields)

//��������������������������������������������������������������������������������Ŀ
//� GetDados: Inicializa Vetor aCols                                               �
//����������������������������������������������������������������������������������
aColsVazio  := aClone(aCols[1]) //Copia do Acols Vazio para inicializar 
nPosFilial	:= GdFieldPos( "RA4_FILIAL") 
nPosMat		:= GdFieldPos( "RA4_MAT")
nPosNome	:= GdFieldPos( "RA4_NOME")
nPosNota	:= GdFieldPos( "RA4_NOTA")
nPosPresen	:= GdFieldPos( "RA4_PRESEN")

//��������������������������������������������������������������Ŀ
//� Variaveis para Tratar Enchoice                               �
//����������������������������������������������������������������
aCampos		:= {}

aMostrar	:= {"RA4_CURSO"		,"RA4_DESCCU"	,"RA4_SINONI"	,"RA4_DESCSI"	,"RA4_ENTIDA"	,"RA4_DESCEN", ;
				"RA4_VALIDA"	,"RA4_NOTA"		,"RA4_DURACA"	,"RA4_UNDURA"	,"RA4_PRESEN"	,"RA4_DATAIN", ;
				"RA4_DATAFI"	,"RA4_VALOR"	,"RA4_HORAS"	,"RA4_EFICAC"	,"RA4_EFICSN"   }

aNaoAlterar := {"RA4_CURSO"}

//��������������������������������������������������������������Ŀ
//� Obtem Parametros para Selecao de Funcionarios                �
//����������������������������������������������������������������
aMemoRA4  := If( ExistBlock( "RA4MEM" ), ExecBlock( "RA4MEM", .F.,.F. ), {} )  
//-- Identifica os campos memos de usuario da tabela RA4
If !( ValType( aMemoRA4 ) == "A" )
	aMemoRA4	:= {}
Else
	aMemoRA4	:= 	Aeval(aMemoRA4,{|x| x[1]:= Alltrim(Upper(x[1])), x[2]:= Alltrim(Upper(x[2]))})
EndIf

aAlteraveis := {}                
cTitCurso	:= ""
cTitEntidade:= ""
cTitDataIn  := ""
cTitDataFi	:= ""

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RA4")

RA4->(DBGOTO(LASTREC()+1))
RegToMemory( "RA4", .T., .T. )

While ! Eof() .and. (X3_ARQUIVO == "RA4")  
    lMostraCpo:= .F.
    If Ascan(aMostrar,Upper(Trim(x3_campo))) > 0     .OR. ( SX3->X3_PROPRI $ "uU" )  .OR. ;
       (!Empty(aMemoRA4) .and. (Ascan(aMemoRA4,{|X|x[1] ==Upper(Trim(x3_campo)) } ) > 0))
		Aadd(aCampos,Upper(Trim(x3_campo))) 
	    lMostraCpo:= .T.
	Endif
    
    If Ascan(aNaoAlterar,Upper(Trim(x3_campo))) == 0
		If lMostraCpo
			Aadd(aAlteraveis,Upper(Trim(x3_campo)))	                              
		Endif	
	Endif
    
	cCampo  	:= "M->"+X3_CAMPO
	cX3Campo 	:= "RA4->"+X3_CAMPO


	If x3_campo = "RA4_CURSO"  //Variaveis vindas do RA1
		&cCampo := cCurso 
        //-- Carrega o Titulo do campo RA4_Curso na lingua nativa
        //-- para ser utilizado no help se necessario
		cTitCurso:=X3Titulo()
	ElseIf x3_campo = "RA4_DESCCU" //Variaveis vindas do RA1
		&cCampo := cDescCurso 
    ElseIf x3_campo = "RA4_DURACA" //Variaveis vindas do RA1
		&cCampo := nDuraca
    ElseIf x3_campo = "RA4_UNDURA" //Variaveis vindas do RA1
		&cCampo := cUnDuraca		 
    ElseIf x3_campo = "RA4_VALOR" //Variaveis vindas do RA1
		&cCampo := nValor				
    ElseIf x3_campo = "RA4_HORAS" //Variaveis vindas do RA1
		&cCampo := nHoras				
    Else                     
    	IF x3_Tipo = "C"
			&cCampo := SPACE(x3_tamanho)
		ELSEIF  x3_Tipo  = "N"
			&cCampo := 0
		ELSEIF  x3_Tipo  = "D"
			&cCampo := CtoD("  /  /  ")
		ELSEIF  x3_Tipo  = "L"
			&cCampo := .F.
		ENDIF

        //-- Carrega o Titulo do campo RA4_Entida na lingua nativa
        //-- para ser utilizado no help se campos NAO INFORMADOS 
		If x3_campo = "RA4_ENTIDA" //Variaveis vindas do RA1
			cTitEntidade:=X3Titulo()		
    	ElseIf x3_campo = "RA4_DATAIN" //Variaveis vindas do RA1
			cTitDataIn:=X3Titulo()		
		ElseIf x3_campo = "RA4_DATAFI" //Variaveis vindas do RA1
			cTitDataFi:=X3Titulo()		    	
    	Endif 
    	
	Endif

	dbSkip()
Enddo

                         
//��������������������������������������������������������������Ŀ
//� Obtem Parametros para Selecao de Funcionarios                �
//����������������������������������������������������������������
// MV_PAR01		- Filial De
// MV_PAR02		- Filial Ate
// MV_PAR03		- Centro Custo de
// MV_PAR04		- Centro Custo ate
// MV_PAR05		- Matricula de
// MV_PAR06		- Matricula ate
// MV_PAR07		- Funcao de
// MV_PAR08		- Funcao ate
// MV_PAR09     - Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
// MV_PAR10		- Grupo De
// MV_PAR11     - Grupo Ate
// MV_PAR12		- Depto De
// MV_PAR13		- Depto Ate
// MV_PAR14		- Sindicato De
// MV_PAR15		- Sindicato Ate
// MV_PAR16    - Status Funcionario
// MV_PAR17    - Ferias Programadas

Pergunte("TRM020",.F.)

FilialDe  := MV_PAR01
FilialAte := MV_PAR02
CcDe      := MV_PAR03
CcAte     := MV_PAR04
MatDe     := MV_PAR05
MatAte    := MV_PAR06
FuncDe    := MV_PAR07
FuncAte   := MV_PAR08
Ordem     := MV_PAR09
GrupoDe   := MV_PAR10
GrupoAte  := MV_PAR11
DeptoDe   := MV_PAR12
DeptoAte  := MV_PAR13
SindDe    := MV_PAR14
SindAte   := MV_PAR15
cSituacao := MV_PAR16
nFerProg  := MV_PAR17



//�����������������������������������������������������������������������������������Ŀ
//� Botoes de Selecao: Carrega Imagens                                                �
//�������������������������������������������������������������������������������������
oOk 	:= LoadBitmap( GetResources(), "Enable" )

//��������������������������������������������������������������������������������Ŀ
//� ListBox: Cria arquivo temporario                                               �
//����������������������������������������������������������������������������������
Tr020CriaArq()

//��������������������������������������������������������������������������������Ŀ
//� ListBox: Preenche com Funcionarios Filtrados conforme Parametros               �
//����������������������������������������������������������������������������������
lRetorna := Tr020Monta(cAlias,cCurso,oSelf)

//Verifica se foram encontrados funcionarios de acordo com os parametros
If !lRetorna
  
   Alert(OemtoAnsi(STR0007)) //## "ATENCAO: Nao Foram Encontrados Funcionarios de Acordo com os Parametros Especificados "  ##
   //-- Nao Foram Encontrados
   Fecha020(aArea,oOK,oNo,o1OK)//,cArq1,cArqNtx)
   
   Return .F.
Endif


/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 070 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aAdd( aObjCoords , { 000 , 007 , .T. , .F. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aClone(aObjSize[2])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 0 , 0 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. , .T. } )
aAdd( aObj1Coords , { 023 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )

aAdv2Size		:= aClone(aObj1Size[2])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 10 }					 
For n:=1 to 10
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
Next n
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords)


Dbselectarea(cTr1Alias)
(cTr1Alias)->(DBGotop())
	
//��������������������������������������������������������������������������������Ŀ
//� Dialogo: Exibe Caixa para conter os objetos                                    �
//����������������������������������������������������������������������������������
DEFINE MSDIALOG oDlgMain Title cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	//��������������������������������������������������������������������������������Ŀ
	//� Enchoice: Exibe os gets de Entrada das Informacoes Compelementares             �
	//����������������������������������������������������������������������������������
	// Enchoice: Inicializa variaveis de memoria para Informacoes Complementares do Curso
	dbSelectArea("RA4")
	dbSetOrder(1)
	
	nOpca := EnChoice( "RA4", nReg, nOpcx   , , , ,aCampos ,aObjSize[1],aAlteraveis, , , , , , , .T. )
	
			
@ aObj1Size[1,1],aObj1Size[1,2] LISTBOX o1Lbx VAR c1Lbx FIELDS ; // FIELDS ALIAS cTr1Alias ; 
			 HEADER    						    "",;			//Em Branco para Selecao	
								OemtoAnsi(STR0010),;			//"Fil."
								OemtoAnsi(STR0012),;			//"Matricula"
								OemtoAnsi(STR0011),;			//"Nome"
								OemtoAnsi(STR0013),;
								OemtoAnsi(STR0014),;
								OemtoAnsi(STR0015),;
								OemtoAnsi(STR0016),;
			COLSIZES 			GetTextWidth(0,"W"),;
								GetTextWidth(0,"BB"),;
								GetTextWidth(0,"BBBBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
								GetTextWidth(0,"BBBBBBBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
								GetTextWidth(0,"BBBB"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
						        SIZE aObj1Size[1,3],aObj1Size[1,4] OF oDlgMain PIXEL
		
						        
		o1Lbx:nFreeze := 3
		o1Lbx:SetArray( aVetor )//Atencao:tabelas temporaria direto no banco nao podem ser vinculadas ao list box. Por isto, aplicamos array
		o1Lbx:bLine:= {||{  		aVetor[o1Lbx:nAt,1],;
									aVetor[o1Lbx:nAt,2],;
									aVetor[o1Lbx:nAt,3],;
									aVetor[o1Lbx:nAt,4],;
									aVetor[o1Lbx:nAt,5],;
									aVetor[o1Lbx:nAt,6],;
									aVetor[o1Lbx:nAt,7],;
									aVetor[o1Lbx:nAt,8]}   }
		o1Lbx:Hide()                           
		o1Lbx:Show()                           
		o1Lbx:Refresh()
	//��������������������������������������������������������������������������������Ŀ
	//� GetDados: Exibe aHeader e aCols para funcionarios selecionados                 �
	//����������������������������������������������������������������������������������
	oGet  := MSGetDados():New(aObj1Size[3,1],aObj1Size[3,2],aObj1Size[3,3],aObj1Size[3,4],nOpcGet,"Tr020LinOK()","Tr020AllOK()"," ",.F.,aAltera,1,.F.)
	
	//-- Sobrepoe Geracao Anterior
	@  aObjSize[3,1],aObj1Size[3,2] CHECKBOX oSubstitui VAR lSubstitui 	PROMPT OemtoAnsi(STR0025) SIZE 90,08	OF oDlgMain PIXEL;	//" Substitui Geracao Anterior"
		ON CLICK ( If( lSubstitui,;
		               If( MsgYesNo(OemtoAnsi(STR0026),OemtoAnsi(STR0020)),; // " Substituir Geracao de Treinamentos Anteriores? "###"Aten��o"
		                   lSubstitui:=.T.,; 
					       lSubstitui:=.F.;
					     ) ;
					   ,Nil;
					  );
				   	,oSubstitui:Refresh(.T.);
				 )            
					
	//-- Botoes de Movimentacao de Funcionario	   
	oBtn1 := TBitmap():New(aObj2Size[1,1],aObj2Size[1,2],25,25,,"NEXT",.T.,oDlgMain ,;
                {||fMoveToGet(.F.,@aVetor)},,,,,,,,.T.,,)
	oBtn1:CTOOLTIP := STR0022 //##"Mover Funcionario"
	

	oBtn3 := TBitmap():New(aObj2Size[2,1],aObj2Size[2,2],25,25,,"PREV",.T.,oDlgMain ,;
                {||fMoveToList(.F.,@aVetor)},,,,,,,,.T.,,)
   	oBtn3:CTOOLTIP := STR0022 //##"Mover Funcionario"
	
	oBtn2 := TBitmap():New(aObj2Size[3,1],aObj2Size[3,2],25,25,,"PGNEXT",.T.,oDlgMain ,;
                {||Processa({||fMoveToGet(.T.,@aVetor)},OemToAnsi(STR0030)+OemToAnsi(STR0033))},,,,,,,,.T.,,)	//"Aguarde..."##"Movendo Funcionarios"#
	oBtn2:CTOOLTIP := STR0022 //##"Mover Funcionario"
	
	oBtn4 := TBitmap():New(aObj2Size[4,1],aObj2Size[4,2],25,25,,"PGPREV",.T.,oDlgMain ,;
                {||Processa({||fMoveToList(.T.,@aVetor)},OemToAnsi(STR0030)+OemToAnsi(STR0033))},,,,,,,,.T.,,)	//"Aguarde..."##"Movendo Funcionarios"#	                        
	oBtn4:CTOOLTIP := STR0022 //##"Mover Funcionario"
	
/*	�����������������������������������������������������������������������������������������������������Ŀ
	�Ponto de Entrada: Pesquisar Funcionarios para Reg. Trein. Coletivo 								  �
	�Dica: Ao usar objs nao pixel, como BTNBMP multiplique por 2 as coordenadas. 						  �
	�		Exemplo aObj2Size[5,1]*2, aObj2Size[5,2]*2													  �
	�Se usar obj pixel, como TBITMAP, use direto as coordenadas do array aObj2Size[5,1],aObj2Size[5,2].	  �
	�������������������������������������������������������������������������������������������������������*/
	If ExistBlock("TRM020PF")
		ExecBlock("TRM020PF",.F.,.F.,{aObj2Size,oDlgMain})     
	EndIF

	nOpca := 0      

ACTIVATE MSDIALOG oDlgMain  On INIT;
	(;
		Tr020OnOff(.T.),Tr020OnOff(.F.),;
		(EnchoiceBar;
			(oDlgMain,	{||If(Tr020Grava(cCurso,lSubstitui, aMemoRA4),oDlgMain:End(),Nil)},;
						{||If(Tr020Sai(),oDlgMain:End(),Nil)};
			);
		);
	) 
	
Fecha020(aArea,oOK,oNo,o1OK)

Return Nil   

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fecha020  � Autor � Mauricio MR           � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Finaliza TRMA201                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trmm020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Fecha020(aArea,oOK,oNo,o1OK)

dbSelectArea(cTr1Alias)
dbCloseArea()

If oTmpTabFO1 <> Nil
    oTmpTabFO1:Delete()
    Freeobj(oTmpTabFO1)
EndIf 
      
dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)

DeleteObject(oOk)

RestArea(aArea)
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020Exc      � Autor �Mauricio MR       � Data � 01.02.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa Exclusao de Registro de Treinamento Coletivo 	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020Exc()	                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr020Exc()

Local aArea			:= GetArea() 
Local aSays   		:= {}
Local aButtons 		:= {}
Local nOpca			:= 0
Local nResultado	:= 0 
Local cFunction		:= "TRMM020"
Local bProcess	  	:= {|oSelf|nOpca := 1,nResultado:=Tr020E(oSelf)} 
Local cDescription	:=	OemToAnsi(STR0038) +" "+;	//"Esta rotina ira Eliminar os registros de treinamento coletivo correspondentes"
						OemToAnsi(STR0039) 			//"ao curso escolhido." 
Local cPerg			:= "TR020E"
Local oProcess

Private cCadastro   := OemToAnsi(STR0037 ) // "Eliminacao de Registros de Treinamento Coletivo" 

oProcess:= tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)   

IF nOpca == 1 
 	ApMSGInfo(STR0043+Trim(Str(nResultado)),STR0042)
EndIF

RestArea( aArea )
Return( NIL )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020E        � Autor �Mauricio MR       � Data � 01.02.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclui  Registro de Treinamento Coletivo   	          	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020E  ()	                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020E(oProcess)
Local aArea			:= GetArea()
Local aAreaSra  	:= SRA->(GetArea())
Local nEliminados	:= 0

//-- Variavel para Controle de Acesso as informacoes dos funcionarios
Local cAcessaSRA	:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")

//-- Variaveis para Tratar de Query para Selecao de Funcionarios Via Cadastro de Func.
Local cIndCond 	:= ""
Local cFor		:= ""
Local nIndex	:= 0
Local cGrupo	:= ""
Local cDepto    := ""

//-- Variaveis para  Obter Parametros
Local FilialDe  := MV_PAR01
Local FilialAte := MV_PAR02
Local CcDe      := MV_PAR03
Local CcAte     := MV_PAR04
Local MatDe     := MV_PAR05
Local MatAte    := MV_PAR06
Local FuncDe    := MV_PAR07
Local FuncAte   := MV_PAR08
Local GrupoDe   := MV_PAR09
Local GrupoAte  := MV_PAR10
Local DeptoDe   := MV_PAR11
Local DeptoAte  := MV_PAR12
Local SindDe    := MV_PAR13
Local SindAte   := MV_PAR14
Local DataDe    := MV_PAR15
Local DataAte   := MV_PAR16

Local cFil		:= ""
Local cInicio	:= ""
Local cFim		:= ""
Local cCurso	:= RA1->RA1_CURSO 
Local cCargo 	:= ""

Local lQGint	:= FlQGint() //Integracao Quality

Local nTamGrupo	:=	TamSX3("Q3_GRUPO")[1]
Local nTamDepto	:=	TamSX3("Q3_DEPTO")[1]


Local oTmpTesTabFO1 
Local cTrTesAlias := GetNextAlias()
Local nTotLoop
Local nLoop
Local aFields := {}
Local __aStruSRA__
Private cArq2Ntx:= ""


dbSelectArea("SRA")
dbGoTop()
// Matricula
dbSetOrder(1)
cIndCond    := "RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC"
cFor		:= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC >="'
cFor		+=  FilialDe+MatDe+CcDe+FuncDe +'") .And.'
cFor		+= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC <="'
cFor		+=  FilialAte+MatAte+CcAte+FuncAte +'")'

__aStruSRA__ := SRA->(dbStruct())
nTotLoop	:= Len(__aStruSRA__)  

For nLoop:=1 To nTotLoop
	AADD(aFields,{	__aStruSRA__[nLoop,1]   ,;
       		        __aStruSRA__[nLoop,2]  	,;
			        __aStruSRA__[nLoop,3]  	,;
			        __aStruSRA__[nLoop,4]    }    )  
Next

oTmpTesTabFO1 := RhCriaTrab(cTrTesAlias, aFields, Nil)	


IndRegua("SRA",cTrTesAlias,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."
nIndex := RetIndex("SRA")

#IFNDEF TOP
	dbSetIndex(cTrTesAlias+OrdBagExt())
#ENDIF                              

dbSetOrder(nIndex+1)    
dbGoTop()
                            
oProcess:SetRegua1(SRA->(RecCount()))
oProcess:SaveLog(STR0004 + ": " + STR0031 + " - " + STR0046)	//"Inicio do Processamento"
      
      
                                
While !Eof() 	

	oProcess:IncRegua1(OemToAnsi(STR0030)+OemToAnsi(STR0036),,.T.) //"Aguarde..."###" Excluindo Registros ...." 
	oProcess:SetRegua2(1)  

	If lOfuscaNom
		oProcess:IncRegua2(STR0019+" / "+STR0018+": "+SRA->RA_FILIAL+" / "+SRA->RA_MAT) // Filial / Matricula                                                                                   
	else
		oProcess:IncRegua2(STR0019+" / "+STR0017+": "+SRA->RA_FILIAL+" / "+Left(SRA->RA_NOME,25)) // Filial / Nome	
	ENDIF	
	
	//��������������������������������������������������������������Ŀ
	//� Consiste controle de acessos e filiais validas				 |
	//����������������������������������������������������������������
    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
       dbSkip()
       Loop
    EndIf
    
	If 	SRA->RA_CC 		< CcDe 	.Or. SRA->RA_CC 		> CcAte 	.Or.;
		SRA->RA_MAT 	< MatDe .Or. SRA->RA_MAT 		> MatAte	.Or.;
		SRA->RA_CODFUNC	< FuncDe.Or. SRA->RA_CODFUNC 	> FuncAte
		dbSkip()
		Loop
	EndIf
    
	cGrupo := Space(nTamGrupo)
	cDepto := Space(nTamDepto)
    cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
	
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cCargo)
		cGrupo := SQ3->Q3_GRUPO 
		cDepto := SQ3->Q3_DEPTO
	EndIf
	
	dbSelectArea("SRA")              
	If cGrupo < GrupoDe .Or. cGrupo > GrupoAte .Or.;
		cDepto < DeptoDe .Or. cDepto > DeptoAte .Or.;
		SRA->RA_SINDICA < SindDe .Or. SRA->RA_SINDICA > SindAte
		dbSkip()
		Loop
	EndIf
	
	// Posiciona e elimina o curso Gerado por este programa
	dbSelectArea("RA4")
	dbSetOrder(1)
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cCurso) 
	   While SRA->RA_FILIAL  + SRA->RA_MAT  + cCurso == ;
	         RA4->RA4_FILIAL + RA4->RA4_MAT + RA4->RA4_CURSO  .AND. RA4->(!Eof()) 
	      
	      //-- Despreza Datas Fora do Periodo Selecionado   
	   	  If  RA4->RA4_DataIn < DataDe .Or. RA4->RA4_DataIn > DataAte
	   	      RA4->(DbSkip())
	   	      Loop
	   	  Endif                          
	   	  
	   	  //-- Verifica se Curso Foi Gerado pela Rotina de Registro
		  If RA4->RA4_TIPO =="1" 
			IF lQGint    
				Tr020DlDoc()
			Endif			   
		    nEliminados++
	   	  	RecLock("RA4",.F.)  
       	  	RA4->(DbDelete())
	      	RA4->(MsUnlock())
	      Endif             
	      RA4->(DbSkip())
	  Enddo   
	Endif
	
	dbSelectArea("SRA")	
	dbSkip()
EndDo 

oProcess:SaveLog(STR0004 + ": " + STR0031 + " - " + STR0047)	//"T�rmino do Processamento"
   
dbSelectArea("SRA")
Set Filter To
RetIndex("SRA")
dbSetOrder(1)               

If oTmpTesTabFO1 <> Nil
    oTmpTesTabFO1:Delete()
    Freeobj(oTmpTesTabFO1)
EndIf 

RestArea(aAreaSra)
RestArea(aArea)

Return nEliminados

                                               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Tr020Monta� Autor � Mauricio MR          � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta os listbox da reserva dos treinamentos               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020Monta(ExpC1,ExpC2)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpC2 : Codigo do Curso                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Tr020Monta(cAlias,cCurso, oSelf) 

Local aArea	   	:= GetArea(),lRet:=.T.
Local cIndCond 	:= ""
Local cFor		:= ""
Local cDescCC	:= ""
Local cDescFunc	:= ""   
Local nBMarca	:= 0
Local nBConcl	:= 0
Local nIndex	:= 0
Local cGrupo	:= ""
Local cDepto	:= ""
Local cAcessaSRA:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local cSituacao := MV_PAR16
Local nFerProg  := MV_PAR17
Local cSitFol   := ""
Local cCargo 	:= ""
Local nTamGrupo	:=	TamSX3("Q3_GRUPO")[1]
Local nTamDepto	:=	TamSX3("Q3_DEPTO")[1]
Local cTrTesAlias := GetNextAlias()
Local oTmpTesTabFO1

Local nTotLoop
Local nLoop
Local aFields := {}
Local __aStruSRA__ 

aVetor := {}   //o usuario pode voltar ao grid inicial da janela e clicar em registrar de novo...entao, sempre re-inicamos o array                 
dbSelectArea("SRA")
dbGoTop()

If Ordem == 1	       // Nome      
	dbSetOrder(3)
	cIndCond    := "RA_FILIAL+RA_NOME"
	cFor		:= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC >="'
	cFor		+=  FilialDe+MatDe+CcDe+FuncDe +'") .And.'
	cFor		+= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC <="'
	cFor		+=  FilialAte+MatAte+CcAte+FuncAte +'")'
ElseIf Ordem == 2		// Matricula
	dbSetOrder(1)
	cIndCond    := "RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC"
	cFor		:= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC >="'
	cFor		+=  FilialDe+MatDe+CcDe+FuncDe +'") .And.'
	cFor		+= '(RA_FILIAL+RA_MAT+RA_CC+RA_CODFUNC <="'
	cFor		+=  FilialAte+MatAte+CcAte+FuncAte +'")'
ElseIf Ordem == 3		// Centro Custo
	dbSetOrder(2)
	cIndCond	:= "RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC"
	cFor		:= 'RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC >="'
	cFor		+=  FilialDe+CcDe+MatDe+FuncDe +'" .And.'
	cFor		+= 'RA_FILIAL+RA_CC+RA_MAT+RA_CODFUNC <="'
	cFor		+=  FilialAte+CcAte+MatAte+FuncAte +'"'
ElseIf Ordem == 4		// Funcao
	dbSetOrder(7)
	cIndCond	:= "RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC"		
	cFor		:= 'RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC >="'
	cFor		+=  FilialDe+FuncDe+MatDe+CcDe + '" .And.'
	cFor		+= 'RA_FILIAL+RA_CODFUNC+RA_MAT+RA_CC <="'
	cFor		+=  FilialAte+FuncAte+MatAte+CcAte + '"'
EndIf	

__aStruSRA__ := SRA->(dbStruct())
nTotLoop	:= Len(__aStruSRA__)  

For nLoop:=1 To nTotLoop
	AADD(aFields,{	__aStruSRA__[nLoop,1]   ,;
       		        __aStruSRA__[nLoop,2]  	,;
			        __aStruSRA__[nLoop,3]  	,;
			        __aStruSRA__[nLoop,4]    }    )  
Next


oTmpTesTabFO1 := RhCriaTrab(cTrTesAlias, aFields, Nil)	

IndRegua("SRA",cTrTesAlias,cIndCond,,cFor,,.F.)		//"Selecionando Registros..."
nIndex := RetIndex("SRA")

#IFNDEF TOP
	dbSetIndex(cTrTesAlias+OrdBagExt())
#ENDIF       
                  


dbSetOrder(nIndex+1)
dbGoTop()
  
oSelf:SetRegua1(SRA->(RecCount()))
oSelf:SaveLog(STR0004 + ": " + STR0003 + " - " + STR0046) //"Inicio do Processamento"

While !Eof() 	            

	oSelf:IncRegua1(OemToAnsi(STR0030)+OemToAnsi(STR0029)) //"Aguarde..."###" Montando tela de Registro de Treinamentos"
	oSelf:SetRegua2(1)

	If lOfuscaNom
		oSelf:IncRegua2(STR0019+" / "+STR0018+": "+SRA->RA_FILIAL+" / "+SRA->RA_MAT) // Filial / Matricula                                                                                   
	else
		oSelf:IncRegua2(STR0019+" / "+STR0017+": "+SRA->RA_FILIAL+" / "+Left(SRA->RA_NOME,25)) // Filial / Nome	
	ENDIF

	//��������������������������������������������������������������Ŀ
	//� Consiste controle de acessos e filiais validas				 |
	//����������������������������������������������������������������
    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
       dbSkip()
       Loop
    EndIf
    
	If Ordem == 1	.Or. Ordem == 2		// Matricula
		If SRA->RA_CC < CcDe .Or. SRA->RA_CC > CcAte .Or.;
			SRA->RA_MAT < MatDe .Or. SRA->RA_MAT > MatAte .Or.;
			SRA->RA_CODFUNC < FuncDe .Or. SRA->RA_CODFUNC > FuncAte
			dbSkip()
			Loop
		EndIf
	ElseIf Ordem == 3		// Centro de Custo
		If 	SRA->RA_MAT < MatDe .Or. SRA->RA_MAT > MatAte .Or.;
			SRA->RA_CODFUNC < FuncDe .Or. SRA->RA_CODFUNC > FuncAte
			dbSkip()
			Loop
		EndIf
	ElseIf Ordem == 4		// Funcao
		If 	SRA->RA_MAT < MatDe .Or. SRA->RA_MAT > MatAte .Or.;
		    SRA->RA_CC < CcDe .Or. SRA->RA_CC > CcAte
			dbSkip()
			Loop
		EndIf				
	EndIf	
   
	//��������������������������Ŀ
	//� Situacao do Funcionario  �
	//����������������������������
	cSitFol := TrmSitFol(dDataBase,"C")                       
		                              
	dbSelectArea("SRA")
	
	If (!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P")) .Or.;
		(cSitfol == "P" .And. nFerProg == 2)
		dbSkip()
		Loop
	EndIf
    
	cGrupo := Space(nTamGrupo)
	cDepto := Space(nTamDepto)
    cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
    	
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cCargo)
		cGrupo := SQ3->Q3_GRUPO 
		cDepto := SQ3->Q3_DEPTO
	EndIf
	
	dbSelectArea("SRA")              
	If 	cGrupo 			< GrupoDe 	.Or. cGrupo 			> GrupoAte .Or.;
		cDepto 			< DeptoDe 	.Or. cDepto 			> DeptoAte .Or.;
		SRA->RA_SINDICA < SindDe 	.Or. SRA->RA_SINDICA 	> SindAte
		dbSkip()
		Loop
	EndIf
	
	nBMarca 	:= 1
	nBConcl		:= 1
	
	// Verificando se ja fez o curso
	dbSelectArea("RA4")
	dbSetOrder(1)
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cCurso) 
	    
		nBConcl:= 2
	EndIf

	dbSelectArea("SRA")
	// Montando o ListBox 1
	cDescCC	 := FDesc("SI3",SRA->RA_CC,"SI3->I3_DESC",30)
	cDescFunc:= FDesc("SRJ",SRA->RA_CODFUNC,"SRJ->RJ_DESC",30)
	
	RecLock(cTr1Alias,.T.)  

	(cTr1Alias)->(TR1_MARCA)		:= nBMarca
	(cTr1Alias)->(TR1_CONCL)		:= nBConcl
	(cTr1Alias)->(TR1_FILIAL)		:= SRA->RA_FILIAL
	(cTr1Alias)->(TR1_NOME)			:= If(lOfuscaNom,Replicate('*',15),SRA->RA_NOME)
	(cTr1Alias)->(TR1_MAT)			:= SRA->RA_MAT
	(cTr1Alias)->(TR1_CC)			:= SRA->RA_CC
	(cTr1Alias)->(TR1_DESCCC)		:= cDescCC
	(cTr1Alias)->(TR1_FUNCAO)		:= SRA->RA_CODFUNC
	(cTr1Alias)->(TR1_DESCFUN)		:= cDescFunc  
	(cTr1Alias)->(TR1_NOTA)			:= 0  
	(cTr1Alias)->(TR1_PRESEN)		:= 0 
		
	(cTr1Alias)->(MsUnlock()	)
	
	AADD(aVetor, { iif ((cTr1Alias)->(TR1_MARCA)==1,o1Ok,oNo),;
									(cTr1Alias)->(TR1_FILIAL),;
									(cTr1Alias)->(TR1_MAT),;
									(cTr1Alias)->(TR1_NOME),;
									(cTr1Alias)->(TR1_CC),;
									(cTr1Alias)->(TR1_DESCCC),;
									(cTr1Alias)->(TR1_FUNCAO),;
									(cTr1Alias)->(TR1_DESCFUN)} )
	
	dbSelectArea("SRA")	
	dbSkip()
EndDo    


If oTmpTesTabFO1 <> Nil
    oTmpTesTabFO1:Delete()
    Freeobj(oTmpTesTabFO1)
EndIf 

oSelf:SaveLog(STR0004 + ": " + STR0003 + " - " + STR0047)	//"T�rmino do Processamento"

//-- Se nao foram encontrados funcionarios de acordo com os parametros passados
//-- retorna .f. para abandonar rotina
If (cTr1Alias)->(LastRec())<1
	lRet:=.F.
Endif          

dbSelectArea(cTr1Alias)
dbGotop()

RestArea(aArea)

Return lRet


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020CriaArq� Autor � Mauricio MR         � Data � 28.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria arquivo para gravar os dados do listbox 2              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trmm020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020CriaArq()
Local a1Stru	:= {}
Local aArea		:= GetArea()
Local cCond		:= ""
Local aLstIndices := {}

Aadd(a1Stru,{"TR1_MARCA",    "N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_CONCL"	,"N", 1,                       0                       } )
Aadd(a1Stru,{"TR1_FILIAL",   "C", FWGETTAMFILIAL,          0                       } )
Aadd(a1Stru,{"TR1_NOME",     "C", TamSx3("RA_NOME")[1],    TamSx3("RA_NOME")[2]    } )
Aadd(a1Stru,{"TR1_MAT",      "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
Aadd(a1Stru,{"TR1_CC",       "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
Aadd(a1Stru,{"TR1_DESCCC",   "C", TamSx3("CTT_DESC01")[1], TamSx3("CTT_DESC01")[2] } )
Aadd(a1Stru,{"TR1_FUNCAO",   "C", TamSx3("RA_CODFUNC")[1], TamSx3("RA_CODFUNC")[2] } )
Aadd(a1Stru,{"TR1_DESCFU",   "C", TamSx3("RJ_DESC")[1],    TamSx3("RJ_DESC")[2]    } )
Aadd(a1Stru,{"TR1_NOTA"		,"N", 6,                       2                       } )
Aadd(a1Stru,{"TR1_PRESEN"	,"N", 6,                       2                       } )

//Ordem 1-Nome 2-Matricula 3-Centro Custo 4-Funcao
If Ordem == 1				// Nome
    Aadd( aLstIndices,{"TR1_FILIAL","TR1_NOME"}   )
ElseIf Ordem == 2			// Matricula
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_MAT"}    )
ElseIf Ordem == 3			// Centro de Custo
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_CC"}     )
ElseIf Ordem == 4			// Funcao
	Aadd( aLstIndices,{"TR1_FILIAL","TR1_FUNCAO"} )
EndIf

oTmpTabFO1 := RhCriaTrab(cTr1Alias, a1Stru, aLstIndices)	

RestArea(aArea)
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020OnOff    � Autor �Mauricio MR       � Data � 05.02.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � LigaDesliga Botoes	                 			          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020OnOff()		                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA0020                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020OnOff(lPrev)

Default lPrev:=.T.
//-- Se o Botao NEXT chamou a funcao
If !lPrev   
   //-- Se Todos os Funcionarios foram movidos para o GetDados
   If Len(aCols)==(cTr1Alias)->(Lastrec())                          
      //-- Habilita Botoes Next
      oBtn3:lReadOnly:=.F.
      oBtn4:lReadOnly:=.F. 
      //-- Desabilita Botoes Prev
      oBtn1:lReadOnly:=.T.
      oBtn2:lReadOnly:=.T. 
   Endif 
   //-- Habilita Todos os Botoes somente se houver pelo menos 1 funcionario escolhido   //-- 
   If Len(aCols)>0 .AND. !Empty(aCols[1,nPosMat])

      //-- Habilita Botoes NEXT  
      oBtn3:lReadOnly:=.F.
      oBtn4:lReadOnly:=.F. 
      //-- Habilita Botoes Prev
      oBtn1:lReadOnly:=.F.
      oBtn2:lReadOnly:=.F.  
   Endif   
Else 
//-- Se o Botao PREV chamou a funcao                   
   //-- Se o GetDados Possui Apenas uma linha em branco)
   If Len(aCols)==1 .AND. Empty(aCols[1,nPosMat])
      //-- Habilita Botoes Prev
      oBtn1:lReadOnly:=.F.
      oBtn2:lReadOnly:=.F. 

      //-- Desabilita Botoes Next
      oBtn3:lReadOnly:=.T.
      oBtn4:lReadOnly:=.T.
   Endif  
Endif

Return(Nil)          

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020EncOk� Autor � Mauricio MR           � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Gets da Enchoice                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trmm020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Tr020EncOk()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaRA0	:= RA0->(GetArea())
Local aAreaRA1	:= RA1->(GetArea())

//Verifica se variavel Codigo entidade eh valida

dbSelectArea("RA0")
dbSetOrder(1)
If !dbSeek(xFilial("RA0")+M->RA4_ENTIDA)
	Help( ""  ,1  ,"REGNOIS", , OemToAnsi( cTitEntidade ) , 5 , 0 )
	lRet:= .F.
Else
	M->RA4_DESCEN:=RA0->RA0_DESC
EndIf
RestArea(aAreaRA0)
   
//Verifica se variavel Codigo Curso eh valida
dbSelectArea("RA1")
dbSetOrder(1)
If !dbSeek(xFilial("RA1")+	M->RA4_CURSO) .AND. lRet
	Help( ""  ,1  ,"REGNOIS", , OemToAnsi( cTitCurso ) , 5 , 0 )
	lRet:= .F.
Else
	M->RA4_DESCCU:=RA1->RA1_DESC
EndIf     
RestArea(aAreaRA1)   

//Verifica se variavel Data inicio do Curso foi informada
If Empty(M->RA4_DATAIN).AND. lRet
	Help( ""  ,1  ,"RA4_DATAIN", , , 5 , 0 )
	lRet:= .F.
Endif

//Verifica se variavel Data Fim do Curso foi informada
If Empty(M->RA4_DATAFI).AND. lRet
	Help( ""  ,1  ,"RA4_DATAFI", , , 5 , 0 )
	lRet:= .F.
Endif

RestArea(aArea)
Return lRet
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020Header� Autor � Mauricio MR           � Data � 30/01/02 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Cria o Array Aheader                                        ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Tr020Header                                                 ���
���������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020Header(aNaoMostrar)
Local aSaveArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Define aHeader para GetDados                                 �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RA4")
nUsado:=0
While !EOF() .And. (x3_arquivo == "RA4")
	lMostra:=ASCAN(aNaoMostrar,Trim(x3_campo)) == 0
	//-- Forca Mostrar campos
	IF  ( (x3Uso(x3_Usado) .AND. lMostra)   .OR. (!x3Uso(x3_Usado).AND. lMostra) );
		.AND.   cNivel >= x3_nivel
		nUsado++
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo } )
	Endif
	dbSkip()
EndDo

RestArea(aSaveArea)	
Return .T.

/*/
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020Cols  � Autor � Mauricio MR           � Data � 30/01/02 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa o Array aCols                                    ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Tr020Header                                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020Cols(aNaoMostrar)
Local aArea		:= GetArea() 
Local nElem		:= Len(aCols) 

nUsado := 0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("RA4")
While !EOF() .And. (x3_arquivo == "RA4")
	lMostra:=ASCAN(aNaoMostrar,Trim(x3_campo)) == 0
	//-- Forca Mostrar campos
	IF  ( (x3Uso(x3_Usado) .AND. lMostra)   .OR. (!x3Uso(x3_Usado).AND. lMostra) );
		.AND.   cNivel >= x3_nivel
		nUsado++
		//�����������������������������������������������������Ŀ
		//� Monta array de 1 elemento vazio. Se inclus�o.       �
		//�������������������������������������������������������
		If x3_context == "V"
			aCOLS[nElem][nUsado] := CriaVar(AllTrim(x3_campo))
			Aadd ( aVirtual , AllTrim(x3_campo) )
		Endif
		IF x3_tipo == "C"
			aCOLS[nElem][nUsado] := SPACE(x3_tamanho)
		ELSEIF x3_tipo == "N"
			aCOLS[nElem][nUsado] := 0
		ELSEIF x3_tipo == "D"
			aCOLS[nElem][nUsado] := CTOD("")
		ELSE
			aCOLS[nElem][nUsado] := .F.
		Endif
	Endif
	dbSkip()
EndDo                 
aCOLS[nElem,nUsado+1] := .F.
                       
RestArea(aArea)	
Return .T.	

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020AllOk� Autor � Mauricio MR           � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Gets de Todas as Linhas                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trmm020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Tr020AllOk()
Local lRet	:= .T.

Return lRet
      
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020LinOk� Autor � Mauricio MR           � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Gets da Linha                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trmm020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Tr020LinOk()
Local lRet	:= .T.
//Nao permite Matricula em Branco (Linha Vazia)
If Empty(aCols[n,nPosMat])
   lRet	:= .F.
Endif
Return lRet
 

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020Grava� Autor � Mauricio MR           � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente ao treinamentos                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpC1 : Codigo curso                                       ��� 
���          � ExpL2 : Sobrepoe Registro Gerado                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA201                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020Grava(cCurso,lSubstitui, aMemoRA4)

Local aArea		:= GetArea()
Local aTr1Area  := (cTr1Alias)->(GetArea())
Local ny        := 0  
Local nZ        := 0
Local ni		:= 0
Local nMaxArray := Len(aHeader)
Local nPos		:= 0
Local naCols    := Len(aCols) 
Local xConteudo	:= ""   
Local lAppenda	:= .T.
Local lGrava	:= .T.  
Local nCpos		:= 0
Local cCampo	:= ""
Local cVar		:= ""
Local lQGint	:= FlQGint() //Integracao Quality  
Local nLoop		:= 0

If Len(aCols)=1 .AND. Empty(aCols[1,nPosMat])
   Alert(OemtoAnsi(STR0032)) //## "Funcionarios Nao Selecionados"
   Return(.F.)
Endif

If !Tr020EncOK()
   Return(.F.)
Endif
//-- Abre inicio da transacao de gravacao e eliminacao de itens
Begin Transaction

    dbSelectArea("RA4")
	dbSetOrder(1)
	
	For nZ := 1 TO naCols   
	    //--Despreza marcados como deletados
		If aCols[nZ,nUsado+1] 
			Loop
		Endif
	
		lAppenda 	:= .T.
		lGrava		:= .T.          
		
        //-- Posiciona no Curso 
		If RA4->(dbSeek(aCols[nz,nPosFilial]+aCols[nz,nPosMat]+cCurso))
		   While (aCols[nz,nPosFilial]+aCols[nz,nPosMat]+cCurso) ==;
				  RA4->RA4_FILIAL+RA4->RA4_MAT+RA4->RA4_CURSO .AND. (!Eof())
				 				  				      
				//-- Verifica se o Curso Foi Gerado pela Rotina de Registro
				If ( RA4->RA4_TIPO == "1" .Or. ( Empty(RA4->RA4_CALEND) .Or. Empty(RA4->RA4_TURMA) )).AND.RA4->RA4_DATAIN == M->RA4_DATAIN 
					lAppenda := .F. 
				   	lGrava	 := If(lSubstitui,.T.,.F.)
					Exit
				EndIf	
				dbSkip()
			EndDo	
		EndIf		
    
        //-- Grava Registro (Se lSubstitui = .F. e o registro de treinamento ja existente
        //-- nao sobrepoe)
        If lGrava  
			RecLock("RA4",lAppenda)   
			
			// Grava informacoes genericas da Enchoice
			nCpos := FCount()
			For ni := 1 To nCpos 
				cCampo 	:= "RA4->"+FieldName(ni)
				cVar	:=	"M->"+FieldName(ni)  
				
				If Type(cVar) <> "U"
					&cCampo	:= &cVar
				EndIf	
				
			Next ni
			
			// Grava informacoes individuais da GetDados
			For ny := 1 To nMaxArray
				cCampo    := Trim(aHeader[ny][2])
				//-- Grava Campos Nao Virtuais
				If (nPos := Ascan(aVirtual,cCampo)) == 0
					xConteudo := aCols[nZ,ny]
					RA4->&cCampo := xConteudo
				Endif 
			Next ny                              
		    
		    //-- Grava Informacoes Complementares     
			Replace RA4_TIPO	With 	"1"  //Flag indicando que o curso foi gerado por esta rotina
			                                                                  
			//��������������������������������������������������������������Ŀ
			//�Grava os campos memo de usuario                               �
			//����������������������������������������������������������������
			For nLoop := 1 To Len( aMemoRA4 ) 
				APDMSMM( &(aMemoRA4[nLoop][1]),,, M->&( aMemoRA4[nLoop,2] ),1,,,"RA4",(aMemoRA4[nLoop][1]))
			Next nLoop 
			
			
			RA4->( MsUnlock() ) 
			IF lQGint    
				Tr020GDoc(lAppenda)
			Endif	
			
		Endif
	Next nZ
   	
End Transaction
RestArea(aTR1Area)
RestArea(aArea) 
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr020Sai  � Autor � Mauricio MR           � Data � 29.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se abandona Rotina                                 ���
�������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trmm020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020Sai()
Local lRet:=.T.
//-- Se existir pelo menos 1 funcionario selecionado 
If Len(aCols)>0 .AND. !Empty(aCols[1,nPosMat])
	//-- Verifica Se NAO Abandona, entao, retorna a geracao de treinamentos coletivos
	If !MsgYesNo(OemtoAnsi(STR0035),OemtoAnsi(STR0020)) //#"Confirma Abandono da rotina?" #"Aten��o"
	   lRet:=.F.
	Endif   
Endif
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fMoveToGet    � Autor �Mauricio MR       � Data � 31.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Move Funcionario para oGetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fMoveToGet(lTodos)                                         ���
���          �            lTodos         .T. move Todos os Funcionarios.  ���
���          �                           .F. move Funcinario Atual.       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fMoveToGet(lTodos, aVetor)                

Local aArea		:= GetArea()
Local nAnterior	:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.
Local nLi		:= Len(aCols)   
LocaL nRecTr1Alias := 0
Default lTodos	:= .F.

dbSelectArea(cTr1Alias) 
nRecno	:= nInicio	:= o1Lbx:nAt

//-- Determina a Abrangencia
If lTodos
   dbGoTop()               
   nFim		:= Len(aVetor)
   nInicio	:= 1
Else
   nFim     := o1Lbx:nAt 
Endif     

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)
For nRec:=nInicio To nFim
   If aVetor [nRec][1] == o1Ok          
	  //-- Adiciona Funcionario   
      //-- Altera Cor indicando que funcionario foi selecionado
      nRecTr1Alias := Tr020Marca(@aVetor, nRec,.T.)  
      dbSelectArea(cTr1Alias)
      If !Empty(aCols[1,nPosMat]) //Na primeira vez, o campo estah em branco
          AADD(aCols,aClone(aColsVazio))  
      Endif                    
      //-- Obtem o ultimo Elemento do aCols         
      nLi:=Len(aCols)   
      //-- Preenche-o com as informacoes
      aCols[nli,nPosFilial]	:= aVetor[nRec,2]
      aCols[nli,nPosNome]	:= aVetor[nRec,4]
      aCols[nli,nPosMat]	:= aVetor[nRec,3]
      aCols[nli,nPosNota]	:= M->RA4_NOTA   // Padrao vindo da Enchoice
      aCols[nli,nPosPresen]	:= M->RA4_PRESEN // Padrao vindo da Enchoice
       
      //-- Armazena o Recno da origem das informacoes da linha da GetDados
      AADD(aTr1Rec, {aVetor[nRec,2],aVetor[nRec,3], nRecTr1Alias/*foi posicionado no tr020marca*/ } )
      
      lRet := .T.  		     
   Endif      
       
Next nRec

RestArea(aArea)

o1Lbx:Refresh(.T.)
o1Lbx:DrawSelect()
nAnterior	:= n 
oGet:ForceRefresh()      
n	:= nAnterior           

//-- Liga/Desliga botoes
Tr020OnOff(.F.)


Return lREt         


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fMoveToList   � Autor �Mauricio MR       � Data � 31.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Move Funcionario para  ListBox                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fMoveToList(lTodos)                                        ���
���          �            lTodos         .T. move Todos os Funcionarios.  ���
���          �                           .F. move Funcinario Atual.       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static function fMoveToList(lTodos, aVetor)                
Local aArea		:= GetArea()
Local nPosicao	:= 0
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.    
Local nListN	:= o1Lbx:nAt

//-- Se Nao Existirem elementos no GetDados nao Move Nada
If Len(aTr1Rec)==0
   Return lRet
Endif
   
Default lTodos:=.F.

//-- Determina a Abrangencia
If lTodos
   //-- Exibe Mensagem de Aviso 
   If !ApMsgYesNo( OemtoAnsi(STR0027),OemtoAnsi(STR0023) ) // ##" Desfazer Escolha de Funcionarios e Digitacao de Notas e Presencas? " ##
      Return lRet 
   Endif   
   nFim		:= Len(aCols)
   nInicio	:= 1
Else
   nPosicao:=nInicio:=nFim:=n
Endif

dbSelectArea(cTr1Alias) 

//--Marca Funcionarios de Acordo com a Abrangencia (Todos ou especifico)

For nRec:=nInicio To nFim
	(cTr1Alias)->(dbGoto(aTr1Rec[nRec,3]))
    Tr020Marca(@aVetor,nRec,.F.)
    dbSelectArea(cTr1Alias)
Next nRec

// Elimina os Elementos Escolhidos do array aCols do GetDados
If lTodos 
    //-- Cria 1 Elemento vazio no GetDados
  	aCols:={Aclone(aColsVazio)}
	//-- Elimina o array de posicionamento dos registros no ListBox(TR1)
	aTr1Rec:={}

Else
	//-- Retira da GetDados
	If (Len(aCols)-1)>0
		Adel(aCols,nPosicao) 
		ASize(aCols,Len(aCols)-1)
	Else
	    //-- Cria 1 Elemento vazio no GetDados
  	    aCols:={Aclone(aColsVazio)}
	Endif 
	//-- Elimina Elemento do array de posicao dos registros no ListBox(TR1)
	Adel(aTr1Rec,nPosicao) 
	ASize(aTr1Rec,Len(aTr1Rec)-1)	
Endif

//(cTr1Alias)->(DbGoto(nRecno))
o1Lbx:nAt:=nListN
o1Lbx:Refresh(.T.)

n:=1           
OGET:OBROWSE:NLEN:=Len(aCols)
oGet:oBrowse:Refresh()      

RestArea(aArea)

//-- Liga/Desliga botoes
Tr020OnOff(.T.)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020Marca    � Autor �Mauricio MR       � Data � 31.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca Funcionario                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020Marca()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020Marca(aVetor, nRec, lAdiciona)
Local aArea	  := GetArea()
Local cAliasQry := GetNextAlias()
Local ctesteTableName := oTmpTabFO1:GetRealName()
Local cSql
Local nIndice

Local nRecTr1Alias := 0

If lAdiciona
	If aVetor[nRec][1] == o1Ok
		aVetor[nRec][1] := oNo
	Else
		aVetor[nRec][1] := o1Ok
	EndIf
	
	cSQL := " SELECT * FROM " + ctesteTableName 
	cSql += " 		WHERE  "
	cSql += " 		TR1_FILIAL  = '" + aVetor[nRec,2] + "' and "
	cSql += " 		TR1_MAT     = '" + aVetor[nRec,3] + "' and "
	cSql += " 		TR1_NOME    = '" + aVetor[nRec,4] + "' and "
	cSql += " 		TR1_CC      = '" + aVetor[nRec,5] + "' and "
	cSql += " 		TR1_DESCCC  = '" + aVetor[nRec,6] + "' and "
	cSql += " 		TR1_FUNCAO  = '" + aVetor[nRec,7] + "' and D_E_L_E_T_ = '' "
	
	//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
	DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
	
	If (cAliasQry)->(!Eof())
		(cTr1Alias)->( DbGoTo(   (cAliasQry)->(R_E_C_N_O_)     ) )
		
		RecLock(cTr1Alias,.F.,.T.)
		
		If aVetor[nRec][1] == o1Ok
			(cTr1Alias)->(TR1_MARCA) := 1//IIF((cTr1Alias)->(TR1_MARCA)==1,2,1)
		Else
			(cTr1Alias)->(TR1_MARCA) := 2
		EndIf
		
		(cTr1Alias)->(MsUnlock())
		nRecTr1Alias := (cTr1Alias)->(Recno())//somente para este caso o retorno sera utilizado
		
	EndIf
	
	(cAliasQry)->(DbCloseArea())

Else
    //remove da lista do grid da direita(de selecionados)
	nIndice := Ascan(aVetor,{|x| (cTr1Alias)->(TR1_FILIAL) = x[2]  .and.  (cTr1Alias)->(TR1_MAT) = x[3] .and.   ;
	                             (cTr1Alias)->(TR1_NOME)   = x[4]  .and.  (cTr1Alias)->(TR1_CC)  = x[5] .and.  (cTr1Alias)->(TR1_DESCCC)= x[6] })

	If nIndice > 0 
		If aVetor[nIndice][1] == o1Ok
			aVetor[nIndice][1] := oNo
		Else
			aVetor[nIndice][1] := o1Ok
		EndIf
	
		RecLock(cTr1Alias,.F.,.T.)
			
		If aVetor[nIndice][1] == o1Ok
			(cTr1Alias)->(TR1_MARCA) := 1
		Else
			(cTr1Alias)->(TR1_MARCA) := 2
		EndIf
			
		(cTr1Alias)->(MsUnlock())
		
	EndIf
EndIf

RestArea(aArea)

Return nRecTr1Alias
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020GDoc     � Autor �Telso Carneiro    � Data � 19/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os registros referentes a Documentos (Docs-Rv)       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr100GDoc(Apenda) 										  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Tr020GDoc(lAppenda)

Local aReaCur	:= GetArea()
Local cDocRev   
Local lNovRAO	:=.F.

RAN->(DbSetOrder(1))

//--Verifica se Nao esta Deletado no aCols
If lAppenda
	IF RAN->(DBSEEK(xFilial("RAN")+RA4->RA4_CURSO))
		DbSelectARea("RAO")
		DbSetOrder(1)
		IF !RAO->(DBSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN))))
			While RAN->(!EOF()) .AND. RA4->RA4_CURSO == RAN->RAN_CURSO
			    cDocRev:=QA_ULTRVDC(RAN->RAN_DOCTO,,.F.,.T.)
				RecLock("RAO",.T.)
				RAO->RAO_FILIAL := xFilial("RAO")
				RAO->RAO_CALEND := RA4->RA4_CALEND
				RAO->RAO_CURSO  := RA4->RA4_CURSO
				RAO->RAO_TURMA	:= RA4->RA4_TURMA
				RAO->RAO_MAT	:= RA4->RA4_MAT
				RAO->RAO_DATAIN := RA4->RA4_DATAIN
				RAO->RAO_TIPO   := RA4->RA4_TIPO
				RAO->RAO_DOCTO	:= RAN->RAN_DOCTO				
				RAO->RAO_RV		:= cDocRev
				MsUnlock()
				RAN->(DbSkip())
			Enddo
		Endif
	Endif
Else
	IF RAN->(DBSEEK(xFilial("RAN")+RA4->RA4_CURSO))
		DbSelectARea("RAO")
		DbSetOrder(1)
		While RAN->(!EOF()) .AND. RA4->RA4_CURSO == RAN->RAN_CURSO
			lNovRAO:=!RAO->(DBSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN)+RAN->RAN_DOCTO)))		    
			cDocRev:=QA_ULTRVDC(RAN->RAN_DOCTO,,.F.,.T.)
			RecLock("RAO",lNovRAO)
			RAO->RAO_FILIAL := xFilial("RAO")
			RAO->RAO_CALEND := RA4->RA4_CALEND
			RAO->RAO_CURSO  := RA4->RA4_CURSO
			RAO->RAO_TURMA	:= RA4->RA4_TURMA
			RAO->RAO_MAT	:= RA4->RA4_MAT
			RAO->RAO_DATAIN := RA4->RA4_DATAIN
			RAO->RAO_TIPO	:= RA4->RA4_TIPO
			RAO->RAO_DOCTO	:= RAN->RAN_DOCTO 								
			RAO->RAO_RV		:= cDocRev
			MsUnlock()		 
			RAN->(DbSkip())
		Enddo
	Endif
Endif
	
Restarea(aReaCur)

Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020DlDoc    � Autor �Telso Carneiro    � Data � 19/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclui os registros referentes a Documentos (Docs-Rv)      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020DlDoc()     										  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Tr020DlDoc()

Local aReaCur	:= GetArea()

DbSelectARea("RAO")
DbSetOrder(1)
		
IF RAO->(DBSEEK(xFilial("RAO")+RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN))))
	While RAO->(!EOF()) .AND. RA4->(RA4_CALEND+RA4_CURSO+RA4_TURMA+RA4_MAT+DTOS(RA4_DATAIN))== ;
			RAO->(RAO_CALEND+RAO_CURSO+RAO_TURMA+RAO_MAT+DTOS(RAO_DATAIN))
		IF RAO->RAO_TIPO =="1"	
			RecLock("RAO",.F.)
	        RAO->(DbDelete())
			MsUnlock()
		Endif	
		RAO->(DbSkip())
	Enddo
Endif
	
Restarea(aReaCur)

Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Tr020NMostra  � Autor �Emerson Grassi    � Data � 02/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna array c/campos que nao serao mostrados na Getdados.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tr020NMostra()                                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trmm020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr020NMostra()
Local aSaveArea	:= GetArea() 
Local aMostrar 	:= {"RA4_FILIAL","RA4_MAT","RA4_NOME","RA4_NOTA","RA4_PRESEN"}
Local aNMostrar	:= {}

dbSelectArea("SX3") 
dbSetOrder(1)
dbSeek("RA4") 
While ! Eof() .and. (SX3->X3_ARQUIVO == "RA4") 
    If Ascan(aMostrar,Upper(Trim(x3_campo))) == 0
		Aadd(aNMostrar,Upper(Trim(x3_campo)))
	Endif   
	dbSkip()
EndDo

RestArea(aSaveArea)

Return aNMostrar


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FlQGInt	 � Autor � Telso Carneiro		� Data � 13/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Integracao TRM com todos os Modulos do Quality	  		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TRMA100                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function FlQGint()
Local lRet	:=.F.
Local aArea	:=GetARea()

IF GETMV("MV_QGINT")=="S" .AND. ChkFile('RAN') .AND. ChkFile('RAO')
	lRet:=.T.
Endif

RestArea(aArea)

Return( lRet )


/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �26/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMM020                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina := {	{ STR0001,'PesqBrw'		, 0,1,,.F.},;	//"Pesquisar"
						{ STR0003,'Tr020Reg'	, 0,6},;	//"Registrar"
						{ STR0031,'Tr020Exc'	, 0,5}}		//"Excluir"


Return aRotina
