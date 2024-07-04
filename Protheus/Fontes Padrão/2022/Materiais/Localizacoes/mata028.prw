#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA028.CH"
#INCLUDE "FWBROWSE.CH"

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa  �MATA028   � Autor  �Miguel Angel Rojas G.     � Data � 14.02.14 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � CONFIGURACIONES DE ADENDA                                      ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA028()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � GENERAL                                                        ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS     �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�24/02/14�          �Ordenar constantes STR00XX                ���
�����������������������������������������������������������������������������Ĵ��
���Miguel Rojas�25/02/14�          �Valida linea duplicada en CPO             ���
���            �        �          �y registro unico en CPR_CONFIG            ���
�����������������������������������������������������������������������������Ĵ��
���M.Camargo	 �08/04/14�          �Se agrega funcionalidad para cargar campos���
���            �        �          �obligatorios de cpp/cpq al incluir.       ���
�����������������������������������������������������������������������������Ĵ��
���Alf. Medrano�06/06/16�  TVGZL6  �se agrega SetPrimaryKey en ModelDef       ���
�����������������������������������������������������������������������������Ĵ��
���Jose Glez   �28/11/17�DMINA-1217�Se agrega validacion para detectar si     ���
���            �        �	       �la rutina se ejecuta de manera automatica ���
���            �        �          �y no mostrar cuadros de usuario.          ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/

Function MATA028()
DbSelectArea("CPP")
DbSelectArea("CPQ")
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CPR")
oBrowse:SetDescription(STR0001)  // Configuraciones de adendas
oBrowse:SetMenuDef("MATA028")
oBrowse:DisableDetails()
oBrowse:Activate()
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef   � Autor � Miguel Angel Rojas G. � Data �14.02.2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Crea un Menu                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Menu Estandar                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA028                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()
Return FWMVCMenu( "MATA028" ) // Genera un Menu Estandar en MVC sin Necesidad de aRotina.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �ModelDef  � Autor �Miguel Angel. Rojas G. � Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Crea la estructura del modelo de datos llama                ���
���          �funciones para validar antes de guardar y al modificar      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Modelo de datos                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA028                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()
Local oStruCPR := FWFormStruct( 1, "CPR" )
Local oStruCPO := FWFormStruct( 1, "CPO" )
Local oModel
Local bBloco


//--- Objeto Constructor del Modelo de Datos
oModel := MPFormModel():New("MATA028",/* { | oMdl | MT28PRE( oMdl ) } */,{ | oMdl | MT28POS( oMdl ) }, /*{ | oMdl | MATA028COMM( oMdl ) }*/,/*bCancel*/ )
bBloco := {|oModel| M458FILLGRID(oModel)}
//--- Agrega un Modelo para la captura de datos
oModel:AddFields( "CPRMASTER", /*es el encabezado*/, oStruCPR )

//--- Agrega Modelo de datos para el detalle
oModel:AddGrid( "CPODETAIL", "CPRMASTER", oStruCPO ,,,,, )

//--- Establece la relaci?n entre las tablas
oModel:SetRelation( "CPODETAIL", { { "CPO_FILIAL", "xFilial( 'CPO' )" }, { "CPO_CONFIG" , "CPR_CONFIG"  } } , CPO->( IndexKey( 1 ) )  )

//--- No permite la duplicidad de registros con SetUniqueLine  
oModel:GetModel( "CPODETAIL" ):SetUniqueLine( { "CPO_CAMPO" } )

//--- Descripci?n del Modelo de Datos
oModel:SetDescription( STR0001 )       // Configuraciones de adendas

//----llave primaria
oModel:SetPrimaryKey( {'CPO_FILIAL','CPR_CONFIG'} ) 
//--- Valida que un Grid pueda quedar Vacio
oModel:GetModel( "CPODETAIL" ):SetOptional( .T. )

//--- Descripci?n de los componente del Modelo de Datos
oModel:GetModel( "CPRMASTER" ):SetDescription( STR0001 )  		// Configuraciones de adendas
oModel:GetModel( "CPODETAIL" ):SetDescription( STR0001 )		// Configuraciones de adendas

oModel:SetActivate(bBloco)

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �ViewDef   � Autor �Miguel Angel. Rojas G. � Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Genera la vista de los datos de acuerdo al  modelo         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EprO1: Objeto Vista                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA094                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()
Local oStruCPR := FWFormStruct( 2, "CPR" )
Local oStruCPO := FWFormStruct( 2, "CPO" )
Local oModel   := FWLoadModel( "MATA028" )
Local oView

//--- Quita los campos de la estrutura para evitar duplicidad en pantalla
oStruCPO:RemoveField( "CPO_CONFIG" )


oView := FWFormView():New()
oView:SetModel( oModel )    // el oView toma como base el objeto oModel para su construcci?n
oView:AddField( "VIEW_CPR", oStruCPR, "CPRMASTER" )
//--- Agrega los Grids para consulta 
oView:AddGrid(  "VIEW_CPO", oStruCPO, "CPODETAIL" )
//--- Hace un "box" horizontal para recibir elementos de la Vista
oView:CreateHorizontalBox( "SUPERIOR", 15 )
oView:CreateHorizontalBox( "INFERIOR", 85 )


//--- Relaciona EL ID del View con el "box" para mostrar
oView:SetOwnerView( "VIEW_CPR", "SUPERIOR" )
oView:SetOwnerView( "VIEW_CPO", "INFERIOR" )

//oView:SetFieldAction( 'CPR_CONFIG'	, { |oView| M458FILLGRID(oView) 		} )
Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �MT28SX3   � Autor �Miguel Angel. Rojas G. � Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Genera la consulta SX3FIL                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT28SX3()                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SXB - SX3FIL                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MT28SX3()
Local lRet      := .F. 
Local cFiltro   := " SX3->X3_CONTEXT!='V' .AND. ( SX3->X3_ARQUIVO =='CPP' .OR. SX3->X3_ARQUIVO =='CPQ') " 
Local oDlg
Local oBrowse
Local oMainPanel
Local oPanelBtn
Local oBtnOK
Local oBtnCan
Local oColumn1
Local oColumn2
Local oColumn3
Local oColumn4

Define MsDialog oDlg From 0, 0 To 390, 515 Title STR0002 Pixel Of oMainWnd		//Campos de las Tablas CPP/CPQ

@00, 00 MsPanel oMainPanel Size 250, 80
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00, 00 MsPanel oPanelBtn Size 250, 15
oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

Define FwBrowse oBrowse DATA TABLE ALIAS 'SX3'  NO CONFIG  NO REPORT;
DOUBLECLICK { || lRet := .T.,  oDlg:End() } NO LOCATE Of oMainPanel
ADD COLUMN oColumn1  DATA { || SX3->X3_CAMPO   }  Title STR0003 Size Len( SX3->X3_CAMPO   ) Of oBrowse // "Campo"
ADD COLUMN oColumn2  DATA { || X3Titulo()      }  Title STR0004 Size Len( X3Titulo()      ) Of oBrowse			//"Titulo"
ADD COLUMN oColumn3  DATA { || X3DescriC()     }  Title STR0005 Size Len( X3DescriC()     ) Of oBrowse		//"Descripci�n"
oBrowse:SetFilterDefault( cFiltro )
oBrowse:Activate()

Define SButton oBtnOK  From 02, 02 Type 1 Enable Of oPanelBtn ONSTOP STR0006 ;				//Aceptar
Action ( lRet := .T., oDlg:End() )

Define SButton oBtnCan From 02, 32 Type 2 Enable Of oPanelBtn ONSTOP STR0007 ;				//Cancelar
Action ( lRet := .F., oDlg:End() )
Activate MsDialog oDlg Centered

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �MT28CAMPO �Autor  �Miguel Angel. Rojas G. � Data �13/02/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Validacion para el campo CPO_CAMPO                         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MT28CAMPO                                                  ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EprL1: .T./.F.                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SX3VALID -CPO_CAMPO                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function MT28CAMPO()
Local cVar := &(ReadVar())
Local lRet := .f.

SX3->(DBSETORDER(2))   //SX3_CAMPO
IF SX3->(DbSeek(cVar)) .AND. (SX3->X3_ARQUIVO=="CPP" .OR. SX3->X3_ARQUIVO=="CPQ")
	lRet := .t.
Else
	Help( ,, STR0008,,STR0009 ,1, 0 )  // Aviso, El campo no pertenece a las tablas CPP/CPQ	
EndIf
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �MT28POS    � Autor �Miguel Angel. Rojas G.� Data �14/02/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Valida que se eliminen las funciones de tipo sistema al     ���
���          �presionar Confirmar cuanto estamos en Borrar                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MT28POS(EprO1)                                              ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�ExprO1: Objeto que contiene el modelo de datos              ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExprL1 : .t./.f.                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA028                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MT28POS( oMdl )
Local nOperation	:= oMdl:GetOperation()
Local lRet 		:= .T.
Local lBorrar		:= .F.
Local lAutomato   := IsBlind()

If nOperation ==	MODEL_OPERATION_DELETE   	
	If !lAutomato
		lBorrar := MsgNoYes(STR0011)	           //Est�s seguro de eliminar
		if lBorrar
		  lRet := .T.
		Else
		  lRet := .F.
		  Help( ,, STR0003,,STR0012,1, 0 )        //Aviso, No se hicieron cambios.
		Endif
	 Else
	   	lRet := .T.   // Se omite la confirmaci�n del usuario para la rutina autom�tica
	 EndIf			
EndIF
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �MT28POS    � Autor �Mayra.Camargo         � Data �08/08/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �LLenado del grid al ser una nueva configuraci�n.            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fgetSX3Cpos(cTabla,aCampos)                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�oMdl:=Modelo de datos										    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA028                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//
Static Function M458FILLGRID(oMdl)
	Local lRet 	:= .T.
	Local oMdlGr	:= oMdl:GetModel('CPODETAIL')
	Local aCampos:= {}
	Local aCols	:= {}
	Local nI		:= 0
	Local nOp		:= oMdl:GetOperation()
	Local cNodo	:= ""
	Local cCampo	:= ""
	
	If nOp == MODEL_OPERATION_INSERT
		fgetSX3Cpos("CPP",@aCampos)
		fgetSX3Cpos("CPQ",@aCampos)
		
	
		For nI := 1 to len(aCampos)
			cCampo := alltrim(aCampos[nI])
			Do Case
				Case cCampo $ "CPP_UUID|CPQ_UUID"		
					cNodo := "_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_UUID:TEXT"
				Case cCampo $ "CPP_EMISSA|CPQ_EMISSA"
					cNodo := "_CFDI_COMPROBANTE:_FECHA:TEXT"
				Case  cCampo $ "CPP_FECTIM"
					cNodo := "_CFDI_COMPROBANTE:_CFDI_COMPLEMENTO:_TFD_TIMBREFISCALDIGITAL:_FECHATIMBRADO:TEXT"
				Otherwise
					cNodo:= "_CFDI_COMPROBANTE"
			EndCase
			oMdlGr:SetValue("CPO_FILIAL",XFILIAL("CPO"))
			oMdlGr:SetValue("CPO_CONFIG","0")
			oMdlGr:SetValue("CPO_CAMPO",cCampo)
			oMdlGr:SetValue("CPO_ELEMEN",cNodo)
			oMdlGr:SetValue("CPO_OBLIGA",'1')
			oMdlGr:AddLine()
						
		Next nI			
	EndIF

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �MT28POS    � Autor �Mayra.Camargo         � Data �08/08/2014���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Obtiene los camposo bligatorios de cpp/cpq de la SX3        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �fgetSX3Cpos(cTabla,aCampos)                                 ���   
�������������������������������������������������������������������������Ĵ��
���Parametros�cTabla	:=Tabla del diccionario para la b�suqueda            ���
���          �aCampos:=Array a llenar con los campos obtenidos            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA028                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//
Static function fgetSX3Cpos(cTabla,aCampos)
	Local aArea 	:= getArea()
	DEFAULT aCampos	:= {}
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))	
	SX3->(dbSeek(cTabla))
	
	While SX3->(!eof()) .AND. SX3->X3_ARQUIVO == cTabla
		If X3OBRIGAT(X3_CAMPO)  // Si el campo es obligatorio
			AADD(aCampos,SX3->X3_CAMPO) // Se agrega al array de campos obigatorios
		EndIF
		SX3->(dbSkip())
	EndDo
	
	RestArea(aArea)
Return