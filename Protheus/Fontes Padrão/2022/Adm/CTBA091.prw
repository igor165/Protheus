#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA091.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � CTBA091  � Autor � alfredo.medrano     � Data �  02/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ABC mnem�nicos                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CTBA091()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mantenimiento a mnem�nicos                                 ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���              �        �           �                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CTBA091()
Local 	 oBrowse
Private oArial10
Private lDescrip 
Private lDesGrup 
Private lTodos
Private cSetFun		:= "" // C�digo de Funci�n
Private lMensaje	:= .T.
Private lCmbBox 	:= .T.
Private lRetP		:= .T.
Private lMsg		:= .T.

oArial10 := tFont():New("Arial",,-10,,.t.) // fuente del Texto	
CTBA095()   // Llama al fuente para la carga automatica de tablas de sistema
//�������������������������������������������Ŀ
//�Browse Automatico contiene				: �
//�B�squeda de Registro 					  �
//�Filtro configurable						  �
//�Configuraci�n de columnas y apariencia 	  �
//�Impresi�n								  �
//���������������������������������������������
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias('CWJ')
oBrowse:SetDescription(OemToAnsi(STR0030)) // "Mnem�nicos"
oBrowse:SetMenuDef('CTBA091')
oBrowse:AddLegend( "CWJ_TIPO=='S'", "BLUE", OemToAnsi(STR0044)) //"Mnem�nico definido por Sistema"
oBrowse:AddLegend( "CWJ_TIPO=='U'", "GREEN"  , OemToAnsi(STR0045)) //"Mnem�nico definido por Usuario"

oBrowse:Activate()

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MenuDef  � Autor � Alfredo Medrano       � Data �02/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � define las operaciones que ser�n realizadas por la         ���
���          � aplicaci�n: incluir, alterar, excluir etc.                 ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � FWMVCMenu                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
// Genera un Menu Estandar en MVC sin Necesidad de aRotina.
Return FWMVCMenu( "CTBA091" ) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ModelDef � Autor � Alfredo Medrano       � Data �02/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Contiene la construcci�n y la definici�n del Modelo        ���
���          � (Model) contiene las reglas del negocio                    ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCWJ := FWFormStruct( 1, 'CWJ', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel


oModel:= MPFormModel():New('CTBA091M', { | oMdl | CTBA091PRE(oMdl) }, { | oMdl | CTBA091POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:addfields( 'CWJMASTER', /*cOwner*/, oStruCWJ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetPrimaryKey( {} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( OemToAnsi(STR0031) )// "Modelo de Dados - Mnem�nicos"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CWJMASTER' ):SetDescription( OemToAnsi(STR0032) ) // "Datos Mnem�nicos"
oModel:GetModel("CWJMASTER"):SetFldNoCopy({"CWJ_CODMNE"})

Return oModel

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ViewDef  � Autor � Alfredo Medrano       � Data �02/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Contiene la construcci�n y la definici�n de la View        ���
���          � construcci�n de la interfaz                                ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel	:= FWLoadModel( 'CTBA091' )
// Cria a estrutura a ser usada na View
Local oStruCWJ	:= FWFormStruct( 2, 'CWJ',/*{ |cCampo| COMP11STRU(cCampo) }*/  )
Local cTipo 	:="2"
Local oView

// Crio os Agrupamentos de Campos
//AddGroup( cID, cTitulo, cIDFolder, nType )   nType => ( 1=Janela; 2=Separador )
oStruCWJ:AddGroup( 'GRUPO01', '', '', 1 )
oStruCWJ:AddGroup( 'GRUPO02', OemToAnsi(STR0033), '', 1 ) // "Tablas"
oStruCWJ:AddGroup( 'GRUPO03', OemToAnsi(STR0034), '', 1 ) // "Campos"

// Altero propriedades dos campos da estrutura, no caso colocando cada campo no seu grupo
// SetProperty( <Campo>, <Propriedade>, <Valor> )

oStruCWJ:SetProperty( '*'		    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oStruCWJ:SetProperty( 'CWJ_TODAS1' ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruCWJ:SetProperty( 'CWJ_TABLA'  ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruCWJ:SetProperty( 'CWJ_TODAS2' ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
oStruCWJ:SetProperty( 'CWJ_CAMPO'  ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
oStruCWJ:SetProperty( 'CWJ_HELP'   ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

//Llena el combobox por default con el contenido de la tabla (CWH)
oStruCWJ:SetProperty( 'CWJ_TABLA'   ,	MVC_VIEW_COMBOBOX,  CWJAliasBox(cTipo) )
oStruCWJ:SetProperty( 'CWJ_CAMPO'   ,	MVC_VIEW_COMBOBOX, {space(16)} )

// Cria o objeto de View
oView := FWFormView():New()
 
// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CWJ', oStruCWJ, 'CWJMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CWJ', 'TELA' )

// Acciones del View
oView:SetViewAction( 'BUTTONCANCEL' ,{ |oView| CTBA091CN( oView ) } )
oView:SetViewAction( 'BUTTONOK' ,{ |oView| CTBA091TD( oView ) } )

Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBA091TD� Autor � Alfredo Medrano       � Data �07/01/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Guarda valores en blanco seg�n el Tipo de Mnem�nico        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA091TD(ExpO1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lActivo                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 :  objeto de interfaz view                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA091TD(oView) 
Local lActivo 	:= .T.
Local aArea		:= GetArea()
Local cCodMne 	:= GetMemVar("CWJ_CODMNE") //--- codigo del de Mnem�nico 
Local cTipoMne 	:= GetMemVar("CWJ_TIPDAT") //--- Identifica el tipo de Mnem�nico

If Altera .OR. Inclui

		DbSelectArea("CWJ") 
		IF CWJ->(DBSeek(XFILIAL("CWJ")+cCodMne))			
			//---BLOQUEA EL REGISTRO
		   	RECLOCK("CWJ",.F.)
/*/
�����������������������������������������������������������Ŀ
�Clasifica el mnem�nico.	 --> cTipoMne = CWJ_TIPDAT		�
�1=Campo de BD 												�
�2=Tabla													�
�3=Formula													�
�4=Funcion													�
�5=Funcion de usuario										�
�6=Valor													�               
�������������������������������������������������������������/*/	
		    //---ACTUALIZA INFORMACION  
		    If cTipoMne == "1"
		    
			    CWJ->CWJ_DATVIN := ""
		    	CWJ->CWJ_FUNRPO := ""
		    	CWJ->CWJ_VALOR 	:= ""
		    
		    ElseIf cTipoMne == "2"
		    
		    	CWJ->CWJ_DATVIN := ""
		    	CWJ->CWJ_FUNRPO := ""
		    	CWJ->CWJ_VALOR 	:= ""
		    	CWJ->CWJ_TODAS2 := "2"
		    	CWJ->CWJ_CAMPO 	:= ""
		    	
		    ElseIF cTipoMne $ "3|4"
		    
		    	CWJ->CWJ_FUNRPO := ""
		    	CWJ->CWJ_VALOR 	:= ""
		    	CWJ->CWJ_TODAS1 := "2"
		    	CWJ->CWJ_TODAS2 := "2"
		    	CWJ->CWJ_TABLA 	:= ""
		    	CWJ->CWJ_CAMPO 	:= ""
		    	
		    ElseIF cTipoMne == "5"
		    	
		    	CWJ->CWJ_DATVIN := ""
		    	CWJ->CWJ_VALOR 	:= ""
		    	CWJ->CWJ_TODAS1 := "2"
		    	CWJ->CWJ_TODAS2 := "2"
		    	CWJ->CWJ_TABLA 	:= ""
		    	CWJ->CWJ_CAMPO 	:= ""
		    
		    ElseIF cTipoMne == "6"
		    	
		    	CWJ->CWJ_DATVIN := ""
		    	CWJ->CWJ_FUNRPO := ""
		    	CWJ->CWJ_TODAS1 := "2"
		    	CWJ->CWJ_TODAS2 := "2"
		    	CWJ->CWJ_TABLA 	:= ""
		    	CWJ->CWJ_CAMPO 	:= ""
		    
		    EndIf
		
		    //---DESBLOQUEA REGISTRO
		    CWN->(MSUNLOCK())
		  EndIf	

EndIf	        
RestArea(aArea)		
Return lActivo

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBA091TD� Autor � Alfredo Medrano       � Data �26/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa el ComboBox                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LlenaCmbbox(ExpN1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aArray                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 :  N�mero que indica 1=tabla, 2=campo                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function LlenaCmbbox(nVal)
Local cTabla	:= CWJ->CWJ_TABLA
Local cTodas1	:= CWJ->CWJ_TODAS1
Local cTodas2	:= CWJ->CWJ_TODAS2
Local aArray	:= {}
Local aDatos	:= {}
Local aArea		:= GetArea()
Local cFil 	 	:= XFILIAL("CWI")

	If nVal==1 // Carga Tablas
		obtTablas(@aDatos,cTodas1 )
		aArray := aDatos
		
	ElseIF nVal==2 // Carga Campos
		If cTodas2 == "1" // campos (SX3)
			obtCampos(@aDatos,cTodas2,cTabla )
			aArray := aDatos
			
		ElseIf cTodas2 == "2"
			//campos (CWI)
			DbSelectArea("CWI") 
			CWI ->(DBSETORDER(1))
			CWI ->( dbSeek(cFil+cTabla) )	
			While  CWI->(!Eof()) .And. ( CWI_FILIAL+CWI_TABLA == cFil+cTabla ) 
				AADD( aArray, CWI->CWI_CAMPO + "=" + CWI->CWI_DESCRI )
				CWI->(dbskip())	 		
			EndDo
		EndIf
	EndIf				
RestArea(aArea)
Return aArray

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTBA091PRE� Autor � Alfredo Medrano       � Data �20/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pre-validaci�n del modelo                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA091PRE(ExpO1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 :  objeto de modelo de datos                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTBA091PRE(oModel)
Local nOperation	:= oModel:GetOperation()
Local lFormula 		:= .F.
Local lFuncion 		:= .F.
Local cTabla		:= CWJ->CWJ_TABLA
Local cTipo			:= CWJ->CWJ_TIPO
Local cCampo		:= CWJ->CWJ_CAMPO
Local oView 		:= FWViewActive() // obtiene el View activo
Local cTipDat		:= CWJ->CWJ_TIPDAT

If nOperation == MODEL_OPERATION_UPDATE

	lMsg := .F.
	// verifica si el Mnem�nico existe en una formula o Funci�n
	lFormula := ValNmoInFor()
	lFuncion := ValNmoInFun()
	
	// verifica que el mnem�nico no est� siendo utilizado por una formula ni utilizado por una Function 
	If !lFormula .AND. !lFuncion
		If cTipo == "S"  //Si el mnem�nico es de sistema Solo permitir modificar la descripci�n
			lDescrip := .T.
		Else
			lTodos := .T. // puede Editar todos los campos, excepto el c�digo 
		EndIf
	
	EndIf
	// El Mnem�nico esta siendo utilizado por una Funcion o Formula y es de sistema
	If (lFormula .OR. lFuncion) .And. cTipo == "S"
		lDescrip := .T.
	EndIf
	
	//est� siendo utilizado por una formula o Funcion y no es de sistema
	If (lFormula .OR. lFuncion) .And. cTipo == "U"
		lDesGrup := .T.
		lTodos := .F.
	EndIf
	
	
	/*
	��������������������������������������������������������������Ŀ
	�Clasifica el mnem�nico.	 --> cTipDat = CWJ_TIPDAT		   �
	�1=Campo de BD 												   �
	�2=Tabla													   �               
	����������������������������������������������������������������*/

	If cTipDat == "1"  
		If oView!=Nil .and. lCmbBox
			lCmbBox := .F.
		
			If lTodos
				oView:SetFieldProperty("CWJMASTER","CWJ_TABLA","COMBOVALUES",{LlenaCmbbox(1)})
				oView:SetFieldProperty("CWJMASTER","CWJ_CAMPO","COMBOVALUES",{LlenaCmbbox(2)})
				oModel:setValue("CWJMASTER","CWJ_TABLA",cTabla)
	            oModel:setValue("CWJMASTER","CWJ_CAMPO",cCampo) 
	            oView:Refresh()
			Else
	            oView:SetFieldProperty("CWJMASTER","CWJ_TABLA","COMBOVALUES",{{cTabla}})
				oView:SetFieldProperty("CWJMASTER","CWJ_CAMPO","COMBOVALUES",{{cCampo}})
				HelpFieldM() 
				oView:Refresh()
			EndIf
			
		EndIf
		
	EndIf
	
	If cTipDat == "2"  
		If oView!=Nil .and. lCmbBox
			lCmbBox := .F.
		
			If lTodos
				oView:SetFieldProperty("CWJMASTER","CWJ_TABLA","COMBOVALUES",{LlenaCmbbox(1)})
				oModel:setValue("CWJMASTER","CWJ_TABLA",cTabla)
	            oView:Refresh()
			Else
	            oView:SetFieldProperty("CWJMASTER","CWJ_TABLA","COMBOVALUES",{{cTabla}})
				HelpFieldM() 
				oView:Refresh()
			EndIf
			
		EndIf
		
	EndIf

ElseIf nOperation == MODEL_OPERATION_DELETE

	If oView!=Nil .and. lCmbBox
		lCmbBox:=.F.
		oView:SetFieldProperty("CWJMASTER","CWJ_TABLA","COMBOVALUES",{{cTabla}})
		oView:SetFieldProperty("CWJMASTER","CWJ_CAMPO","COMBOVALUES",{{cCampo}}) 
		oView:Refresh()
	EndIf

EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTBA091GPO� Autor � Alfredo Medrano       � Data �26/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Activa o desactiva grupo                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA091GPO()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_WHEN: CWJ_GRUPO                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA091GPO()
lRet	:= .t.
If Altera 
	If lDesGrup 
	    If lMensaje 
	         Aviso( OemToAnsi(STR0022),OemToAnsi(STR0029), {OemToAnsi(STR0007)} ) //"Aviso" //"Mnem�nico est� en uso de alguna f�rmula o funci�n, solo permitir� cambios en la Descripci�n y el grupo	         
	         lMensaje := .F.
	    EndIf    
	ELse
	  If lDescRip
	     lRet := .f.
	  EndIf         
	EndIF
EndIF	
Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBA091AB� Autor � Alfredo Medrano       � Data �26/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Activa o desactiva campos de formulario                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA091AB()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lActivo                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_WHEN: CWJ_TIPO, CWJ_TIPDAT, CWJ_DATVIN, CWJ_FUNRPO,     ���
���			 � CWJ_VALOR Y CWJ_TODAS1, CWJ_TODAS2                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA091AB() 
Local lActivo	:= .T.

IF Altera 
	If lTodos
		lActivo := .T.
	Else
	  	if lMensaje .AND. lDescrip
			Aviso( OemToAnsi(STR0022),OemToAnsi(STR0028), {OemToAnsi(STR0007)} )  //"Aviso" //"El mnem�nico seleccionado es de tipo Sistema y solo permitir� modificar la descripci�n"
			lMensaje := .F.
		endif
		lActivo := .F.
	EndIF

EndIf

Return lActivo


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CTBA091CN� Autor � Alfredo Medrano       � Data �26/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa Variables privadas                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA091CN()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA91                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTBA091CN(oView)

If lMsg 
 	lMensaje	:= .T.
 ElseIf oView!=Nil
 	lMensaje	:= .T.
EndIf

 lDescrip	:= .F.
 lDesGrup	:= .F.
 lTodos 	:= .F.
 lCmbBox 	:= .T.

Return .T. 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTBA091POS� Autor � Alfredo Medrano       � Data �20/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inicializa Variables privadas                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA091POS(ExpO1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 :  objeto de modelo de datos                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTBA091POS(oModel)
Local lRet       	:= .T.
Local lFormula 		:= .F.
Local lFuncion 		:= .F.
Local cTipo			:= getMemvar("CWJ_TIPO")
Local cTipoFun		:= getMemvar("CWJ_TIPDAT")
Local aArea			:= GetArea()
Local nOperation 	:= oModel:GetOperation()
Local oView 		:= FWViewActive() // obtiene el View activo

//inicializa Variables
CTBA091CN()

If nOperation == MODEL_OPERATION_INSERT  .OR.  nOperation == MODEL_OPERATION_UPDATE
	
	lRet := CWJValCampos()
	
EndIf

If nOperation  == MODEL_OPERATION_DELETE
	
	// verifica si el Mnem�nico existe en una formula o Funci�n
	lFormula := ValNmoInFor()
	lFuncion := ValNmoInFun()
	
	// El Mnem�nico es de Sistema
	If cTipo == "S"
		Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0035), 1, 0 ) //"Aviso" //"Este registro es de sistema y no se puede eliminar"
		lRet := .F.

	//est� siendo utilizado por una formula o Funci�n y no es de sistema
	ElseIf lFormula .OR. lFuncion .And. cTipo == "U"
		Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0036), 1, 0 )//"Aviso" //"Mnem�nico est� en uso de alguna f�rmula o funci�n, no permitir� eliminarlo"
		lRet := .F.
		
	Else

		If ( IsBlind() )
			lRet := .t.
		Else
			lRet := msgNoyes(OemToAnsi(STR0037))  //"�Est� seguro de Eliminar el registro?"
		EndIf

		If !lRet
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0046), 1, 0 )//"Aviso" // "No se realizaron cambios"
		EndIf 
		
	EndIf
	
EndIf

restArea(aArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ValNmoInFor� Autor � Alfredo Medrano      � Data �20/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica que el nem�nico no est� siendo utilizado por una   ���
���          �Formula                                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ValNmoInFor()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA91                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ValNmoInFor()
Local  	lRet	:= .F.
Local	aArea	:= getArea()        
Local	cFilCWL	:= XFILIAL("CWL")
Local	cCodMne	:= CWJ->CWJ_CODMNE   

	DbSelectArea("CWL") 
	CWL -> (DBSETORDER(2))
	
	If CWL -> (dbSeek(cFilCWL+cCodMne))
		lRet := .T.
		Return lRet
	EndIF	
	
	CWL -> (DBSETORDER(3))
	If CWL -> (dbSeek(cFilCWL+cCodMne))
		lRet := .T.
		Return lRet
	EndIF	
   
	restArea(aArea)
	 
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CWJValCampos� Autor � Alfredo Medrano     � Data �19/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacion de Tablas y Campos                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CWJValCampos()                                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA91                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CWJValCampos()
Local lRet		:=.T.
Local cTipDat 	:= getMemvar("CWJ_TIPDAT")
Local cTables 	:= getMemvar("CWJ_TABLA")
Local cFields 	:= getMemvar("CWJ_CAMPO")
Local cDatVin	:= getMemvar("CWJ_DATVIN")
Local cFunRPO	:= getMemvar("CWJ_FUNRPO")
Local cValor	:= getMemvar("CWJ_VALOR")

	If cTipDat == "1"
		If Empty(cTables)
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0038), 1, 0 ) //"Seleccione la Tabla"
			lRet := .F.
			Return lRet
		EndIf
		
		If Empty(cFields)
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0039), 1, 0 ) //"Seleccione el Campo"
			lRet := .F.
			Return lRet
		EndIf	
	ElseIF  cTipDat == "2"
	
		If Empty(cTables)
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0038), 1, 0 ) //"Seleccione la Tabla"
			lRet := .F.
			Return lRet
		EndIf
		
	ElseIF  cTipDat $ "3|4"
		If Empty(cDatVin)
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0040), 1, 0 ) //"Ingrese el Dato Vinculado"
			lRet := .F.
			Return lRet
		EndIf
		
	ElseIF  cTipDat == "5"
		If Empty(cFunRPO)
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0041), 1, 0 ) // "Ingrese la Funci�n RPO"
			lRet := .F.
			Return lRet
		EndIf
		
	ElseIF  cTipDat == "6"
		If Empty(cValor)
			Help( ,, OemToAnsi(STR0022),, OemToAnsi(STR0042), 1, 0 ) // "Ingrese el Valor"
			lRet := .F.
			Return lRet
		EndIf

	EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ValNmoInFun � Autor � Alfredo Medrano     � Data �19/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica si existe el nem�nico en alguna funci�n            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ValNmoInFun()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA91                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ValNmoInFun()
Local lRet		:= .F.
Local aDatos	:= {}   
Local aArea		:= getArea()        
Local cTmpPer	:= CriaTrab(Nil,.F.)
Local cQuery	:= "" 
Local nTotalR 	:= 0
Local cFilCWN	:= FWCODFIL("CWN")
Local cCodMne	:= CWJ->CWJ_CODMNE   

	cQuery := " SELECT CWN_CODFUN " 
	CQuery += " FROM " + RetSqlName("CWN") 
 	cQuery += " WHERE CWN_PAR1 ='"+ cCodMne +"'" 	
 	cQuery += " OR CWN_PAR2 ='"+ cCodMne +"'"
 	cQuery += " OR CWN_PAR3 ='"+ cCodMne +"'" 	
 	cQuery += " OR CWN_PAR4 ='"+ cCodMne +"'" 	
 	cQuery += " OR CWN_PAR5 ='"+ cCodMne +"'" 	
  	cQuery += " AND D_E_L_E_T_ = ' ' "
  	cQuery += " AND CWN_FILIAL = '" +cFilCWN + "'"
  	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
   	Count to nTotalR  
   
   If nTotalR > 0
   		lRet := .T.
   EndIF
	
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �x2CboxMnemo � Autor � Alfredo Medrano     � Data �11/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tratameinto de COMBOBOX para el campo CWJ_TABLA             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � x2CboxMnemo()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: CWJ_TODAS1                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function x2CboxMnemo()
Local cTipo 	:= getMemvar("CWJ_TODAS1") // TODAS? {"1=SI",2="NO"}
Local oView 	:= FWViewActive() // obtiene el View activo

If oView!=Nil // Verifica que el objeto no este vac�o
	//Llena combobox
	oView:SetFieldProperty("CWJMASTER","CWJ_TABLA","COMBOVALUES",{CWJAliasBox(cTipo)}) 
EndIf

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �x3CboxMnemo � Autor � Alfredo Medrano     � Data �18/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tratameinto de COMBOBOX para el campo CWJ_CAMPO             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � x3CboxMnemo()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: CWJ_TABLA, CWJ_TODAS2                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function x3CboxMnemo()
Local cTipo		:= getMemvar("CWJ_TODAS2") // TODAS? {"1=SI",2="NO"}
Local cTabla 	:= getMemvar("CWJ_TABLA")  // obtiene el alias de tabla
Local cTipDat 	:= getMemvar("CWJ_TIPDAT")
Local oView 	:= FWViewActive() // obtiene el View activo

If oView!=Nil .And. cTipDat =="1" //Verifica que el objeto no este vac�o
 	//Llena Combobox
	oView:SetFieldProperty("CWJMASTER","CWJ_CAMPO","COMBOVALUES",{CWJListField(cTipo,cTabla )}) 
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �HelpFieldM  � Autor � Alfredo Medrano     � Data �18/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Presenta el Help del campo seleccionado                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HelpFieldM()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: CWJ_CAMPO                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HelpFieldM()
Local cCampo	:= getMemvar("CWJ_CAMPO") // Nombre del campo
Local oModel	:= FWModelActive() // obtiene el Modelo activo
Local aArea		:= getArea() 
Local cTipo		:=""
Local nTamanio	:= 0
Local cUsado	:=""
Local cValid	:=""
Local cTabla	:=""
Local nDecimal	:=0
Local cCadena	:=""
	
If !Empty(cCampo)

// Arma la Cadena que contendr� la ayuda del campo con sus caracter�sticas
// Campo, Tabla, Help de campo, Validaci�n, Tipo de Dato, Tama�o y Decimal
	DbSelectArea("SX3") 
	SX3 -> (DBSETORDER(2))
	
	If SX3 -> (dbSeek(cCampo))
		cTipo 	:= SX3 -> X3_TIPO
		nTamanio:= SX3 -> X3_TAMANHO
		cTabla	:= SX3 -> X3_ARQUIVO
		nDecimal:= SX3 -> X3_DECIMAL
		
		If SX3->( X3Uso( X3_USADO ) )
			cUsado := OemToAnsi(STR0054)
		Else
			cUsado := OemToAnsi(STR0055)
		EndIf
			
		cValid := AllTrim( GetSx3Cache(cCampo, "X3_VALID") )
		
	EndIF
		
	cCadena := cCampo + OemToAnsi(STR0047) + " " + cTabla + Chr(13)+ Chr(10)
	cCadena += Ap5GetHelp(cCampo) + Chr(13)+ Chr(10)
	cCAdena += OemToAnsi(STR0049) + Chr(13)+ Chr(10)
	cCadena += cValid + Chr(13)+ Chr(10)
	cCadena += OemToAnsi(STR0050) +" "+ cTipo +" "
	cCadena += OemToAnsi(STR0051) +" "+ Alltrim(str(nTamanio)) +" "
	cCadena += OemToAnsi(STR0052) +" "+ cUsado +" "
	cCadena += OemToAnsi(STR0053) +" "+ Alltrim(str(nDecimal)) +" "

 	oModel:setvalue("CWJMASTER","CWJ_HELP",cCadena) // Retorna el Help del campo
 	ELSE
 	oModel:setvalue("CWJMASTER","CWJ_HELP","")	
EndIf

RestArea(aArea)
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CWJIniBoxF  � Autor � Alfredo Medrano     � Data �03/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �inicializa el Combobox de "Todas" en "NO" de los campos     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CWJIniBoxF()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lCwjIni                                                 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: CWJ_TABLA                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CWJIniBoxF()
Local lCwjIni	:= .T.
Local oModel	:= FWModelActive() // obtiene el Modelo activo
Local cTipDat 	:= getMemvar("CWJ_TIPDAT")
Local cTodas2	:= getMemvar("CWJ_TODAS2")

If !Altera .And. cTipDat == "1" // si es modo Edicion
	If cTodas2 == "1" 
		oModel:SetValue("CWJMASTER","CWJ_TODAS2","2")
	EndIF
EndIF
	
return lCwjIni


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTB91CESP   � Autor � Alfredo Medrano     � Data �05/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Define las consultas a ejecutar en base al tipo de dato    ���
���          � especificado                                               ���
���          � cTipDat == 3 Formula  - ejecuta CTB91FOR()                 ���
���          � cTipDat == 4 Funci�n  - ejecuta CTB91FUN()                 ���
���          � cTipDat == 6 valor 	 - ejecuta CTB91VAL()                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB91CESP()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                   	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB911 - consulta espec�fica                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTB91CESP()

Local cRedVar := getMemvar("CWJ_TIPDAT")

If cRedVar != NIL

	DO CASE
		CASE cRedVar == "3" 
			cSetFun := CTB91FOR()
		CASE cRedVar == "4" 
			cSetFun := CTB91FUN()
		CASE cRedVar == "6"
			cSetFun := CTB91VAL() 
	ENDCASE

EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTB91CRET   � Autor � Alfredo Medrano     � Data �05/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Define el retorno de las consultas CTB91FOR, CTB91FUN,     ���
���		     � y CTB91VAL                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB91CRET()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cCodFun                                                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB911 - consulta espec�fica                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTB91CRET()

Local cCodFun // Asigna C�digo de Funci�n

	cCodFun := cSetFun

Return(cCodFun)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTB91FUN    � Autor � Alfredo Medrano     � Data �05/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara el cuadro de dialogo para la consulta de Funciones ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB91FUN()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cCWNCFun                                                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB91CESP                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTB91FUN()
 
Local cCWNCFun  := ""
Local oDlg 
Local oBtnOk 
Local oBtnCa
Local oCmbTip
Local oGetHlp
Local oCmbFun 
Local aArea		:= getArea()
Local cCmbTip	:= ""	 
Local cDato		:= ""
Local cCmbFun	:= ""
Local aFunc		:= {}
Local iCWN		:= RETORDEM("CWN","CWN_FILIAL+CWN_CODFUN") 
Local cHelp 	:= ""

//Obtiene la lista de Items de la consulta para pasarla a un Array
If(FindFunction("CTB92LBOX"))
	cDato	:= CTB92LBOX()
	aFunc := obtArrayL(cDato, ";") // llena los items del Combo
EndIf

	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 380,340 PIXEL TITLE OemToAnsi(STR0001) + '- ' +OemToAnsi(STR0009) // Consulta Est�ndar - Funciones
	
	oSay	:= tSay():New(10,10,{||OemToAnsi(STR0010)},oDlg,,,,,,.T.) 			// Tipo			
 	oCmbTip:= tComboBox():New(18,10,{|u|if(PCount()>0,cCmbTip:=u,cCmbTip)},aFunc ,130,20,oDlg,,{||obtFuncion(cCmbTip, @oCmbFun:aitems)},,,,.T.,,,,,,,,,'cCmbTip')  // ComboBox Tipos
 							
	oSay	:= tSay():New(35,10,{||OemToAnsi(STR0011)},oDlg,,,,,,.T.) // Funci�n
	oCmbFun:= tComboBox():New(43,10,{|u|if(PCount()>0,cCmbFun:=u,cCmbFun)},/*ITEMS*/,130,20,oDlg,,/*{||}*/,,,,.T.,,,,,,,,,'cCmbFun')// ComboBox Funciones
 							
  	oSay	:= tSay():New(60,10,{||OemToAnsi(STR0006)},oDlg,,,,,,.T.) // Ayuda 			
  	@ 68,10  GET oGetHlp  VAR	IIF(!Empty(cCmbFun), POSICIONE("CWN", iCWN,XFILIAL("CWN") + cCmbFun,"CWN_HELP"),"")	MEMO SIZE 90,100 WHEN .F. OF oDlg PIXEL		
 	oGetHlp:bRClicked := {||AllwaysTrue()}
 
	oBtnOk	:=tButton():New(175,90,OemToAnsi(STR0007),oDlg,{|| ( cCWNCFun := SubStr(cCmbFun,0,15), oDlg:End()  )} ,30,12,,,,.T.) //  Ok
	oBtnCa	:=tButton():New(175,125,OemToAnsi(STR0008),oDlg,{||( cCWNCFun := "",oDlg:End() )},30,12,,,,.T.)  // Anular
	
 ACTIVATE MSDIALOG oDlg CENTERED

 RestArea(aArea)
 
Return cCWNCFun

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTB91FOR    � Autor � Alfredo Medrano     � Data �05/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara el cuadro de dialogo para la consulta de Formula   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB91FOR()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cCWNCFor                                                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB91CESP                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTB91FOR()

Local oDlg 
Local oBtnOk 
Local oBtnCa
Local oCmbFor
Local oGetHlp
Local cCWNCFor	:= "" 
Local cCmbFor	:= ""
Local cGetHlp	:= ""
Local cTabla 	:= "CZ"
Local cGrupo	:= space(TamSX3("CWK_GRUPO")[1])
Local iSX5     	:= RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE") 
Local iCWK     	:= RETORDEM("CWK","CWK_FILIAL+CWK_CODFOR") 
Local aArea		:= getArea() 
Local aFormula	:= {}


	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 380,410 PIXEL TITLE OemToAnsi(STR0001) + '- ' +OemToAnsi(STR0002) // Consulta Est�ndar - Formulas
	
	oSay	:= tSay():New(10,10,{||OemToAnsi(STR0003)},oDlg,,,,,,.T.) 			// Grupo
	@ 18,10   MSGET	cGrupo	  SIZE 060,10 OF oDlg  F3 cTabla VALID obtFormula(cGrupo,@oCmbFor:aitems) PIXEL HASBUTTON	
		
	oSay	:= tSay():New(10,80,{||OemToAnsi(STR0004)},oDlg,,,,,,.T.) 			// Descripci�n
	@ 18,80   MSGET 	IIF(cGrupo!="",POSICIONE("SX5",iSX5,XFILIAL("SX5")+cTabla+cGrupo,"X5_DESCRI"),"")  SIZE 120,10 WHEN .F. OF oDlg PIXEL
	
	oSay	:= tSay():New(35,10,{||OemToAnsi(STR0005)},oDlg,,,,,,.T.)
	oCmbFor := tComboBox():New(43,10,{|u|if(PCount()>0,cCmbFor:=u,cCmbFor)},/*ITEMS*/,190,20,oDlg,,/*{||}*/,,,,.T.,,,,,,,,,'cCmbFor')  // ComboBox Formula
 				
  	oSay	:= tSay():New(60,10,{||OemToAnsi(STR0006)},oDlg,,,,,,.T.) // Ayuda 
    @ 68,10   GET oGetHlp VAR IIF(!Empty(cCmbFor),POSICIONE("CWK", iCWK,XFILIAL("CWK") + SubStr(cCmbFor,0,15),"CWK_HELP");
    + Chr(13)+Chr(10) +  Chr(13)+Chr(10) + POSICIONE("CWK", iCWK,XFILIAL("CWK") + SubStr(cCmbFor,0,15),"CWK_ADVPL"),"") MEMO  SIZE 100,100 WHEN .F. OF oDlg PIXEL
    oGetHlp:bRClicked := {||AllwaysTrue()}
  
	oBtnOk	:= tButton():New(170,135,OemToAnsi(STR0007),oDlg,{||( cCWNCFor := SubStr(cCmbFor,0,15), oDlg:End()  )} ,30,12,,,,.T.) //  Ok
	oBtnCa	:= tButton():New(170,170,OemToAnsi(STR0008),oDlg,{||( cCWNCFor := "",oDlg:End() )},30,12,,,,.T.)  // Anular
	
 ACTIVATE MSDIALOG oDlg CENTERED
  
RestArea(aArea)

Return cCWNCFor

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTB91VAL    � Autor � Alfredo Medrano     � Data �05/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara el cuadro de dialogo para la consulta de Valor     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB91VAL()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cCWNCVal                                                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB91CESP                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum						                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTB91VAL()
Local oDlg 
Local oBtnOk 
Local oBtnCa
Local oCmbTip
Local cCmbTip 
Local oCmbCta
Local cDato		:= ""
Local cCWNCVal	:= ""
Local aArea		:= getArea() 
Local cCmbCta 	:= space(TamSX3("CT1_CONTA")[1])
Local cCmbCCos 	:= space(TamSX3("CTT_CUSTO")[1])
Local cCmbITemC	:= space(TamSX3("CTD_ITEM")[1])
Local cCmbClVal	:= space(TamSX3("CTH_CLVL")[1])
Local iCT1		:= RETORDEM("CT1","CT1_FILIAL+CT1_CONTA")
Local iCTT		:= RETORDEM("CTT","CTT_FILIAL+CTT_CUSTO")
Local iCTD		:= RETORDEM("CTD","CTD_FILIAL+CTD_ITEM")
Local iCTH		:= RETORDEM("CTH","CTH_FILIAL+CTH_CLVL")    
Local aItems		:= {} 

cDato	:= OemToAnsi(STR0013)
aItems := obtArrayL(cDato, ",") // llena los items del Combo
	//Crea el cuadro de dialogo 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 330,450 PIXEL TITLE OemToAnsi(STR0001) + '- ' +OemToAnsi(STR0043) // Consulta Est�ndar - Valor
	
	oSay	:= tSay():New(10,10,{||OemToAnsi(STR0010)},oDlg,,,,,,.T.) 			// "Tipo"
	oCmbTip	:= tComboBox():New(18,10,{|u|if(PCount()>0,cCmbTip:=u,cCmbTip)},aItems,075,10,oDlg,,/*{||}*/,,,,.T.,,,,,,,,,'cCmbTip')  // ComboBox Tipo
		
	oSay	:= tSay():New(35,10,{||OemToAnsi(STR0014)},oDlg,,,,,,.T.)		// "Cuenta"
	@ 43,10   MSGET 	cCmbCta   SIZE 075,10 OF oDlg  F3 "CT1" WHEN (cCmbTip== "1")  	VALID IIF(cCmbTip=="1",cCWNCVal := cCmbCta,"") PIXEL HASBUTTON 
	
	oSay	:= tSay():New(35,095,{||OemToAnsi(STR0004)},oDlg,,,,,,.T.) // "Descripci�n"			
	@ 43,095  MSGET POSICIONE("CT1", iCT1,XFILIAL("CT1") + cCmbCta,"CT1_DESC01")   	SIZE 120,10 WHEN .F. OF oDlg PIXEL
 				
  	oSay	:= tSay():New(60,10,{||OemToAnsi(STR0015)},oDlg,,,,,,.T.)		// "C. de Costo"
	@ 68,10   MSGET	cCmbCCos  SIZE 075,10 OF oDlg  F3 "CTT" WHEN (cCmbTip== "2")	 	VALID IIF(cCmbTip=="2",cCWNCVal := cCmbCCos,"") PIXEL HASBUTTON
		
	oSay	:= tSay():New(60,095,{||OemToAnsi(STR0004)},oDlg,,,,,,.T.) // Descripci�n			
	@ 68,095  MSGET POSICIONE("CTT", iCTT,XFILIAL("CTT") + cCmbCCos,"CTT_DESC01")	SIZE 120,10 WHEN .F. OF oDlg PIXEL
 	
 	oSay	:= tSay():New(85,10,{||OemToAnsi(STR0016)},oDlg,,,,,,.T.)		// "Item Contable"
	@ 93,10   MSGET	cCmbITemC  SIZE 075,10 OF oDlg  F3 "CTD" WHEN (cCmbTip== "3")		VALID IIF(cCmbTip=="3",cCWNCVal := cCmbITemC,"") PIXEL HASBUTTON
		
	oSay	:= tSay():New(85,095,{||OemToAnsi(STR0004)},oDlg,,,,,,.T.) // Descripci�n			
	@ 93,095  MSGET POSICIONE("CTD", iCTD,XFILIAL("CTD") + cCmbITemC,"CTD_DESC01")	SIZE 120,10 WHEN .F. OF oDlg PIXEL
 	
 	oSay	:= tSay():New(110,10,{||OemToAnsi(STR0017)},oDlg,,,,,,.T.)		// "Item Contable"
	@ 118,10   MSGET	cCmbClVal  SIZE 075,10 OF oDlg  F3 "CTH" WHEN (cCmbTip== "4")	VALID IIF(cCmbTip=="4",cCWNCVal := cCmbClVal,"") PIXEL HASBUTTON
		
	oSay	:= tSay():New(110,095,{||OemToAnsi(STR0004)},oDlg,,,,,,.T.) // Descripci�n			
	@ 118,095  MSGET POSICIONE("CTH", iCTD,XFILIAL("CTH") + cCmbClVal,"CTH_DESC01") SIZE 120,10 WHEN .F. OF oDlg PIXEL
 	
 	
	oBtnOk	:= tButton():New(145,150,OemToAnsi(STR0007),oDlg,{|| ( cCWNCVal , oDlg:End()  )},30,12,,,,.T.) //  Ok
	oBtnCa	:= tButton():New(145,185,OemToAnsi(STR0008),oDlg,{|| ( cCWNCVal := "", oDlg:End() ) },30,12,,,,.T.)  // Anular
	
 ACTIVATE MSDIALOG oDlg CENTERED
 
 RestArea(aArea)
Return cCWNCVal

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �obtFormula  � Autor � Alfredo Medrano     � Data �06/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene las Formulas de la tabla CWK de acuerdo al Grupo(CZ)���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � obtFormula(ExpC1,@ExpA1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / (byRef -> aFormula)                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB91FOR                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : c�digo del grupo (CZ)                             ���
���          � ExpA1  : Array                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function obtFormula(cGrupo,aFormula) 
Local	 aDatos	  	:= {}   
Local 	 aArea		:= getArea()        
Local	 cTmpPer	:= CriaTrab(Nil,.F.)
Local   cQuery		:= "" 
Local   cFilCWK		:= FWCODFIL("CWK")   
Default cGrupo		:= ""
Default aFormula	:= {}
	
	cQuery := " SELECT CWK_CODFOR, CWK_DESC " 
	CQuery += " FROM " + RetSqlName("CWK") 
 	cQuery += " WHERE CWK_GRUPO='"+ cGrupo +"' " 	//Grupo
 	cQuery += " AND CWK_FILIAL =  '" + cFilCWK + "'"
  	cQuery += " AND D_E_L_E_T_ = ' ' "
  	cQuery := ChangeQuery(cQuery)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
    
    AADD(aDatos,"")
	(cTmpPer)->(dbgotop())//primer registro de tabla
	While  (cTmpPer)->(!EOF())
		AADD(aDatos,(cTmpPer)-> CWK_CODFOR + " " + (cTmpPer)->CWK_DESC )		
		(cTmpPer)-> (dbskip())	 		
	EndDo
	
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
	aFormula := aDatos
	 		
Return  .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �obtFuncion  � Autor � Alfredo Medrano     � Data �09/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene las Funciones de la tabla CWN de acuerdo al tipo    ��� 
���          � 1=Conversion de Monedas(AxMoeda) 2=Apuntador (Posicione)   ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � obtFuncion(ExpC1,@ExpA1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. /(byRef -> aFormula)                                	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTB91FUN                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Tipo (Cuentas contable, Centros de costos,        ���
���          � 			�tem contable y clase valor.)                     ���				
���          � ExpA1  : Array                                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function obtFuncion(cTipo,aFormula) 
Local	 aDatos	  	:= {}   
Local 	 aArea		:= getArea()        
Local	 cTmpPer	:= CriaTrab(Nil,.F.)
Local   cQuery		:= "" 
Local   cFilCWN		:= FWCODFIL("CWN")   
Default cTipo 		:= ""
Default aFormula	:= {}
	
	cQuery := " SELECT CWN_CODFUN, CWN_DESCRI " 
	CQuery += " FROM " + RetSqlName("CWN") 
 	cQuery += " WHERE CWN_TIPO='"+ cTipo +"' " 	//Tipo
 	cQuery += " AND CWN_FILIAL =  '" + cFilCWN + "'"
  	cQuery += " AND D_E_L_E_T_ = ' ' "
  	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.) 
 
    AADD(aDatos,"")
	(cTmpPer)->(dbgotop())//primer registro de tabla
	While  (cTmpPer)->(!EOF())
		AADD(aDatos,(cTmpPer)-> CWN_CODFUN + " " + (cTmpPer)->CWN_DESCRI )		
		(cTmpPer)-> (dbskip())	 		
	EndDo
	
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)
	 
	aFormula := aDatos
	
Return  .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �obtArrayL   � Autor � Alfredo Medrano     � Data �10/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene un array apartir de una cadena con sepradores       ��� 
���          �Ejemplo: 1=A,2=B                                            ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � obtArrayL(ExpC1,ExpC2)                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aArrayF                                               	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Cadena alfanumerica                               ���		
���          � ExpC2  : Separador                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function obtArrayL(cCadena,cIdeSep)

Local 	 aArrayF	:= {}
Local 	 nLen		:= 0
Local 	 nCaract	:= 0
Local	 cConten	:= ""
Default cCadena  	:= ""
Default cIdeSep		:= ""

If cCadena != ""  .OR. 	cCadena!=Nil
AADD(aArrayF,"")	
	nLen 	:= Len(Alltrim(cCadena))
	If At(cIdeSep,cCadena)>0
		For nCaract:=1 To nLen       
    		If Substr(cCadena,nCaract,1)==cIdeSep
        		AADD(aArrayF,cConten)
            	cConten :=""
       		Else
        		cConten += Substr(cCadena,nCaract,1)
        		IF nCaract == nLen
            		AADD(aArrayF,cConten)
           		EndIf
      		Endif
   		Next                
	EndIf
	
EndIf 
	
Return aArrayF


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CwjMnemoPVar� Autor � Alfredo Medrano     � Data �11/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tratamento do X3_PICTVAR para campo CWJ_CODMNE              ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CwjMnemoPVar(ExpC1)                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cPicture                                               	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_PICVAR                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Cadena de caracteres                              ���		
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CwjMnemoPVar( cType )
Local nTamMnemo	:= GetSx3Cache( "CWJ_CODMNE", "X3_TAMANHO")
Local cPicture	:= "@! %C"
local Inclui	:= .T.                                    

cPicture := ( "@! " + Replicate( "X", nTamMnemo ) +"%C" )

	IF ( Inclui )
	
		/*/
		��������������������������������������������������������������Ŀ
		� Altera a Mascara do Campo CWJ_CODMNE carregando os 2   primei�
		� ros Bytes com M_											   �
		����������������������������������������������������������������/*/
		cPicture := ( "@! M_" + Replicate( "X", nTamMnemo - 2 ) +"%C" )
			
	EndIF

Return( cPicture )                


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CTB91VLDVIN � Autor � Alfredo Medrano     � Data �13/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica si existe la Funci�n (CWN) o la Formula (CWK)      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTB91VLDVIN()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                    	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � X3_VALID: CWJ_DATVIN                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum	                                                  ���		
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTB91VLDVIN()
Local 	lRet 	:= .T. 
Local 	aArea	:= getArea()  
Local 	cRedVar	:= getMemvar("CWJ_TIPDAT")
Local 	cCodF 	:= getMemvar("CWJ_DATVIN")

DO CASE
	CASE cRedVar == "3" //Verifica Formulas
	
		DbSelectArea("CWK") 
 		CWK ->(DBSETORDER(1)) // CWK_FILIAL+CWK_CODFOR
   		If  !CWK ->(	Dbseek(XFILIAL("CWK")+cCodF)) 
 			lRet := .F.
 		EndIF
 		 
	CASE cRedVar == "4" //Verifica Funciones
	
		DbSelectArea("CWN") 
 		CWN ->(DBSETORDER(1)) // CWN_FILIAL+CWN_CODFUN
   		If !CWN ->(	Dbseek(XFILIAL("CWN")+cCodF)) 
 			lRet := .F.
 		EndIF 	
 				 
ENDCASE

restArea(aArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CWJAliasBox � Autor � Alfredo Medrano     � Data �10/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Presentara las tablas que est�n disponibles para el uso de ���
���          �mnem�nicos (CWH) o los registros de la tabla SX2            ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CWJAliasBox(ExpC1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aDatos                                                  	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  :  Todas las Tablas '1'-Si (SX2) '2'-No (CWH)       ���		
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CWJAliasBox(cTipo)  
Local aArea		:= GetArea()
Local aDatos	:= {}
Local oModel	:= FWModelActive()	
Default cTipo 	:= ""

	If cTipo == "1" // Todas las Tablas 1-Si (SX2) 2-No (CWH)
	
		lRet := msgNoyes(OemToAnsi(STR0018))  //"Visualizara todas las tablas del sistema �continuar?"
		if lRet == .T.
			// Visualiza un mensaje de Espera para el llenado de Tablas(SX2)
			MsgRun(OemToAnsi(STR0019), OemToAnsi(STR0021),{|| CursorWait(),obtTablas(@aDatos,cTipo ) ,CursorArrow()})
		Else
			oModel:setValue("CWJMASTER","CWJ_TODAS1","2")
		EndIf
		
	Elseif cTipo == "2"
		// Visualiza un mensaje de Espera para el llenado de Tablas(CWH)
			MsgRun(OemToAnsi(STR0019), OemToAnsi(STR0021),{|| CursorWait(),obtTablas(@aDatos,cTipo ) ,CursorArrow()})
		
	EndIf

RestArea( aArea  )

Return aDatos

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �obtTablas   � Autor � Alfredo Medrano     � Data �19/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene las tablas para el uso de mnem�nicos (CWH) o los    ���
���          �registros de la tabla SX2                                   ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � obtTablas(@ExpA1,ExpC1)                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � byRef -> @aDatos                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1  : Array                                             ���
���          � ExpC1  : Tipo '1'= Carga SX2 '2'= Carga CWH                ���		
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function obtTablas(aDatos, cTipo)
Local 	 aAreaS 	:= SX2->( GetArea() )
Local 	 aAreaC 	:= CWH->( GetArea() )
Local 	 cDescSx2	:= ""
Default aDatos		:= {}
Default cTipo		:= ""

AADD(aDatos,"")
if cTipo == "1"
// CAGRGA EL CONTENIDO DE LA TABLA (SX2)
		DbSelectArea("SX2") 
	 	SX2 ->(DBSETORDER(1))
	 	SX2 ->(dbgotop())
		cDescSx2 := ""	
		While  SX2 ->( !Eof())
			cDescSx2 := AllTrim( X2Nome() )
			AADD(aDatos, FWX2CHAVE() + "=" + cDescSx2 )
			SX2->(dbskip())	 		
		EndDo
		
ElseIF cTipo == "2"

// AGREGA EL CONTENIDO DE LA TABLA (CWH)
	DbSelectArea("CWH") 
 	CWH ->(DBSETORDER(1))
	While  CWH->(!Eof())
		AADD( aDatos, CWH->CWH_TABLA + "=" + CWH->CWH_DESCRI  )
		CWH->(dbskip())	 		
	EndDo

EndIf

RestArea( aAreaC )
RestArea( aAreaS )
Return 


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CWJListField� Autor � Alfredo Medrano     � Data �18/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Presentar� los campos que est�n disponibles para el uso de ���
���          � mnem�nicos (CWI) o los registros de la tabla SX3           ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CWJListField(@ExpC1,ExpC1)                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aDatos                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1  : Tipo '1'= Carga SX3 '2'= Carga CWI                ���
���          � ExpC2  : Nombre de la tabla                                ���		
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CWJListField(cTipo, cTabla)   
Local 	 aArea	:= GetArea()
Local 	 aDatos	:= {}
Local 	 cFil 	:= XFILIAL("CWI")
Default cTipo 	:= ""
Default cTabla 	:= ""	

AADD(aDatos,"")

If cTipo == "1" .And. cTabla!=Nil

	// Visualiza un mensaje de Espera para el llenado de los campos
	MsgRun(OemToAnsi(STR0019), OemToAnsi(STR0020),{|| CursorWait(),obtCampos(@aDatos,cTipo,cTabla ) ,CursorArrow()})

ElseIf cTipo == "2" .And. cTabla!=Nil

	// AGREGA EL CONTENIDO DE LA TABLA (CWI)
	DbSelectArea("CWI") 
	CWI ->(DBSETORDER(1))
	CWI ->( dbSeek(cFil+cTabla) )	
	While  CWI->(!Eof()) .And. ( CWI_FILIAL+CWI_TABLA == cFil+cTabla ) 
		AADD( aDatos, CWI->CWI_CAMPO +"="+ CWI->CWI_DESCRI )
		CWI->(dbskip())	 		
	EndDo

EndIf
	
RestArea(aArea)

Return aDatos

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �obtCampos   � Autor � Alfredo Medrano     � Data �19/12/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtiene los Campos de la tabla SX3                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � obtCampos(@ExpA1,ExpC1,ExpC2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � byRef -> @aDatos                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA091                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1  : Array                                             ���
���          � ExpC1  : Tipo 1=Tabla, 2=Campo                             ���
���          � ExpC2  : Nombre de la tabla                                ���				
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function obtCampos(aDatos, cTipo, cTabla )
Local aHeader
Local nCamp		:= 0
Default cTipo 	:= ""
Default cTabla 	:= ""	
Default aDatos	:= {}

//Llena un array con los campos y sus caracteristicas
	aHeader := GdMontaHeader(  	NIL				,;	//01 -> Por Referencia contera o numero de campos em Uso
				   				    NIL				,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
					    			NIL				,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
					 				cTabla			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
									NIL				,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
									.T.   			,;	//06 -> Opcional, Carregar Todos os Campos
									.T.				,;	//07 -> Nao Carrega os Campos Virtuais
									NIL				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
									NIL				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									.T.				,;	//10 -> Verifica se Deve Checar se o campo eh usado
									NIL				,;	//11 -> Verifica se Deve Checar o nivel do usuario
									NIL				,;	//12 -> Utiliza Numeracao na GhostCol
									.T.				 ;	//13 -> Carrega os Campos de Usuario
					   			)
// AGREGA EL CONTENIDO DE LA TABLA (SX3)
	If Len(aHeader) > 0
		For nCamp := 1 To Len(aHeader) 
			AADD(aDatos,aHeader[nCamp,2] + "=" +aHeader[nCamp,1] )
		Next
	EndIf

Return