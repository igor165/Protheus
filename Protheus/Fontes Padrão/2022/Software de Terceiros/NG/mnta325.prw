#INCLUDE "MNTA325.ch"
#Include "Protheus.ch"
#Include 'FWMVCDef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA325
Cadastro de tipos de status da Ordem de Servi�o

@author Gustavo Henrique Voigt

@since 24/10/2019

@return Nil
/*/
//----------------------------------------------------------------------
Function MNTA325()

   Local oBrowse

   oBrowse := FWMBrowse():New()
   oBrowse:SetAlias( 'TQW' )
   oBrowse:SetDescription( STR0001 ) // 'Tipo de Status'
   oBrowse:SetMenuDef( 'MNTA325' )
   oBrowse:Activate()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Gustavo Henrique Voigt

@since 24/10/2019

@return FwMvcMenu( 'Mnta325' )
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

Return FwMvcMenu( 'Mnta325' ) // No momento ainda n�o possui 'Pesquisar'

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Gustavo Henrique Voigt

@since 24/10/2019

@return oModel, objeto, Modelo MVC
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

   Local oModel
   Local oStrumTQW := FWFormStruct(1, 'TQW')

   oModel := MPFormModel():New( 'MNTA325' )

   /*For�ar valida��o do campo devido � erro de dicion�rio.
   Fun��o Pertence(), MNTA325CKTS e MNT325CKTC() s�o ignoradas.
   
   Foi necess�rio tornar obrigat�rio devido a possibilidade de cadastro vazio,
   sendo assim, a primary key se tornava vazia e caso cadastrasse novamente vazio
   gerava errorlog */
   oStrumTQW:SetProperty('TQW_TIPOST', MODEL_FIELD_VALID, {|oModel| Mnta325Vld('TQW_TIPOST', oModel)})
   oStrumTQW:SetProperty('TQW_TIPOST', MODEL_FIELD_OBRIGAT, .T.)
   oStrumTQW:SetProperty('TQW_CORSTA', MODEL_FIELD_VALID, {|oModel| Mnta325Vld('TQW_CORSTA', oModel)})
   oStrumTQW:SetProperty('TQW_CORSTA', MODEL_FIELD_OBRIGAT, .T.)
   oStrumTQW:SetProperty('TQW_STATUS', MODEL_FIELD_OBRIGAT, .T.)
   oStrumTQW:SetProperty('TQW_DESTAT', MODEL_FIELD_OBRIGAT, .T.)

   oModel:AddFields('MNTA325_TQW', Nil, oStrumTQW)
   oModel:SetDescription( STR0001 ) // 'Tipo de Status'

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Gustavo Henrique Voigt

@since 24/10/2019

@return oView, objeto, View MVC
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

   Local oModel := FWLoadModel( 'MNTA325' )
   Local oStruvTQW := FWFormStruct(2, 'TQW')
   Local oView

   oView := FWFormView():New()
   oView:SetModel( oModel )
   oView:AddField('MNTA325_TQW', oStruvTQW)
   oView:CreateHorizontalBox('MASTER', 100)
   oView:SetOwnerView('MNTA325_TQW', 'MASTER')

   //Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnt325Per
Verificar inser��o de valor nos campos especificados, eliminando espa�os em branco. Assim como a;
valida��o por meio do ExistChav() dos campos.

@param nField, num�rico, valor para identifica��o (1 para tipo, 2 para cor).
@param oModel, objeto, model do mnta325.

@author Gustavo Henrique Voigt

@since 24/10/2019


@return lRet, l�gico, retorna valor l�gico.
/*/
//-----------------------------------------------------------------------
Function Mnta325Vld( cField, oModel)

   Local lRet := .T. 

   If cField == 'TQW_TIPOST'
      If !(Alltrim(oModel:GetValue(cField)) $ '1/2/3/4/5/6/7')

         Help(' ', 1, STR0004,, STR0012, 3, 1,,,,,, ; // 'N�O CONFORMIDADE' 'Valor de campo inv�lido.'
         {STR0003}) // 'Informe um tipo de status v�lido.'

         lRet := .F.

      ElseIf !ExistChav('TQW', oModel:GetValue(cField), 3)
         
         lRet := .F.

      EndIf  

   ElseIf cField == 'TQW_CORSTA'
      If !(Alltrim(oModel:GetValue( cField )) $ '1/2/3/4/5/6/7/8/9/10')

         Help(' ', 1, STR0004,, STR0012, 3, 1,,,,,, ; // 'N�O CONFORMIDADE' 'Valor de campo inv�lido.'
         {STR0006}) // 'Informe uma cor v�lida.'
      
         lRet := .F.
      
      ElseIf !ExistChav('TQW', oModel:GetValue( cField ), 4)

         lRet := .F.

      EndIf 

   EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT325CKTS
Valida o tipo de status informado ( Usado no valid do campo )

@author  Elisangela Costa
@since   27/11/07
@version P11/P12
@return  L�gico, define se o status poder� ser utilizado
/*/
//-------------------------------------------------------------------
Function MNT325CKTS()

   Local lACHOU := .F., cCODSTA         
   dbSelectArea("TQW")
   nINDTQW := IndexOrd()
   nRECTQW := Recno()

   dbSetOrder(03)
   dbSeek(xFilial("TQW")+M->TQW_TIPOST,.T.)
   While !Eof() .And. TQW->TQW_FILIAL == xFilial("TQW") .And. Alltrim(TQW->TQW_TIPOST) == Alltrim(M->TQW_TIPOST);
   .And. !lACHOU
         
      If ALTERA .And. Recno() == nRECTQW
         dbSkip()
         Loop
      EndIf 
      lACHOU := .T.
      cCODSTA := TQW->TQW_STATUS
      
      dbSelectArea("TQW")
      dbSkip()
   End              
   dbSelectArea("TQW")
   dbSetOrder(nINDTQW)
   dbGoto(nRECTQW)

   If lACHOU
      MsgInfo(STR0002+" "+Alltrim(cCODSTA)+"."+CHR(13)+; //"Tipo de status j� cadastrado para o Status"
            STR0003,STR0004)  //"Informe outro tipo de status."###"N�O CONFORMIDADE"
      Return .F.
   EndIf 

Return .T.   

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT325CKTC
Valida a cor informada ( Utilizada no valid de campo )

@author  Elisangela Costa 
@since   27/11/07
@version P11/P12
@return  L�gico, define se a cor informada � v�lida.
/*/
//-------------------------------------------------------------------
Function MNT325CKTC()

   Local lACHOU := .F., cCODSTA         
   dbSelectArea("TQW")
   nINDTQW := IndexOrd()
   nRECTQW := Recno()

   dbSetOrder(04)
   dbSeek(xFilial("TQW")+M->TQW_CORSTA,.T.)
   While !Eof() .And. TQW->TQW_FILIAL == xFilial("TQW") .And. Alltrim(TQW->TQW_CORSTA) == Alltrim(M->TQW_CORSTA) ;
   .And. !lACHOU
         
      If ALTERA .And. Recno() == nRECTQW
         dbSkip()
         Loop
      EndIf 
      lACHOU := .T.
      cCODSTA := TQW->TQW_STATUS
      
      dbSelectArea("TQW")
      dbSkip()
   End              
   dbSelectArea("TQW")
   dbSetOrder(nINDTQW)
   dbGoto(nRECTQW)

   If lACHOU
      MsgInfo(STR0005+" "+Alltrim(cCODSTA)+"."+CHR(13)+; //"Cor do status j� cadastrado para o Status"
            STR0006,STR0004)  //"Informe outra cor para o status."###"N�O CONFORMIDADE"
      Return .F.
   EndIf 

Return .T. 
