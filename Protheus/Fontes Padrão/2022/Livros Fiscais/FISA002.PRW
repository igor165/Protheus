#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA002.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA002 

@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function FISA002(lLoad,lApurConso,cReg,lAutomato)
	DEFAULT lApurConso	:= '1'
	DEFAULT cReg			:= ''
	DEFAULT lAutomato 	:= .F.
	STATIC PIS 			:= '1'	
	STATIC COF 			:= '2'
	STATIC NAOCUMULAT	:= '1'
	STATIC CUMULAT 		:= '2'
	PRIVATE CKZT			:= ''
	PRIVATE CKZR			:= ''	
	PRIVATE CKZD			:= ''	
	PRIVATE CKZN			:= ''	
	PRIVATE CKZDC			:= ''	
	PRIVATE CALIAS004	:= ''	
	PRIVATE LCARREGA		:= lLoad
	PRIVATE CCONSOL		:= Iif(lApurConso,'1','2')	
	PRIVATE CDESCRREG		:= DescrReg(cReg)
	
	If !lAutomato
		//Chama a View da rotina diretamente
		FWExecView('Filial: ' + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA002', MODEL_OPERATION_UPDATE,, { || .T. }, { || ASA001GDUP() }) 	
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( 'FISA002' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80
@history 27/04/2018, Vogas Júnior, Verificando a  existência da variável LCARREGA. 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel	
	Local aArray	:= {}
	Local oStruABA	:= FWFormStruct( 1, 'CKR')
	Local oStruABA1	:= x001Struct(1,'ABA1')
	Local oStruABA2	:= x001Struct(1,'ABA2')	
	Local oStruABA3	:= x001Struct(1,'ABA3')
	Local oStruABA4	:= x001Struct(1,'ABA4')	
	Local oStruABA5	:= x001Struct(1,'ABA5')	
	Local oStruABA5A	:= x001Struct(1,'ABA5A')
	Local oStruABA6	:= x001Struct(1,'ABA6')	
	Local oStruABA7	:= x001Struct(1,'ABA7')
	Local bLoadABA1  := { || a002LdGrid('ABA1',@aArray) } 	
	Local bLoadABA2  := { || a002LdGrid('ABA2',@aArray) }
	Local bLoadABA3  := { || a002LdGrid('ABA3',@aArray) }	
	Local bLoadABA4  := { || a002LdGrid('ABA4',@aArray) } 	
	Local bLoadABA5  := { || a002LdGrid('ABA5',@aArray) }	
	Local bLoadABA5A := { || a002LdGrid('ABA5A',@aArray) }	
	Local bLoadABA6  := { || a002LdGrid('ABA6',@aArray) }
	Local bLoadABA7  := { || a002LdGrid('ABA7',@aArray) }
	Local bDetalhe  := { |oModelGrid, nLine, cAction, cField| ASA01LPRE(oModelGrid, nLine, cAction, cField,aArray) }	
	Local lDetTotCST  := { |oModelGrid, nLine, cAction, cField| ISA002CST(oModelGrid, nLine, cAction, cField) }
			
	oModel	:=	MPFormModel():New('FISA002',,{ |oModel| .T. } ,{|oModel| .T. })

			
	oModel:AddFields( 'MODEL_ABA' ,, oStruABA )
	
		//Montagem do grid da primeira ABA
//	oModel:AddGrid( 'MODEL_ABA1' ,'MODEL_ABA', oStruABA1 ,,,,, bLoadABA1)
	oModel:AddGrid( 'MODEL_ABA1', 'MODEL_ABA', oStruABA1,lDetTotCST,,,,bLoadABA1)
	oModel:GetModel( 'MODEL_ABA1' ):SetNoInsertLine( .T. )
//	oModel:GetModel( 'MODEL_ABA1' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA1' ):SetNoDeleteLine( .T. )
		
	//Montagem do grid da segunda ABA
	oModel:AddGrid( 'MODEL_ABA2' ,'MODEL_ABA', oStruABA2 ,lDetTotCST,,,, bLoadABA2)
	oModel:GetModel( 'MODEL_ABA2' ):SetNoInsertLine( .T. )
//	oModel:GetModel( 'MODEL_ABA2' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA2' ):SetNoDeleteLine( .T. )
	
	//Montagem do grid da terceira ABA
	oModel:AddGrid( 'MODEL_ABA3' ,'MODEL_ABA', oStruABA3 ,bDetalhe,,,, bLoadABA3)
	oModel:GetModel( 'MODEL_ABA3' ):SetNoInsertLine( .T. )
//	oModel:GetModel( 'MODEL_ABA3' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA3' ):SetNoDeleteLine( .T. )

	//Montagem do grid da quarta ABA
	oModel:AddGrid( 'MODEL_ABA4' ,'MODEL_ABA', oStruABA4 ,bDetalhe,,,, bLoadABA4)
	oModel:GetModel( 'MODEL_ABA4' ):SetNoInsertLine( .T. )
	//oModel:GetModel( 'MODEL_ABA4' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA4' ):SetNoDeleteLine( .T. )

	//Montagem do grid da quinta-superior ABA
	oModel:AddGrid( 'MODEL_ABA5' ,'MODEL_ABA', oStruABA5 ,bDetalhe,,,, bLoadABA5)
	oModel:GetModel( 'MODEL_ABA5' ):SetNoInsertLine( .T. )
///	oModel:GetModel( 'MODEL_ABA5' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA5' ):SetNoDeleteLine( .T. )
		
	//Montagem do grid da quinta-inferior ABA
	oModel:AddGrid( 'MODEL_ABA5A' ,'MODEL_ABA', oStruABA5A ,,,,, bLoadABA5A)
	oModel:GetModel( 'MODEL_ABA5A' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA5A' ):SetNoDeleteLine( .T. )
	If Type('LCARREGA') <> 'U' .And. LCARREGA
		oModel:GetModel( 'MODEL_ABA5A' ):SetNoUpdateLine( .T. )
	EndIF	
	
	//Montagem do grid da sexta ABA
	oModel:AddGrid( 'MODEL_ABA6' ,'MODEL_ABA', oStruABA6 ,,,,, bLoadABA6)
	oModel:GetModel( 'MODEL_ABA6' ):SetNoInsertLine( .T. )
//	oModel:GetModel( 'MODEL_ABA6' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA6' ):SetNoDeleteLine( .T. )

	//Montagem do grid da sétima ABA
	oModel:AddGrid( 'MODEL_ABA7' ,'MODEL_ABA', oStruABA7 ,,,,, bLoadABA7)
	oModel:GetModel( 'MODEL_ABA7' ):SetNoInsertLine( .T. )
//	oModel:GetModel( 'MODEL_ABA7' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'MODEL_ABA7' ):SetNoDeleteLine( .T. )

	oModel:SetPrimaryKey( { 'ABA1_CMP1'} )
	oModel:SetDescription( 'TOTVS')
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     	 := FWLoadModel( 'FISA002' )
Local oView        := FWFormView():New()
Local oStruABA1   := x001Struct(2, 'ABA1')
Local oStruABA2   := x001Struct(2, 'ABA2')
Local oStruABA3   := x001Struct(2, 'ABA3')
Local oStruABA4   := x001Struct(2, 'ABA4')
Local oStruABA5   := x001Struct(2, 'ABA5')
Local oStruABA5A  := x001Struct(2, 'ABA5A')
Local oStruABA6   := x001Struct(2, 'ABA6')
Local oStruABA7   := x001Struct(2, 'ABA7')
Local cDescr		:= 'Período:' + MesExtenso(mv_par01) + '/' +  Str(year(mv_par01),4) +' - '
Local cVersao 	:= GetVersao(.F.)

oView:SetModel( oModel ) 



//Cria View para cada grid
oView:AddGrid( 'VIEW_ABA1' ,oStruABA1  ,'MODEL_ABA1'  )  
oView:AddGrid( 'VIEW_ABA2' ,oStruABA2  ,'MODEL_ABA2'  )
oView:AddGrid( 'VIEW_ABA3' ,oStruABA3  ,'MODEL_ABA3'  )
oView:AddGrid( 'VIEW_ABA4' ,oStruABA4  ,'MODEL_ABA4'  )  
oView:AddGrid( 'VIEW_ABA5' ,oStruABA5  ,'MODEL_ABA5'  )
oView:AddGrid( 'VIEW_ABA5A',oStruABA5A ,'MODEL_ABA5A' )
oView:AddGrid( 'VIEW_ABA6' ,oStruABA6  ,'MODEL_ABA6'  )
oView:AddGrid( 'VIEW_ABA7' ,oStruABA7  ,'MODEL_ABA7'  )
   
//Títulos das telas
oView:EnableTitleView('VIEW_ABA1',cDescr+CDESCRREG+STR0130)//'Operações de Saída por CST e Regime'
oView:EnableTitleView('VIEW_ABA2',cDescr+CDESCRREG+STR0131)//'Operações de Entrada por CST'
oView:EnableTitleView('VIEW_ABA3',cDescr+CDESCRREG+STR0132)//'Resumo da Composição dos Débitos'
oView:EnableTitleView('VIEW_ABA4',cDescr+CDESCRREG+STR0133)//'Resumo da Composição dos Créditos'
oView:EnableTitleView('VIEW_ABA5',cDescr+CDESCRREG+STR0134)//'Apuração de PIS COFINS'
oView:EnableTitleView('VIEW_ABA5A',cDescr+STR0135)//'Informações Sobre o Recolhimento dos Tributos'   
oView:EnableTitleView('VIEW_ABA6',cDescr+STR0136)//'Valor de PIS Sobre Folha de Salário'
oView:EnableTitleView('VIEW_ABA7',cDescr+STR0137)//'Contribuição Previdenciária Sobre a Receita Bruta' 
  
//Cria a pasta
oView:CreateFolder( 'PASTAS' )

//Cria as abas
oView:AddSheet( 'PASTAS', 'ABA01', STR0002 )//'OPERAÇÕES DE SAÍDAS'
oView:AddSheet( 'PASTAS', 'ABA02', STR0003 )//'OPERAÇÕES DE ENTRADAS'
oView:AddSheet( 'PASTAS', 'ABA03', STR0004 )//'COMPOSIÇÃO DOS DÉBITOS'
oView:AddSheet( 'PASTAS', 'ABA04', STR0005 )//'COMPOSIÇÃO DOS CRÉDITOS'
oView:AddSheet( 'PASTAS', 'ABA05', STR0006 )//'APURAÇÃO'
oView:AddSheet( 'PASTAS', 'ABA06', STR0007 )//'PIS-FOLHA DE SALÁRIO'
oView:AddSheet( 'PASTAS', 'ABA07', STR0008 )//'CPRB'

//Cria BOX
oView:CreateHorizontalBox( 'TELA1', 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'TELA2', 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'TELA3', 100,,, 'PASTAS', 'ABA03' )
oView:CreateHorizontalBox( 'TELA4', 100,,, 'PASTAS', 'ABA04' )
oView:CreateHorizontalBox( 'TELA5', 65 ,,, 'PASTAS', 'ABA05' )
oView:CreateHorizontalBox( 'TELA5E',2 ,,, 'PASTAS', 'ABA05' )
oView:CreateHorizontalBox( 'TELA5A',33 ,,, 'PASTAS', 'ABA05' )
oView:CreateHorizontalBox( 'TELA6', 100,,, 'PASTAS', 'ABA06' )
oView:CreateHorizontalBox( 'TELA7', 100,,, 'PASTAS', 'ABA07' )

//Relaciona cada grid com sua respectiva aba na tela 
oView:SetOwnerView( 'VIEW_ABA1'  , 'TELA1')
oView:SetOwnerView( 'VIEW_ABA2'  , 'TELA2')
oView:SetOwnerView( 'VIEW_ABA3'  , 'TELA3')
oView:SetOwnerView( 'VIEW_ABA4'  , 'TELA4')
oView:SetOwnerView( 'VIEW_ABA5'  , 'TELA5')
oView:SetOwnerView( 'VIEW_ABA5A' , 'TELA5A')
oView:SetOwnerView( 'VIEW_ABA6'  , 'TELA6')
oView:SetOwnerView( 'VIEW_ABA7'  , 'TELA7')

//INCLUI CHAMADA DA FUNÇÃO ATUALIZA GRID, PARA ATUALIZAR OS VALORES APÓS EDIÇÃO DE AJUSTES MANUAIS
oView:SetFieldAction( 'ABA3_CMP2', { || AtualizaGrid() } )
oView:SetFieldAction( 'ABA3_CMP3', { || AtualizaGrid() } )
oView:SetFieldAction( 'ABA4_CMP2', { || AtualizaGrid() } )
oView:SetFieldAction( 'ABA4_CMP3', { || AtualizaGrid() } )

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER")
EndIF

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizaGrid
Função que irá atualizar as abas considerando os ajustes manuais na tela
efetuados pelo usuário.
@author Erick G. Dias
@since 07/07/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function AtualizaGrid()

Local oModel		:=	FWModelActive()
Local oModelZA2	:= oModel:GetModel( 'MODEL_ABA3' )
lOCAL oView 		:= 	FWViewActive()
Local nI 			:= 0
Local oCredito
Local oApurPIS	
Local oApurCof
local oDebito
Local oGuias

//-----------------------------------------
//AJUSTE NA ABA DOS DÉBITOS NÂO CUMULATIVOS
//-----------------------------------------
aArea	:= GetArea()
oDebito:= COMPDEBITO():New()
oDebito:SetConsol(CCONSOL)
oDebito:SetDtIni(MV_PAR01)
oDebito:LoadDebito(NAOCUMULAT)

For nI := 1 To oModelZA2:Length()
	oModelZA2:GoLine( nI )
	If nI == 5 //Ajuste de acrésciumo
		oModelZA2:SetValue( 'ABA3_CMP2' ,oDebito:GetAjuAcre(PIS) )
		oModelZA2:SetValue( 'ABA3_CMP3' , oDebito:GetAjuAcre(COF))	
	ElseIF nI == 6 //Ajuste de redução
		oModelZA2:SetValue( 'ABA3_CMP2' , oDebito:GetAjuRed(PIS))
		oModelZA2:SetValue( 'ABA3_CMP3' , oDebito:GetAjuRed(COF))	
	ElseIF nI == 9//Valor total dos débitos
		oModelZA2:SetValue( 'ABA3_CMP2' , oDebito:GetValDisp(PIS))
		oModelZA2:SetValue( 'ABA3_CMP3' , oDebito:GetValDisp(COF))  		
	EndIF	
Next

oDebito	:= Nil
RestArea(aArea)
oModelZA2:GoLine( 1 )
oview:Refresh( 'VIEW_ABA3' )

//-----------------------------------------
//AJUSTE NA ABA DOS DÉBITOS CUMULATIVOS
//-----------------------------------------
aArea	:= GetArea()
oDebito:= COMPDEBITO():New()
oDebito:SetConsol(CCONSOL)
oDebito:SetDtIni(MV_PAR01)
oDebito:LoadDebito(CUMULAT)

For nI := 1 To oModelZA2:Length()
	oModelZA2:GoLine( nI )
	If nI == 14 //Ajuste de acrésciumo
		oModelZA2:SetValue( 'ABA3_CMP2' ,oDebito:GetAjuAcre(PIS) )
		oModelZA2:SetValue( 'ABA3_CMP3' , oDebito:GetAjuAcre(COF))	
	ElseIF nI == 15 //Ajuste de redução
		oModelZA2:SetValue( 'ABA3_CMP2' , oDebito:GetAjuRed(PIS))
		oModelZA2:SetValue( 'ABA3_CMP3' , oDebito:GetAjuRed(COF))	
	ElseIF nI == 18 //valor do débito cumulativo
		oModelZA2:SetValue( 'ABA3_CMP2' , oDebito:GetValDisp(PIS))
		oModelZA2:SetValue( 'ABA3_CMP3' , oDebito:GetValDisp(COF))  		
	EndIF	
Next

oDebito	:= Nil
RestArea(aArea)
oModelZA2:GoLine( 1 )
oview:Refresh( 'VIEW_ABA3' )
//--------------------------
//AJUSTE NA ABA DOS CRÉDITOS
//--------------------------

oModelZA2 := oModel:GetModel( 'MODEL_ABA4' )
aArea		:= GetArea()
oCredito 	:= CMPCREDITO():New()		
oCredito:SetConsol(CCONSOL)
oCredito:SetDtIni(MV_PAR01)
oCredito:LoadCredit()	

For nI := 1 To oModelZA2:Length()
	oModelZA2:GoLine( nI )
	If nI == 10 //Ajuste de acrésciumo
		oModelZA2:SetValue( 'ABA4_CMP2' , oCredito:GeTAjuAcre(PIS) )
		oModelZA2:SetValue( 'ABA4_CMP3' , oCredito:GeTAjuAcre(COF))	
	ElseIF nI == 11 //Ajuste de redução
		oModelZA2:SetValue( 'ABA4_CMP2' , oCredito:GeTAjuRed(PIS))
		oModelZA2:SetValue( 'ABA4_CMP3' , oCredito:GeTAjuRed(COF))	
	ElseIF nI == 13//Valor total dos créditos
		oModelZA2:SetValue( 'ABA4_CMP2' , oCredito:GeTVlDisp(PIS))
		oModelZA2:SetValue( 'ABA4_CMP3' , oCredito:GeTVlDisp(COF))  		
	EndIF	
Next

oModelZA2:GoLine( 1 )
oview:Refresh( 'VIEW_ABA4' )
oCredito	:= Nil
RestArea(aArea)

//---------------------------------------
//ATUALIZA OS VALORES DA ABA DE APURAÇÃO
//--------------------------------------
aArea	:= GetArea()
oApurPIS	:= APURPISCOF():New()
oApurPIS:SetConsol(CCONSOL)
oApurPIS:SetRegime(MV_PAR06)
oApurPIS:SetDtIni(MV_PAR01)
oApurPIS:SetGrvDup('1') //Indica que irá atualizar a tabela de duplicata/recolhimento considertando os valores digitados
oApurPIS:setPCrdFut(!MV_PAR06 == 3) //Somente irá processsar valores de créditos para próximo período se não for regime de caixa
oApurPIS:LoadApurPC(PIS)

oApurCof	:= APURPISCOF():New()
oApurCof:SetConsol(CCONSOL)
oApurCof:SetRegime(MV_PAR06)
oApurCof:SetDtIni(MV_PAR01)
oApurCof:SetGrvDup('1')
oApurCof:setPCrdFut(!MV_PAR06 == 3) //Somente irá processsar valores de créditos para próximo período se não for regime de caixa
oApurCof:LoadApurPC(COF)
					

oModelZA2 := oModel:GetModel( 'MODEL_ABA5' )				
For nI := 1 To oModelZA2:Length()
	oModelZA2:GoLine( nI )
	If nI == 4 //Valor tot contribuição NC
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetVlContr(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetVlContr(NAOCUMULAT))
	ElseIf nI == 5 //Credito período anterior
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetCrdAnt(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetCrdAnt(NAOCUMULAT))
	ElseIf nI == 6 //Credito período atual
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetCrdAtu(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetCrdAtu(NAOCUMULAT))
	ElseIf nI == 7 //Valor da Contribuição Devida
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetConDev(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetConDev(NAOCUMULAT))
	ElseIf nI == 8 //Valor de retenção na fonte período anterior
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetRetAnt(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetRetAnt(NAOCUMULAT))
	ElseIf nI == 9 //Valor de retenção na fonte período anterior
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetRetAtu(NAOCUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetRetAtu(NAOCUMULAT))
	ElseIf nI == 10 //Outras Deduções no período
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetOutDed(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' ,oApurCof:GetOutDed(NAOCUMULAT))
	ElseIf nI == 11 //Valor da contribuição não cumulativa a recolher
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetVlRecol(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' , oApurCof:GetVlRecol(NAOCUMULAT))
	ElseIf nI == 13 //Valor de credito a transportar para proximo mes
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetSldCrd(NAOCUMULAT) )
		oModelZA2:SetValue( 'ABA5_CMP3' ,oApurCof:GetSldCrd(NAOCUMULAT))
	ElseIf nI == 14 //Valor de retenção a transportar para proximo mes
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetSldRet(NAOCUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,  oApurCof:GetSldRet(NAOCUMULAT))
	ElseIf nI == 18 //Valor tot contribuição cumulativa
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetVlContr(CUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,  oApurCof:GetVlContr(CUMULAT))
	ElseIf nI == 19 //Valor de retenção na fonte período anterior
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetRetAnt(CUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,  oApurCof:GetRetAnt(CUMULAT))
	ElseIf nI == 20 //Valor de retenção na fonte período anterior
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetRetAtu(CUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,  oApurCof:GetRetAtu(CUMULAT))				
	ElseIf nI == 21 //Outras Deduções no período
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetOutDed(CUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,  oApurCof:GetOutDed(CUMULAT))	
	ElseIf nI == 22 //Valor da contribuição cumulativa a recolher
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetVlRecol(CUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,   oApurCof:GetVlRecol(CUMULAT))		
	ElseIf nI == 24 //Valor de retenção a transportar para proximo mes
		oModelZA2:SetValue( 'ABA5_CMP2' , oApurPIS:GetSldRet(CUMULAT))
		oModelZA2:SetValue( 'ABA5_CMP3' ,  oApurCof:GetSldRet(CUMULAT))
	EndIF	
Next

oModelZA2:GoLine( 1 )

oview:Refresh( 'VIEW_ABA5' )
oApurPis	:= Nil
oApurCof	:= Nil
RestArea(aArea)

//-------------------------------------------
//ATUALIZA OS VALORES DA ABA DE RECOLHIMENTO
//------------------------------------------
aArea	:= GetArea()
oGuias	:= APURPISCOF():New()
oGuias:SetConsol(CCONSOL)	
oGuias:SetRegime(MV_PAR06)
oGuias:SetDtIni(MV_PAR01)
oGuias:LoadRecolh()

oModelZA2 := oModel:GetModel( 'MODEL_ABA5A' )				
For nI := 1 To oModelZA2:Length()
	oModelZA2:GoLine( nI )
	If nI == 4 //PIS NAO CUMULATIVO
		oModelZA2:SetValue( 'ABA5A_CMP2' , oGuias:GetCodRec('1'))
		oModelZA2:SetValue( 'ABA5A_CMP3' , oGuias:GetValor('1'))
		oModelZA2:SetValue( 'ABA5A_CMP4' , oGuias:GetDtVenc('1'))				
	ElseIF nI == 5 //PIS CUMULATIVO
		oModelZA2:SetValue( 'ABA5A_CMP2' , oGuias:GetCodRec('2'))
		oModelZA2:SetValue( 'ABA5A_CMP3' , oGuias:GetValor('2'))
		oModelZA2:SetValue( 'ABA5A_CMP4' , oGuias:GetDtVenc('2'))
	ElseIF nI == 6 //COFINS NAO CUMULATIVO
		oModelZA2:SetValue( 'ABA5A_CMP2' , oGuias:GetCodRec('3'))
		oModelZA2:SetValue( 'ABA5A_CMP3' , oGuias:GetValor('3'))
		oModelZA2:SetValue( 'ABA5A_CMP4' , oGuias:GetDtVenc('3'))
	ElseIF nI == 7 //COFINS CUMULATIVO
		oModelZA2:SetValue( 'ABA5A_CMP2' , oGuias:GetCodRec('4'))
		oModelZA2:SetValue( 'ABA5A_CMP3' , oGuias:GetValor('4'))
		oModelZA2:SetValue( 'ABA5A_CMP4' , oGuias:GetDtVenc('4'))						
	EndIF
Next nI

oModelZA2:GoLine( 1 )

oview:Refresh( 'VIEW_ABA5A' )
oGuias	:= Nil
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x002Tabs
 
 Função que monta as propriedades de cada campo da tabela temporária
 de cada aba das telas de apuração
  
@param  	cTabela  - Tabela a qual serão criados os campos
@return	aCampos  - Array com as propriedades dos campos que serão criados
			
@author Erick G. Dias
@since 08/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function a002Tabs(cTabela)

Local aCampos	:= {}

//aAdd(aCampos, {/*Título*/,/*Nome do campo*/,/*Tipo*/,/*Tamanho*/,/*Decimal*/,/*Ordem*/,/*Array com help*/,/*Picture*/,/*Campo editáveç*/})

Do Case

	Case cTabela == 'ABA'
		aAdd(aCampos, {STR0009,'ABA_CMP1' ,'C',75,0,'01',{STR0014},'@!'				  ,.T.})//'Operações'		
	Case cTabela == 'ABA1'
		//---------------------------------------------
		// Cria as colunas da primeira tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {STR0129,'ABA1_CMP1' ,'C',50,0,'01',{STR0014},'@!'				  ,.T.})//'Operações' 
		aAdd(aCampos, {STR0010,'ABA1_CMP2','N',14,2,'02',{STR0015},'@E 999,999,999.99',.T.})//'Base de cálculo - Não Cumulativo'
		aAdd(aCampos, {STR0011,'ABA1_CMP3','N',14,2,'03',{STR0016},'@E 999,999,999.99',.T.})//'Base de cálculo -  Cumulativo'
		aAdd(aCampos, {STR0012,'ABA1_CMP4','N',14,2,'04',{STR0017},'@E 999,999,999.99',.T.})//'Base de cálculo -  Cumulativo'
		aAdd(aCampos, {STR0013,'ABA1_CMP5','N',14,2,'05',{STR0018},'@E 999,999,999.99',.T.})//'Receita -  Cumulativo'	
	
	Case cTabela == 'ABA2'
		//---------------------------------------------
		// Cria as colunas da segunda tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {STR0129,'ABA2_CMP1','C',75,0,'01',{STR0053},'@!'				  ,.T.})//'Operações de entradas' 
		aAdd(aCampos, {STR0054,'ABA2_CMP2','N',14,2,'02',{STR0054},'@E 999,999,999.99',.T.})//'Base de Cálculo'
		aAdd(aCampos, {STR0055,'ABA2_CMP3','N',14,2,'03',{STR0055},'@E 999,999,999.99',.T.})//'Valor da Operação' 
	
	Case cTabela == 'ABA3'
		//---------------------------------------------
		// Cria as colunas da terceira tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {STR0129,'ABA3_CMP1','C',75,0,'01',{STR0112},'@!'				  ,.T.})//'Composição dos Débitos' 
		aAdd(aCampos, {STR0113,'ABA3_CMP2','N',14,2,'02',{STR0113},'@E 999,999,999.99',.T.})//'Valores de PIS'
		aAdd(aCampos, {STR0114,'ABA3_CMP3','N',14,2,'03',{STR0114},'@E 999,999,999.99',.T.})//'Valores da COFINS'	
	
	Case cTabela == 'ABA4'
		//---------------------------------------------
		// Cria as colunas da quarta tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {STR0129,'ABA4_CMP1','C',75,0,'01',{STR0115},'@!'				  ,.T.})//'Composição dos Créditos' 
		aAdd(aCampos, {STR0116,'ABA4_CMP2','N',14,2,'02',{STR0116},'@E 999,999,999.99',.T.})//'Créditos de PIS'
		aAdd(aCampos, {STR0117,'ABA4_CMP3','N',14,2,'03',{STR0117},'@E 999,999,999.99',.T.})//'Créditos da COFINS'
	
	Case cTabela == 'ABA5'
		//----------------------------------------------------
		// Cria as colunas da quinta tela-superior da apuração
		//----------------------------------------------------
		aAdd(aCampos, {STR0129,'ABA5_CMP1','C',75,0,'01',{STR0118},'@!'				  ,.F.})//'Apuração' 
		aAdd(aCampos, {STR0119,'ABA5_CMP2','N',14,2,'02',{STR0119},'@E 999,999,999.99',.T.})//'Valores de PIS'
		aAdd(aCampos, {STR0120,'ABA5_CMP3','N',14,2,'03',{STR0120},'@E 999,999,999.99',.T.})//'Valores da COFINS'
	
	Case cTabela == 'ABA5A'
		//----------------------------------------------------
		// Cria as colunas da quinta tela-inferior da apuração
		//----------------------------------------------------
		aAdd(aCampos, {STR0129,'ABA5A_CMP1','C',53,0,'01',{STR0121},'@!'				  ,.F.})//'Tributo' 
		aAdd(aCampos, {STR0122,'ABA5A_CMP2','C',6,0,'02',{STR0122},'@!',.T.})//'Código da Receita'
		aAdd(aCampos, {STR0123+' a pagar','ABA5A_CMP3','N',14,2,'03',{STR0123},'@E 999,999,999.99',.F.})//'Valor do Tributo'	
		aAdd(aCampos, {STR0124,'ABA5A_CMP4','D',10,0,'04',{STR0124},'',.T.})//'Data de Vencimento'
	
	Case cTabela == 'ABA6'
		//-------------------------------------------
		// Cria as colunas da sexta tela da apuração
		//-------------------------------------------
		aAdd(aCampos, {STR0129,'ABA6_CMP1','C',75,0,'01',{STR0125},'@!'				  ,.F.})//'PIS Sobre Folha de Salário' 
		aAdd(aCampos, {STR0126,'ABA6_CMP2','N',14,2,'02',{STR0126},'@E 999,999,999.99',.F.})//'Valores'		
	
	Case cTabela == 'ABA7'
		//-------------------------------------------
		// Cria as colunas da sétima tela da apuração
		//------------ -------------------------------
		aAdd(aCampos, {STR0129,'ABA7_CMP1','C',75,0,'01',{STR0127},'@!'				  ,.F.})//'Contribuição Previdenciária - Receita Bruta' 
		aAdd(aCampos, {STR0128,'ABA7_CMP2','N',14,2,'02',{STR0128},'@E 999,999,999.99',.F.})//'Valores'		
	
EndCase

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} a002LdGrid
 
 Função que irá retornar as informações para pouplar as linhas
 das tabelas temporárias de cada aba da tela de apuração.
  
@param  	cTabela  - Tabela a qual serão será populada
@return	aLoad   - Array com as informações e valores para popular as telas
			
@author Erick G. Dias
@since 08/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function a002LdGrid(cTabela,aArray)

Local aLoad  		:= {}
Local aGuias		:= {}
Local nCont			:= 0
Local nX			:= 0
Local cCstTrib	:= '01/02/03'
Local cCstNTrib	:= '04/05/06/07/08/09/49'
Local cSeqTrib	:= '4'
Local lNewProc	:= findfunction("ISA001NDIF") .AND. ISA001NDIF()
Local oSaiCST
Local oEntCST
Local oDebito
Local oCredito
Local oApurPIS
Local oApurCof
Local oGuias
Local oPisFolha
Local oCPRB
Local lF2Z	:= AliasIndic("F2Z")
Local lProcCPRB	:= .F.

Local i			:= 0
Local aDados	:= {}

Do Case
	Case cTabela == 'ABA1'		
		

		//Cria Objeto de saídas por CST
		oSaiCST 	:= VALORESCST():New()	
		oSaiCST:SetConsol(CCONSOL)
		
		//Passa período de referência		
		oSaiCST:SetDtIni(MV_PAR01)
		
		//Carrega valores de saídas por CST
		oSaiCST:LoadTotCST()	
		//---------------------------------------------------------------------------------
		// Insere informações na primeira tela da apuração - Resumo das operações de saídas
		//---------------------------------------------------------------------------------
		aAdd( aLoad, { nX++,  { '',,,,} } )
		aAdd( aLoad, { nX++,  { STR0019, oSaiCST:GetBaseNC('01'),oSaiCST:GetRecNC('01'), oSaiCST:GetBaseC('01'), oSaiCST:GetRecC('01')} } )//'01 - Tributável Alíquota Básica'		
		aAdd( aLoad, { nX++,  { STR0020, oSaiCST:GetBaseNC('02'),oSaiCST:GetRecNC('02'), oSaiCST:GetBaseC('02'), oSaiCST:GetRecC('02')} } )//'02 - Tributável Alíquota Diferenciada'		
		aAdd( aLoad, { nX++,  { STR0021, 0							,oSaiCST:GetRecNC('03'), 0						 , oSaiCST:GetRecC('03')} } )//'03 - Tributável Alíquota em Reais'		
		aAdd( aLoad, { nX++,  { STR0022, oSaiCST:GetBaseNC('04'),oSaiCST:GetRecNC('04'), oSaiCST:GetBaseC('04'), oSaiCST:GetRecC('04')} } )//'04 - Tributável Monofásica - Revenda a Alíquota Zero'		
		aAdd( aLoad, { nX++,  { STR0023, oSaiCST:GetBaseNC('05'),oSaiCST:GetRecNC('05'), oSaiCST:GetBaseC('05'), oSaiCST:GetRecC('05')} } )//'05 - Tributável Substituição Tributária'		
		aAdd( aLoad, { nX++,  { STR0024, oSaiCST:GetBaseNC('06'),oSaiCST:GetRecNC('06'), oSaiCST:GetBaseC('06'), oSaiCST:GetRecC('06')} } )//'06 - Tributável a Alíquota Zero'		
		aAdd( aLoad, { nX++,  { STR0025, oSaiCST:GetBaseNC('07'),oSaiCST:GetRecNC('07'), oSaiCST:GetBaseC('07'), oSaiCST:GetRecC('07')} } )//'07 - Isenta da Contribuição'		
		aAdd( aLoad, { nX++,  { STR0026, oSaiCST:GetBaseNC('08'),oSaiCST:GetRecNC('08'), oSaiCST:GetBaseC('08'), oSaiCST:GetRecC('08')} } )//'08 - Sem Incidência da Contribuição'		
		aAdd( aLoad, { nX++,  { STR0027, oSaiCST:GetBaseNC('09'),oSaiCST:GetRecNC('09'), oSaiCST:GetBaseC('09'), oSaiCST:GetRecC('09')} } )//'09 - Suspensão da Contribuição'		
		aAdd( aLoad, { nX++,  { STR0028, oSaiCST:GetBaseNC('49'),oSaiCST:GetRecNC('49'), oSaiCST:GetBaseC('49'), oSaiCST:GetRecC('49')} } )//'49 - Outras Operações'
		aAdd( aLoad, { nX++,  { '',,,,} } )
		aAdd( aLoad, { nX++,  { STR0029, oSaiCST:GetBaseNC('01/02')	,oSaiCST:GetRecNC(cCstTrib)		, oSaiCST:GetBaseC('01/02')		, oSaiCST:GetRecC(cCstTrib)} } )//'Valor Total da Operações tributadas'
		aAdd( aLoad, { nX++,  { STR0030, oSaiCST:GetBaseNC(cCstNTrib)	,oSaiCST:GetRecNC(cCstNTrib)	, oSaiCST:GetBaseC(cCstNTrib)	, oSaiCST:GetRecC(cCstNTrib)} } )//'Valor Total da Operações não tributadas'
		aAdd( aLoad, { nX++,  { '',,,,} } )
		oSaiCST	:= nil

	Case cTabela == 'ABA2'		
		//---------------------------------------------------------------------------------
		// Insere informações na segunda tela da apuração - Resumo das operações de entrada
		//---------------------------------------------------------------------------------
		
		//Cria Objeto de entradas por CST
		oEntCST 	:= VALORESCST():New()	
		oEntCST:SetConsol(CCONSOL)
		
		//Passa período de referência		
		oEntCST:SetDtIni(MV_PAR01)
		
		//Carrega valores de entradas por CST
		oEntCST:LoadTotCST()	

		aAdd( aLoad, {nX++,  { '',,} } )
		aAdd( aLoad, {nX++,  { Space(35)+STR0056,,} } ) //'-- operações com direito ao crédito --'
		aAdd( aLoad, {nX++,  { ''      ,    ,    ,     ,     } } )
		aAdd( aLoad, {nX++,  { STR0031, oEntCST:GetBaseNC('50'), oEntCST:GetRecNC('50')} } )//'50 - Vinculada a Receita Tributada'
		aAdd( aLoad, {nX++,  { STR0032, oEntCST:GetBaseNC('51'), oEntCST:GetRecNC('51')} } )//'51 - Vinculada a Receita Não Tributada'
		aAdd( aLoad, {nX++,  { STR0033, oEntCST:GetBaseNC('52'), oEntCST:GetRecNC('52')} } )//'52 - Vinculada a Receita de Exportação'
		aAdd( aLoad, {nX++,  { STR0034, oEntCST:GetBaseNC('53'), oEntCST:GetRecNC('53')} } )//'53 - Vinculada a Receita Tributada e Não Tributada'
		aAdd( aLoad, {nX++,  { STR0035, oEntCST:GetBaseNC('54'), oEntCST:GetRecNC('54')} } )//'54 - Vinculada a Receita Tributada e Exportação'
		aAdd( aLoad, {nX++,  { STR0036, oEntCST:GetBaseNC('55'), oEntCST:GetRecNC('55')} } )//'55 - Vinculada a Receita Não Tributada e Exportação'
		aAdd( aLoad, {nX++,  { STR0037, oEntCST:GetBaseNC('56'), oEntCST:GetRecNC('56')} } )//'56 - Vinculada a Receita Tributada, Não tributada e Exportação'
		aAdd( aLoad, {nX++,  { '',,} } )
		aAdd( aLoad, {nX++,  { Space(35)+STR0057,,} } )//'-- operações com direito ao crédito presumido'
		aAdd( aLoad, {nX++,  { '',,} } )
		aAdd( aLoad, {nX++,  { STR0038, oEntCST:GetBaseNC('60'), oEntCST:GetRecNC('60')} } )//'60 - Crédito Presumido Vinculada a Receita Tributada'
		aAdd( aLoad, {nX++,  { STR0039, oEntCST:GetBaseNC('61'), oEntCST:GetRecNC('61')} } )//'61 - Crédito Presumido Vinculada a Receita Não Tributada'
		aAdd( aLoad, {nX++,  { STR0040, oEntCST:GetBaseNC('62'), oEntCST:GetRecNC('62')} } )//'62 - Crédito Presumido Vinculada a Receita de Exportação'
		aAdd( aLoad, {nX++,  { STR0041, oEntCST:GetBaseNC('63'), oEntCST:GetRecNC('63')} } )//'63 - Crédito Presumido Vinculada a Receita Tributada e Não Tributada'
		aAdd( aLoad, {nX++,  { STR0042, oEntCST:GetBaseNC('64'), oEntCST:GetRecNC('64')} } )//'64 - Crédito Presumido Vinculada a Receita Tributada e Exportação'
		aAdd( aLoad, {nX++,  { STR0043, oEntCST:GetBaseNC('65'), oEntCST:GetRecNC('65')} } )//'65 - Crédito Presumido Vinculada a Receita Não Tributada e Exportação'
		aAdd( aLoad, {nX++,  { STR0044, oEntCST:GetBaseNC('66'), oEntCST:GetRecNC('66')} } )//''66 - Crédito Presumido Vinculada a Receita Tributada, Não tributada e Exportação'
		aAdd( aLoad, {nX++,  { '',,} } )
		aAdd( aLoad, {nX++,  { Space(35)+STR0058,,} } )//'-- operações sem direito ao crédito'
		aAdd( aLoad, {nX++,  { '',,} } )
		aAdd( aLoad, {nX++,  { STR0045, oEntCST:GetBaseNC('67'), oEntCST:GetRecNC('67')} } )//'67 - Crédito Presumido - Outras Operações'
		aAdd( aLoad, {nX++,  { STR0046, oEntCST:GetBaseNC('70'), oEntCST:GetRecNC('70')} } )//'70 - Aquisição sem direito ao C´redito'
		aAdd( aLoad, {nX++,  { STR0047, oEntCST:GetBaseNC('71'), oEntCST:GetRecNC('71')} } )//'71 - Aquisição com Isenção'
		aAdd( aLoad, {nX++,  { STR0048, oEntCST:GetBaseNC('72'), oEntCST:GetRecNC('72')} } )//'72 - Aquisição com Suspensão'
		aAdd( aLoad, {nX++,  { STR0049, oEntCST:GetBaseNC('73'), oEntCST:GetRecNC('73')} } )//'73 - Aquisição a Alíquota Zero'
		aAdd( aLoad, {nX++,  { STR0050, oEntCST:GetBaseNC('74'), oEntCST:GetRecNC('74')} } )//'74 - Aquisição sem Incidência'
		aAdd( aLoad, {nX++,  { STR0051, oEntCST:GetBaseNC('75'), oEntCST:GetRecNC('75')} } )//'75 - Aquisição por Substituição Tributária'
		aAdd( aLoad, {nX++,  { STR0052, oEntCST:GetBaseNC('98'), oEntCST:GetRecNC('98')} } )//'98 - Outras Operações de Entrada'		
		aAdd( aLoad, {nX++,  { '',,} } )
		oEntCST	:= nil
	
	Case cTabela == 'ABA3'
		//-------------------------------------------------------------------------
		// Insere informações na terceira tela da apuração - Composição dos débitos
		//-------------------------------------------------------------------------
		
		oDebito:= COMPDEBITO():New() 	//Cria Objeto da Classe COMPDEBITO
		oDebito:SetConsol(CCONSOL)
		oDebito:SetDtIni(MV_PAR01)   	//Passa data de referência
		oDebito:LoadDebito(NAOCUMULAT)	//Buscar débitos Não Cumulativos
				
		aAdd( aLoad, { nX++, { '',,} } )
		aAdd( aLoad, { nX++, { Space(35)+STR0059,,} } )//'-- regime não cumulativo --'
		aAdd( aLoad, { nX++, { '',,} } )	
		aAdd( aLoad, { nX++, { STR0061,oDebito:GetTotCon(PIS)		, oDebito:GetTotCon(COF)		} })//02-'Valor Total da Contribuição'
		aAdd( aLoad, { nX++, { STR0062,oDebito:GetAjuAcre(PIS)		, oDebito:GetAjuAcre(COF)	} })//03-'Valor Total dos Ajustes de Acréscimos'
		aadd(aArray,{cTabela,nx,STR0062,'1'})
		aAdd( aLoad, { nX++, { STR0063,oDebito:GetAjuRed(PIS)		, oDebito:GetAjuRed(COF)		} })//04-'Valor Total dos Ajustes de Redução'
		aadd(aArray,{cTabela,nx,STR0063,'2'})
		aAdd( aLoad, { nX++, { STR0064 + Iif(lNewProc,' +' ,''),oDebito:GetDif(PIS)			, oDebito:GetDif(COF)			} })//05-'Valor da Contribuição Diferir no Período'
		IF lNewProc
			aadd(aArray,{cTabela,nx,STR0064,'13'})
		EndIF
		aAdd( aLoad, { nX++, { STR0065 + Iif(lNewProc,' +' ,''),oDebito:GetDifAnt(PIS)		, oDebito:GetDifAnt(COF)		} })//06-'Valor Total da Contribuição Diferida em Períodos Anteriores'
		IF lNewProc
			aadd(aArray,{cTabela,nx,STR0065,'14'})
		EndIF
		aAdd( aLoad, { nX++, { STR0066,oDebito:GetValDisp(PIS)		, oDebito:GetValDisp(COF)	} })//07-'Valor Total da COntribuição Apurada'
		aadd(aArray,{cTabela,nx,STR0062,'10'})						
		
		If Year(MV_PAR01) >= 2019 .AND. lF2Z
			aAdd( aLoad, { nX++, { "Ajustes de Acréscimo de Base de Cálculo + ", oDebito:GetAjBsAcr(PIS) , oDebito:GetAjBsAcr(COF)} } )//'Ajustes de Acréscimo de Base de Cálculo
			aadd(aArray,{cTabela,nx,"Ajustes de Acréscimo de Base de Cálculo",'18'})
			aAdd( aLoad, { nX++, { "Ajustes de Redução de Base de Cálculo + ",   oDebito:GetAjBsRed(PIS) , oDebito:GetAjBsRed(COF)} } )//'Ajustes de Redução de Base de Cálculo
			aadd(aArray,{cTabela,nx,"Ajustes de Redução de Base de Cálculo",'19'})
		EndIF
		aAdd( aLoad, { nX++, { '',,} } )		
		
		oDebito:=	nil		
		oDebito:= COMPDEBITO():New() 	//Cria Objeto da Classe COMPDEBITO
		oDebito:SetConsol(CCONSOL)
		oDebito:SetDtIni(MV_PAR01)   	//Passa data de referência
		oDebito:LoadDebito(CUMULAT)		//Buscar débitos Cumulativos		
		
		aAdd( aLoad, { nX++, { Space(35)+STR0060,,} } )//'-- regime cumulativo --'
		aAdd( aLoad, { nX++, { '',,} } )
		aAdd( aLoad, { nX++, { STR0067, oDebito:GetTotCon(PIS)	, oDebito:GetTotCon(COF)		} })//'Valor Total da Contribuição'
		aAdd( aLoad, { nX++, { STR0068, oDebito:GetAjuAcre(PIS)	, oDebito:GetAjuAcre(COF)	} })//'Valor Total dos Ajustes de Acréscimo'
		aadd(aArray,{cTabela,nx,STR0068,'3'})
		aAdd( aLoad, { nX++, { STR0069, oDebito:GetAjuRed(PIS)	, oDebito:GetAjuRed(COF)		} })//'Valor Total de Ajustes de Redução'
		aadd(aArray,{cTabela,nx,STR0069,'4'})
		aAdd( aLoad, { nX++, { STR0070 + Iif(lNewProc,' +' ,''), oDebito:GetDif(PIS)		, oDebito:GetDif(COF)			} })//'Valor da Contribuição Diferir no Período'
		IF lNewProc
			aadd(aArray,{cTabela,nx,STR0064,'15'})
		EndIF
		aAdd( aLoad, { nX++, { STR0071 + Iif(lNewProc,' +' ,''), oDebito:GetDifAnt(PIS)	, oDebito:GetDifAnt(COF)		} })//'Valor Total da Contribuição Diferida em Períodos Anteriores'
		IF lNewProc
			aadd(aArray,{cTabela,nx,STR0064,'16'})
		EndIF
		aAdd( aLoad, { nX++, { STR0072, oDebito:GetValDisp(PIS)	, oDebito:GetValDisp(COF)	} })//'Valor Total da COntribuição Apurada'
		aadd(aArray,{cTabela,nx,STR0062,'11'})				
		
		If Year(MV_PAR01) >= 2019 .AND. lF2Z
			aAdd( aLoad, { nX++, { "Ajustes de Acréscimo de Base de Cálculo + ", oDebito:GetAjBsAcr(PIS)  , oDebito:GetAjBsAcr(COF)} } )//'Ajustes de Acréscimo de Base de Cálculo
			aadd(aArray,{cTabela,nx,"Ajustes de Redução de Base de Cálculo",'20'})
			aAdd( aLoad, { nX++, { "Ajustes de Redução de Base de Cálculo + ",   oDebito:GetAjBsRed(PIS) , oDebito:GetAjBsRed(COF)} } )//'Ajustes de Redução de Base de Cálculo
			aadd(aArray,{cTabela,nx,"Ajustes de Redução de Base de Cálculo",'21'})
		EndIF

		aAdd( aLoad, { nX++, { '',,} } ) 
		oDebito:=	nil
		
	Case cTabela == 'ABA4'	
		//---------------------------------------------------------------------------------
		// Insere informações na quarta tela da apuração - Composição dos créditos
		//---------------------------------------------------------------------------------

		//Cria Objeto de saídas por CST
		oCredito 	:= CMPCREDITO():New()	
		oCredito:SetConsol(CCONSOL)
		//Passa período de referência		
		oCredito:SetDtIni(MV_PAR01)
		
		//Carrega valores de saídas por CST
		oCredito:LoadCredit()	

		aAdd( aLoad, { nX++,  { '',,} } )	
		aAdd( aLoad, { nX++, { STR0073, oCredito:GetBseApur(PIS)		, oCredito:GetBseApur(COF)	} } )//'Base de Cálculo Pelas Entradas'
		aAdd( aLoad, { nX++, { STR0074, oCredito:GetCrdAtfD(PIS)		, oCredito:GetCrdAtfD(COF)	} } )//'Base de Cálculo Ativo Fixo - Depreciação'
		aAdd( aLoad, { nX++, { STR0075, oCredito:GetCrdAtfA(PIS)		, oCredito:GetCrdAtfA(COF)	} } )//'Base de Cálculo Ativo Fixo - Aquisição'
		aAdd( aLoad, { nX++, { STR0076, oCredito:GetCrdPres(PIS)		, oCredito:GetCrdPres(COF)	} } )//'Base de Cálculo Crédito Presumido'
		aAdd( aLoad, { nX++, { STR0077, oCredito:GeTTotBase(PIS)		, oCredito:GeTTotBase(COF)	} } )//'Total da Base de Cálculo do Período'
		aAdd( aLoad, { nX++, { STR0078, oCredito:GeTBasApur(PIS)		, oCredito:GeTBasApur(COF)	} } )//'Total da Base de Cálculo Apurada'

		aAdd( aLoad, {nX++,  { '',,} } )

		aAdd( aLoad, { nX++, { STR0151 , oCredito:GetCredApu(PIS)		, oCredito:GetCredApu(COF)	} } )//'Total Do Crédito apurado
		aAdd( aLoad, { nX++, { STR0079, oCredito:GeTAjuAcre(PIS)		, oCredito:GeTAjuAcre(COF)	} } )//'Total de Ajuste de Acréscimo'
		aadd(aArray,{cTabela,nx,STR0079,'5'})
		aAdd( aLoad, { nX++, { STR0080, oCredito:GeTAjuRed(PIS)			, oCredito:GeTAjuRed(COF)	} } )//'Total de Ajuste de Redução'
		aadd(aArray,{cTabela,nx,STR0080,'6'})
		aAdd( aLoad, { nX++, { STR0081 + Iif(lNewProc,' +' ,''), oCredito:GeTVlDif(PIS)		, oCredito:GeTVlDif(COF)		} } )//'Valor Total do Crédito Diferido no Período'
		IF lNewProc
			aadd(aArray,{cTabela,nx,STR0081,'17'})
		EndIF
		aAdd( aLoad, { nX++, { STR0082 + ' + ', oCredito:GeTVlDisp(PIS)		, oCredito:GeTVlDisp(COF)	} } )//'Valor Total do Crédito Disponível no Período'
		aadd(aArray,{cTabela,nx,STR0062,'12'})		
		aAdd( aLoad, { nX++, { '',,} } )
		oCredito:=	nil
		
	Case cTabela == 'ABA5'	
	
		//---------------------------------
		// CRIA OBJETO DE PIS PARA APURAÇÃO
		//---------------------------------		
		//Cria objeto da apuração para o PIS
		oApurPIS	:= APURPISCOF():New()
		oApurPIS:SetConsol(CCONSOL)	
		//Passa data inicial
		oApurPIS:SetRegime(MV_PAR06)
		oApurPIS:SetDtIni(MV_PAR01)
		oApurPIS:SetGrvDup(iif(LCARREGA,'','1'))
//		oApurPIS:SetGrvDup(iif(LCARREGA,'','1'))
		//Apura o PIS do período
		//Carrega as informações no objeto
		oApurPIS:setPCrdFut(!MV_PAR06 == 3) //Somente irá processsar valores de créditos para próximo período se não for regime de caixa
		oApurPIS:setSeqTrib(cSeqTrib)
		oApurPIS:LoadApurPC(PIS)

		//------------------------------------
		// CRIA OBJETO DA COFINS PARA APURAÇÃO
		//------------------------------------
		//Cria objeto da apuração para a COFINS
		oApurCof	:= APURPISCOF():New()	
		oApurCof:SetConsol(CCONSOL)
		//Passa data inicial
		oApurCof:SetRegime(MV_PAR06)
		oApurCof:SetDtIni(MV_PAR01)
		oApurCof:SetGrvDup(iif(LCARREGA,'','1'))
//		oApurCof:SetGrvDup(iif(LCARREGA,'','1'))
		//Apura o PIS do período		
		//Carrega as informações no objeto
		oApurCof:setPCrdFut(!MV_PAR06 == 3) //Somente irá processsar valores de créditos para próximo período se não for regime de caixa		
		oApurCof:setSeqTrib(oApurPIS:getSeqTrib())
		oApurCof:LoadApurPC(COF)
						
					
		//------------------------------------------------------------------------------------------
		// Insere informações na quinta tela (parte superior)da apuração - Apuração de PIS e COFINS
		//------------------------------------------------------------------------------------------
		aAdd( aLoad, { nX++,  { '',,} } )	
		aAdd( aLoad, { nX++, { Space(35)+STR0059,,} } )//'-- Regime não Cumulativo --'		
		aAdd( aLoad, { nX++,  { '',,}})
		aAdd( aLoad, { nX++, { STR0083, oApurPIS:GetVlContr(NAOCUMULAT)		, oApurCof:GetVlContr(NAOCUMULAT)} } )//'Valor Total da Contribuição'
		aAdd( aLoad, { nX++, { STR0084, oApurPIS:GetCrdAnt(NAOCUMULAT)		, oApurCof:GetCrdAnt(NAOCUMULAT)} } )//'Valor do Crédito Descontado - Período Anterior'
		aAdd( aLoad, { nX++, { STR0085, oApurPIS:GetCrdAtu(NAOCUMULAT)		, oApurCof:GetCrdAtu(NAOCUMULAT)} } )//'Valor do Crédito Descontado - Período Atual'
		aAdd( aLoad, { nX++, { STR0086, oApurPIS:GetConDev(NAOCUMULAT)		, oApurCof:GetConDev(NAOCUMULAT)} } )//'Valor da Contribuição Devida'
		aAdd( aLoad, { nX++, { STR0087, oApurPIS:GetRetAnt(NAOCUMULAT)		, oApurCof:GetRetAnt(NAOCUMULAT)} } )//'Valor Retido na Fonte - Período Anterior'
		aAdd( aLoad, { nX++, { STR0088, oApurPIS:GetRetAtu(NAOCUMULAT)		, oApurCof:GetRetAtu(NAOCUMULAT)} } )//'Valor Retido na Fonte - Período Atual'
		aAdd( aLoad, { nX++, { STR0089, oApurPIS:GetOutDed(NAOCUMULAT)		, oApurCof:GetOutDed(NAOCUMULAT)} } )//'Outras Deduções no Período'
		aAdd( aLoad, { nX++, { STR0090, oApurPIS:GetVlRecol(NAOCUMULAT)		, oApurCof:GetVlRecol(NAOCUMULAT)} } )//'Valor da Contribuição Não Cumulativa a Recolher'
		aAdd( aLoad, { nX++,  { '',,} } )
		aAdd( aLoad, { nX++, { STR0091 + ' + ', oApurPIS:GetSldCrd(NAOCUMULAT)		, oApurCof:GetSldCrd(NAOCUMULAT)} } )//'Saldo de Crédito a Transportar para próximo período'
		aadd(aArray,{cTabela,nx,STR0062,'7'})
		aAdd( aLoad, { nX++, { STR0092 + ' + ', oApurPIS:GetSldRet(NAOCUMULAT)		, oApurCof:GetSldRet(NAOCUMULAT)} } )//'Saldo de Retenção a Transportar para próximo período'
		aadd(aArray,{cTabela,nx,STR0062,'8'})		
		aAdd( aLoad, { nX++,  { '',,} } )	
		aAdd( aLoad, { nX++, { Space(35)+STR0060,,} } )//'-- Regime  Cumulativo --'
		aAdd( aLoad, { nX++,  { '',,} } )
		aAdd( aLoad, { nX++, { STR0093, oApurPIS:GetVlContr(CUMULAT)		, oApurCof:GetVlContr(CUMULAT)} } )//'Valor Total da Contribuição'		
		aAdd( aLoad, { nX++, { STR0094, oApurPIS:GetRetAnt(CUMULAT)			, oApurCof:GetRetAnt(CUMULAT)} } )//'Valor Retido na Fonte - Período Anterior'
		aAdd( aLoad, { nX++, { STR0095, oApurPIS:GetRetAtu(CUMULAT)			, oApurCof:GetRetAtu(CUMULAT)} } )//'Valor Retido na Fonte - Período Atual'
		aAdd( aLoad, { nX++, { STR0096, oApurPIS:GetOutDed(CUMULAT)			, oApurCof:GetOutDed(CUMULAT)} } )//'Outras Deduções no Período'
		aAdd( aLoad, { nX++, { STR0097, oApurPIS:GetVlRecol(CUMULAT)		, oApurCof:GetVlRecol(CUMULAT)} } )//'Valor da Contribuição Não Cumulativa a Recolher'		
		aAdd( aLoad, { nX++,  { '',,} } )
		aAdd( aLoad, { nX++, { STR0098 + ' + ', oApurPIS:GetSldRet(CUMULAT)			, oApurCof:GetSldRet(CUMULAT)} } )//'Saldo de Retenção a Transportar para próximo período'
		aadd(aArray,{cTabela,nx,STR0062,'9'})
		aAdd( aLoad, { nX++,  { '',,} } )	
	
	Case cTabela == 'ABA5A'
		
		
		//------------------------------------
		// CRIA OBJETO DA COFINS PARA APURAÇÃO
		//------------------------------------
		//Cria objeto da apuração para a COFINS
		oGuias	:= APURPISCOF():New()
		oGuias:SetConsol(CCONSOL)	
		//Passa data inicial
		oGuias:SetRegime(MV_PAR06)
		oGuias:SetDtIni(MV_PAR01)			
		//Carrega as informações no objeto
		aGuias	:= oGuias:LoadRecolh()
				
		//------------------------------------------------------------------------------------------
		// Insere informações na quinta tela (parte inferior)da apuração - Apuração de PIS e COFINS
		//------------------------------------------------------------------------------------------
		aAdd( aLoad, { nX++,  { '',,,} } )
		aAdd( aLoad, { nX++,  {Space(15)+ STR0099,,,} } )//'-- Recolhimento dos Tributos --'
		aAdd( aLoad, { nX++,  { '',,,} } )
		
		For nCont	:= 1 to Len(aGuias)
			If aGuias[nCont][1] == '1'
				aAdd( aLoad, { nX++, { '1- ' + Iif(Empty(aGuias[nCont][5]),STR0101 , aGuias[nCont][5]) , aGuias[nCont][2], aGuias[nCont][3],aGuias[nCont][4]} } )//'PIS - Não Cumulativo'
			ElseIf aGuias[nCont][1] == '2'
				aAdd( aLoad, { nX++, { '2- ' + Iif(Empty(aGuias[nCont][5]),STR0100 , aGuias[nCont][5]), aGuias[nCont][2], aGuias[nCont][3],aGuias[nCont][4]} } )//'PIS - Cumulativo'			
			ElseIf aGuias[nCont][1] == '3'
				aAdd( aLoad, { nX++, { '3- ' + Iif(Empty(aGuias[nCont][5]),STR0103 , aGuias[nCont][5]), aGuias[nCont][2], aGuias[nCont][3],aGuias[nCont][4]} } )//'COFINS - Não Cumulativo'
			ElseIf aGuias[nCont][1] == '4'
				aAdd( aLoad, { nX++, { '4- ' + Iif(Empty(aGuias[nCont][5]),STR0102 , aGuias[nCont][5]), aGuias[nCont][2], aGuias[nCont][3],aGuias[nCont][4]} } )//'COFINS - Cumulativo'			
			ElseIf Len(aGuias[nCont]) >= 7 .AND. aGuias[nCont][7]
				//As informações de CPRB já foram gravadas na CL3, serão somente carregadas
				aAdd( aLoad, { nX++, { aGuias[nCont][1] + '- ' +  aGuias[nCont][5], aGuias[nCont][2], aGuias[nCont][3],aGuias[nCont][4]} } )//'COFINS - Cumulativo'
				lProcCPRB	:= .T.				
			Else
				//Aqui serão adicionadas os códigos de receitas conforme regra cadastrada pelo usuário. As linhas de 1 a 4 são tratamento legado, a partir da 4 são conforme regras do usuário
				aAdd( aLoad, { nX++, { aGuias[nCont][1] + '- ' +  aGuias[nCont][5], aGuias[nCont][2], aGuias[nCont][3],aGuias[nCont][4]} } )//'COFINS - Cumulativo'
			EndIF			
		Next nCont
		
		IF !lProcCPRB
			//Cria Objeto da CPRB
			oCPRB 	:= CPRBEFD():New()	
			oCPRB:SetConsol(CCONSOL)

			//Passa período de referência		
			oCPRB:SetDtIni(MV_PAR01)
			
			//Carrega os valores já processados de CPRB
			oCPRB:LoadCPRB()
					
			//-----------------------------------------------------
			// Insere informações na quinta tela (parte inferior) da apuração - CPRB
			//-----------------------------------------------------
			if oCPRB:GetCPRBPag() > 0
				
				aDados := oCPRB:GetaCodRec()
				
				for i := 1 to len(aDados)
				
					aAdd( aLoad, { nX++, { alltrim(str(nCont)) + '- CPRB' , aDados[i][1],  aDados[i][5] , CTOD("  /  /    ") } } )//' CRB '
					
					nCont += 1
					
				next
				
			endif
		EndIF
		
		aAdd( aLoad, { nX++,  { '',,,} } )		
	
	Case cTabela == 'ABA6'


		oPisFolha	:= APURPISCOF():New()
		oPisFolha:SetConsol(CCONSOL)
		oPisFolha:SetRegime(MV_PAR06)
		oPisFolha:SetDtIni(MV_PAR01)
		oPisFolha:LoadPisFol()
		//----------------------------------------------------------------------
		// Insere informações na sexta tela da apuração - PIS - Folha de salário
		//----------------------------------------------------------------------
		aAdd( aLoad, { nX++,  { '',} } )	
		aAdd( aLoad, { nX++, { STR0104, oPisFolha:GetTotFolh()} } )//'Valor Total da Folha de Salário'	
		aAdd( aLoad, { nX++, { STR0105, oPisFolha:GetExlFolh()} } )//'Valor Total da Exclusão da Base de Cálculo'		
		aAdd( aLoad, { nX++, { STR0106, oPisFolha:GetBCFolha()} } )//'Valor Total da Base de Cálculo'		
		aAdd( aLoad, { nX++, { STR0107, oPisFolha:GetPisFolh()} } )//'Valor de PIS a Recolher'
		aAdd( aLoad, { nX++,  { '',} } )
	
	Case cTabela == 'ABA7'

		//Cria Objeto da CPRB
		oCPRB 	:= CPRBEFD():New()	
		oCPRB:SetConsol(CCONSOL)
		
		//Passa período de referência		
		oCPRB:SetDtIni(MV_PAR01)
		
		//Carrega os valores já processados de CPRB
		oCPRB:LoadCPRB()

		//-----------------------------------------------------
		// Insere informações na sétima tela da apuração - CPRB
		//-----------------------------------------------------
		aAdd( aLoad, { nX++,  { '',} } )	

		aAdd( aLoad, { nX++, { 'Total da Receita Bruta', oCPRB:GetVlBrut()} } )
		aAdd( aLoad, { nX++, { 'Total da Receita incidente a CPRB', oCPRB:GetVlAtiv()} } )		
		aAdd( aLoad, { nX++, { 'Total das Exclusões das Receitas incidente a CPRB', oCPRB:GetVlExcl()} } )		
		aAdd( aLoad, { nX++, { 'Total da Base de Cálculo', oCPRB:GetBase()} } )	
		aAdd( aLoad, { nX++,  { '',} } )
		aAdd( aLoad, { nX++, { STR0108, oCPRB:GetTotCon()} } )//'Valor Total da COntribuição Apurada'	
		aAdd( aLoad, { nX++, { STR0109, oCPRB:GetAjusRed()} } )//'Valor Total dos Ajustes de Redução'		
		aAdd( aLoad, { nX++, { STR0110, oCPRB:GetAjusAcr()} } )//'Valor Total dos Ajustes de Acréscimo'		
		aAdd( aLoad, { nX++, { STR0111, oCPRB:GetCPRBPag()} } )//'Valor Total da Contribuição a Recolher'
		aAdd( aLoad, { nX++,  { '',} } )
EndCase


Return( aLoad )

Static Function DescrReg(cCodReg)

local cRet	:= 'Regime:'

IF cCodReg == 1
	cRet+= STR0138//'Não Cumulativo - '
ElseIF cCodReg == 2 
	cRet+= STR0139//'Cumulativo - '
ElseIF cCodReg == 3
	cRet+= STR0140//'Caixa - '
ElseIF cCodReg == 4
	cRet+= STR0141//'Cumulativo/Não Cumulativo - '
EndIF

Return cRet


Function ISA002CST( oModelGrid, nLinha, cAcao, cCampo )

Local	oModel		:=	FWModelActive()
Local	oModelABA	
Local cAba	:= SUBSTR(cCampo,1,4)
Local cCst	:= ''
Local cFiltroBrw	:= ''

cFiltroBrw :='CL0_FILIAL == "' + xFilial('CL0') + '"'
cFiltroBrw	+= ' .AND.  DTOS(CL0_PER) >="' + DTOS(MV_PAR01)  + '" .and.  DTOS(CL0_PER) <="' + DTOS(MV_PAR02) + '"'
cFiltroBrw	+= ' .AND.  CL0_CONSOL == "' + CCONSOL + '"'

If cAba == 'ABA1'
	oModelABA	:=	oModel:GetModel('MODEL_ABA1')
	cCst		:= SubStr(oModelABA:GetValue('ABA1_CMP1'),1,2)	
ElseIF cAba == 'ABA2'
	oModelABA	:=	oModel:GetModel('MODEL_ABA2')
	cCst		:= SubStr(oModelABA:GetValue('ABA2_CMP1'),1,2)	
EndIF

IF cCst $'01/02/03/04/05/06/07/08/09/49/50/51/52/53/54/55/56/60/61/62/63/64/65/66/67/70/71/72/73/74/75/98'

	cFiltroBrw	+= ' .and. CL0_CST == "' + cCst + '"'
	
	VisualGen(cFiltroBrw,'Visualização dos totais por CST','CL0')
EndIF


Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA01LPRE
 
Função que faz a pre validação da linha do grid, irá chamar a tela
para exibir o detalhamento dos valores considerados para compor
os ajustes.
			
@author Erick G. Dias
@since 04/07/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function ASA01LPRE( oModelGrid, nLinha, cAcao, cCampo,aArray )

Local lAlteracao	:= .F.
Local lRet		:= .F.
Local cAba		:= SubStr(cCampo,1,4)
Local cCpo		:= SubStr(cCampo,6,5)
Local cPisCOf		:= ''
Local cDebCred	:= ''
local cTexto		:= ''
Local cFiltroBrw	:= ''
Local cAlias		:= ''
Local cDescr		:= STR0142//'Ajustes '
Local cFiltroAux	:= DTOS(MV_PAR01)
Local nPos		:= 0
Local nVal		:= 0
Local oBrowse
Local oCompCred
Local oDebito
Local aArea	:= {}
Local	oModel		:=	FWModelActive()

IF ('CMP2' $ cCpo .OR. 'CMP3' $ cCpo )  
	nPos:=aScan(aArray,{|aX| aX[1]==cAba .AND. aX[2] ==nLinha})
	If nPos > 0
		lAlteracao	:=Iif (aArray[nPos][4] $ '1/2/3/4/5/6' ,.T. ,.F. )
		CKZN	:= aArray[nPos][4]
		If aArray[nPos][4] =='1'
			CKZR :=	 NAOCUMULAT
			cDescr += STR0143//' - Acréscimo Débito Não Cumulativo'
			cDebCred	:= '1' 		
		ElseIf aArray[nPos][4] =='2'
			CKZR :=	 NAOCUMULAT
			cDescr += STR0144//' - Redução Débito Não Cumulativo'
			cDebCred	:= '1'						
		ElseIf aArray[nPos][4] =='3'			
			CKZR :=	 CUMULAT
			cDescr += STR0145//' - Acréscimo Débito Cumulativo'
			cDebCred	:= '1'						
		ElseIf aArray[nPos][4] =='4'
			CKZR :=	 CUMULAT
			cDescr += STR0146//' - Redução Débito Cumulativo'
			cDebCred	:= '1'						
		ElseIf aArray[nPos][4] =='5'		
			CKZR :=	 NAOCUMULAT
			cDescr += STR0147//' - Acréscimo Crédito '
			cDebCred	:= '2'						
		ElseIf aArray[nPos][4] =='6'
			CKZR :=	 NAOCUMULAT
			cDescr += STR0148//' - Redução Crédito '
			cDebCred	:= '2'
		EndIF

		IF 'CMP2' $ cCpo
			CKZT := '1'	
			cDescr += STR0149//' - PIS'
			cFiltroAux+='1'
		ElseIF 'CMP3' $ cCpo
			CKZT := '2'
			cDescr += STR0150//' - COFINS'
			cFiltroAux+='2'		
		EndIF
		CKZDC	:= cDebCred
		CKZD:= cDescr
		cFiltroAux+=CKZR

		If cAcao =='CANSETVALUE' .AND. !lAlteracao //Se usuário clicou em linha que não é para alteração irá somente visualizar
			Do case
				Case aArray[nPos][4] =='7' // Saldo de crédito para próximo período	
					If CKZT == '1'
						cFiltroBrw :='CCY_FILIAL == "' + xFilial('CCY') + '"'
						cFiltroBrw	+= ' .AND. CCY_PERIOD =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" '												
						//Os saldos com ressarcimento ou compensação total também precisam ser listados na apuração
						cFiltroBrw	+= ' .AND. (CCY_TOTCRD >0 .OR. CCY_CREDUT >0 .OR. CCY_COMP >0 .OR. CCY_RESSA >0 .OR. CCY_COANTE >0 .OR. CCY_REANTE >0 ) ' 
						If CCONSOL == '1'
							cFiltroBrw	+= ' .AND. CCY_CONSOL =="' +CCONSOL + '"  '
						Else
							cFiltroBrw	+= ' .AND. CCY_CONSOL <>"1"  '
						EndIF												
						cDescr	:= STR0152 //'Visualização do saldo de crédito de PIS'
						cAlias	:= 'CCY'
		
					ElseIF CKZT == '2'
						cFiltroBrw :='CCW_FILIAL == "' + xFilial('CCW') + '"'
						cFiltroBrw	+= ' .AND. CCW_PERIOD =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" '		
						//Os saldos com ressarcimento ou compensação total também precisam ser listados na apuração
						cFiltroBrw	+= ' .AND. (CCW_TOTCRD >0 .OR. CCW_CREDUT >0 .OR. CCW_COMP >0 .OR. CCW_RESSA >0 .OR. CCW_COANTE >0 .OR. CCW_REANTE >0 ) '				
						If CCONSOL == '1'
							cFiltroBrw	+= ' .AND. CCW_CONSOL =="' +CCONSOL + '"  '
						Else
							cFiltroBrw	+= ' .AND. CCW_CONSOL <>"1"  '
						EndIF							
						
						cDescr	:= STR0153// 'Visualização do saldo de crédito da COFINS'
						cAlias	:= 'CCW'
																
					EndIF
				Case aArray[nPos][4] =='8' // Saldo de retenção Não Cumulativo para próximo período
					If CKZT == '1'
						cFiltroBrw :='FV_FILIAL == "' + xFilial('SFV') + '"'
						cFiltroBrw	+= '.AND. FV_PER =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" .and.  FV_TPREG == "1"'					
						If CCONSOL == '1'
							cFiltroBrw	+= ' .AND. FV_CONSOL =="' +CCONSOL + '"  '
						Else
							cFiltroBrw	+= ' .AND. FV_CONSOL <>"1"  '
						EndIF							
						
						cDescr	:= STR0154//'Visualização do saldo de retenção Cumulativa de PIS'
						cAlias	:= 'SFV'
																	
					ElseIF CKZT == '2'
						cFiltroBrw :='FW_FILIAL == "' + xFilial('SFW') + '"'
						cFiltroBrw	+= '.AND. FW_PER =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" .and.  FW_TPREG == "1"'
						If CCONSOL == '1'
							cFiltroBrw	+= ' .AND. FW_CONSOL =="' +CCONSOL + '"  '
						Else
							cFiltroBrw	+= ' .AND. FW_CONSOL <>"1"  '
						EndIF							
						
						cDescr	:= STR0155//'Visualização do saldo de retenção Cumulativa da COFINS'
						cAlias	:= 'SFW'							
					EndIF
				
				Case aArray[nPos][4] =='9' // Saldo de retenção Cumulativo para próximo período
					If CKZT == '1'
						cFiltroBrw :='FV_FILIAL == "' + xFilial('SFV') + '"'
						cFiltroBrw	+= '.AND. FV_PER =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" .and.  FV_TPREG == "2"'
						If CCONSOL == '1'
							cFiltroBrw	+= ' .AND. FV_CONSOL =="' +CCONSOL + '"  '
						Else
							cFiltroBrw	+= ' .AND. FV_CONSOL <>"1"  '
						EndIF							
						
						cDescr	:= STR0156//'Visualização do saldo de retenção Não Cumulativa de PIS'
						cAlias	:= 'SFV'											
					ElseIF CKZT == '2'
						cFiltroBrw :='FW_FILIAL == "' + xFilial('SFW') + '"'
						cFiltroBrw	+= '.AND. FW_PER =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" .and.  FW_TPREG == "2"'
						If CCONSOL == '1'
							cFiltroBrw	+= ' .AND. FW_CONSOL =="' +CCONSOL + '"  '
						Else
							cFiltroBrw	+= ' .AND. FW_CONSOL <>"1"  '
						EndIF						
						
						cDescr	:= STR0157//'Visualização do saldo de retenção  Cumulativa da COFINS'
						cAlias	:= 'SFW'																	
					EndIF
					
				Case aArray[nPos][4] =='10' // Débitos Não Cumulativos

					cFiltroBrw :='CKS_FILIAL == "' + xFilial('CKS') + '"'
					cFiltroBrw	+= ' .AND. DTOS(CKS_PER) >="' + DTOS(MV_PAR01)  + '" .and.  DTOS(CKS_PER) <="' + DTOS(MV_PAR02) + '"'
					cFiltroBrw	+= ' .AND. CKS_CONSOL == "' + CCONSOL + '"'
					cFiltroBrw	+= ' .AND. SUBSTR(CKS_CHV,10,1) == "1"'
					If CKZT == '1' 
						cFiltroBrw	+= ' .AND. CKS_TRIB == "1"'
						cDescr	:= STR0158//'Visualização dos débitos de PIS Não Cumulativos disponíveis'
					ElseIf CKZT == '2'
						cFiltroBrw	+= ' .AND. CKS_TRIB == "2"'
						cDescr	:= STR0159//'Visualização dos débitos da COFINS Não Cumulativos disponíveis'					
					EndIF
					cAlias	:= 'CKS'
				Case aArray[nPos][4] =='11' // Débitos Cumulativos	 			

					cFiltroBrw :='CKS_FILIAL == "' + xFilial('CKS') + '"' 
					cFiltroBrw	+= ' .AND.  DTOS(CKS_PER) >="' + DTOS(MV_PAR01)  + '" .and.  DTOS(CKS_PER) <="' + DTOS(MV_PAR02) + '"'
					cFiltroBrw	+= ' .AND. CKS_CONSOL == "' + CCONSOL + '"'
					cFiltroBrw	+= ' .AND. SUBSTR(CKS_CHV,10,1) == "2"'
					If CKZT == '1' 
						cFiltroBrw	+= ' .AND. CKS_TRIB == "1"'
						cDescr	:= STR0160//'Visualização dos débitos de PIS Cumulativos disponíveis'
					ElseIf CKZT == '2'
						cFiltroBrw	+= ' .AND. CKS_TRIB == "2"'
						cDescr	:=STR0161//'Visualização dos débitos da COFINS Cumulativos disponíveis'					
					EndIF
					cAlias	:= 'CKS'

				Case aArray[nPos][4] =='12' // Detalhamento dos Créditos
				
					cFiltroBrw :='CL8_FILIAL == "' + xFilial('CL8') + '"'
					cFiltroBrw	+= ' .AND.  DTOS(CL8_PER) >="' + DTOS(MV_PAR01)  + '" .and. DTOS(CL8_PER) <="' + DTOS(MV_PAR02) + '"'
					cFiltroBrw	+= ' .AND.  CL8_CONSOL == "' + CCONSOL + '"'

					If CKZT == '1' 
						cFiltroBrw	+= ' .AND. CL8_TRIB == "1"'
						cDescr	:= STR0162//'Visualização dos Créditos de PIS disponíveis'
					ElseIf CKZT == '2'
						cFiltroBrw	+= ' .AND. CL8_TRIB == "2"'
						cDescr	:= STR0163//'Visualização dos Créditos da COFINS disponíveis'					
					EndIF
					cAlias	:= 'CL8'				
									
				Case aArray[nPos][4] $'13/15' // Diferimento do período dos débitos
					cFiltroBrw :='CFA_FILIAL == "' + xFilial('CFA') + '"'
					cFiltroBrw	+= ' .AND.  CFA_PERAPU ="' + Substr(DTOS(mv_par01),5,2)+Substr(DTOS(mv_par01),1,4)  + '" '
					cFiltroBrw	+= ' .AND.  CFA_CONSOL == "' + CCONSOL + '"'
					
					IF aArray[nPos][4] == '13' //Débitos Não Cumulativos
						cFiltroBrw	+= ' .AND.  CFA_CODCON $ "01/02/03/04/71" '
					ElseIF aArray[nPos][4] == '15' //Débitos Cumulativos
						cFiltroBrw	+= ' .AND.  CFA_CODCON $ "51/52/53/54/72" '
					EndIF					
					
					If CKZT == '1' 
						cFiltroBrw	+= ' .AND. CFA_TPCON == "PIS"'
						cDescr	:= 'Visualização dos débitos diferidos de PIS do período'
					ElseIf CKZT == '2'
						cFiltroBrw	+= ' .AND. CFA_TPCON == "COF"'
						cDescr	:= 'Visualização dos débitos diferidos de COFINS do período'					
					EndIF
					
					cFiltroBrw	+= ' .AND. CFA_CONDIF > 0'					
					
					cAlias	:= 'CFA'			
					
				Case aArray[nPos][4] $'14/16' // Diferimento débitos de período anterior				
					cFiltroBrw :='CFB_FILIAL == "' + xFilial('CFB') + '"'
					cFiltroBrw	+= ' .AND.  CFB_PERAPU ="' + Substr(DTOS(mv_par01),5,2)+Substr(DTOS(mv_par01),1,4)  + '" '
					cFiltroBrw	+= ' .AND.  CFB_CONSOL == "' + CCONSOL + '"'
					
					IF aArray[nPos][4] == '14'
						cFiltroBrw	+= ' .AND.  CFB_CODCON $ "01/02/03/04/71" '
					ElseIF aArray[nPos][4] == '16'
						cFiltroBrw	+= ' .AND.  CFB_CODCON $ "51/52/53/54/72" '					
					EndIF
					
					If CKZT == '1' 
						cFiltroBrw	+= ' .AND. CFB_TPCON == "PIS"'
						cDescr	:= 'Visualização dos débitos diferidos de período anteriores de PIS '
					ElseIf CKZT == '2'
						cFiltroBrw	+= ' .AND. CFB_TPCON == "COF"'
						cDescr	:= 'Visualização dos débitos diferidos de período anteriores de COFINS '					
					EndIF
					cFiltroBrw	+= ' .AND. (CFB_CONREC - CFB_CREDES) > 0'					
					cAlias	:= 'CFB'


				Case aArray[nPos][4] == '17' // Créditos diferidos no período
					cFiltroBrw :='CFA_FILIAL == "' + xFilial('CFA') + '"'
					cFiltroBrw	+= ' .AND.  CFA_PERAPU ="' + Substr(DTOS(mv_par01),5,2)+Substr(DTOS(mv_par01),1,4)  + '" '
					cFiltroBrw	+= ' .AND.  CFA_CONSOL == "' + CCONSOL + '"'										
					
					If CKZT == '1' 
						cFiltroBrw	+= ' .AND. CFA_TPCON == "PIS"'
						cDescr	:= 'Visualização dos créditos diferidos de PIS do período'
					ElseIf CKZT == '2'
						cFiltroBrw	+= ' .AND. CFA_TPCON == "COF"'
						cDescr	:= 'Visualização dos créditos diferidos de COFINS do período'					
					EndIF
					cFiltroBrw	+= ' .AND. CFA_CREDIF > 0'
					
					cAlias	:= 'CFA'	
				
				Case aArray[nPos][4] $ '18/19/20/21' // Ajustes de base de cálculo
					
					cFiltroBrw  :='F2Z_FILIAL == "' + xFilial('F2Z') + '"'
					cFiltroBrw	+= ' .AND.  F2Z_PERAPU  ="' + DTOS(mv_par01) + '" '
					cFiltroBrw	+= ' .AND.  F2Z_TRIB == "' + CKZT +  '"'
					cFiltroBrw	+= ' .AND.  F2Z_ORIG == "2" '
					cFiltroBrw	+= ' .AND.  F2Z_CONSOL == "' + CCONSOL + '"'

					cDescr	:= 'Visualização dos Ajustes de Base de Cálculo de '					
					

					If aArray[nPos][4] $ "18/20"
						//Ajuste de Acréscumo
						cFiltroBrw	+= ' .AND. F2Z_INDAJU == "1" '						
						cDescr	+= " Acréscimo de "
					ElseIf aArray[nPos][4] $ "19/21"
						//Ajuste de redução
						cFiltroBrw	+= ' .AND. F2Z_INDAJU == "0" '
						cDescr	+= " Redução de "						
					EndIF

					cDescr	+= Iif(CKZT == '1','PIS', 'COFINS')

					If aArray[nPos][4] $ "18/19"
						cDescr += ' Não Cumulativo'
						cFiltroBrw	+= ' .AND.  F2Z_CODCON  $ "01/02/03/04/71" '
					ElseIf aArray[nPos][4] $ "20/21"
						cDescr += ' Cumulativo'
						cFiltroBrw	+= ' .AND.  F2Z_CODCON  $ "51/52/53/54/72" '
					EndIF				

					cAlias	:= 'F2Z'	

			EndCase
			VisualGen(cFiltroBrw,cDescr,cAlias)
			
		EndIF		

		If cAcao =='CANSETVALUE' .AND. lAlteracao
			cFiltroBrw	:= 'CLA_FILIAL =="' + xFilial('CLA') + '" .AND. CLA_PERUTI =="' + cvaltochar(strzero(month(MV_PAR01 ),2)) + cvaltochar(year(MV_PAR01 )) + '" .and.  CLA_TPAJU =="' + ;
			Iif(aArray[nPos][4] $ '1/3/5','1' ,'0') +'" .AND. SUBSTR(CLA_CHV,1,10) == "' + cFiltroAux +'" .AND. SUBSTR(CLA_CHV,14,1) ==  "' + cDebCred + '"' +;
			' .AND. CLA_CONSOL == "' + CCONSOL + '"'   
						
			oBrowse := FWmBrowse():New()
			oBrowse:SetDescription( cDescr)
			oBrowse:SetAlias( 'CLA' )
			oBrowse:SetMenuDef( 'FISA003' ) 
			oBrowse:SetMainProc('FISA003')
			oBrowse:DisableDetails()
			oBrowse:ForceQuitButton()
			oBrowse:SetFilterDefault( cFiltroBrw )
			oBrowse:Activate()
			aArea	:= GetArea()
			//---------------------------------------------------------------
			//Atualiza os valores da apuração considerando os ajustes manuais
			//---------------------------------------------------------------
			IF CKZR ==	 NAOCUMULAT

				oCompCred	:= CMPCREDITO():New()	
				oCompCred:SetConsol(CCONSOL)
				oCompCred:SetDtIni(MV_PAR01)
				oCompCred:DedCred(CKZT)
				oCompCred	:= Nil

			ElseIf CKZR ==	 CUMULAT
				oDebito:= COMPDEBITO():New()
				oDebito:SetConsol(CCONSOL)
				oDebito:SetDtIni(MV_PAR01) 
				oDebito:AtuDebito(CUMULAT,PIS)
				oDebito:AtuDebito(CUMULAT,COF)			 
				oDebito	:= nil
			EndIF	
			RestArea(aArea)				
		EndIF
		//Se for somente para visualização genérica, então não vai permitir alterar o conteúodo da célula
		lRet	:=  Iif(lAlteracao .OR. isincallstack('atualizagrid'),.T.,.F.)		
//		lRet	:=  .T.
	ElseIF isincallstack('atualizagrid')
		lRet	:= .T.
	EndIF
EndIf

Return .F. 

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA002CKZ
 
Função auxiliar para consulta padrão do detalhamento dos ajustes, retonar
qual é o tributo clicado pelo usu[ario, o regime e a descrição.
			
@author Erick G. Dias
@since 04/07/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function ASA002CKZ()

Return {CKZT,CKZR,CKZD,CKZN,CKZDC,LCARREGA,CCONSOL}


Function AS02XALIAS()
Default CALIAS004 := "CL0"
Return {CALIAS004}



//-------------------------------------------------------------------
/*/{Protheus.doc} ASA001GDUP
 
Função que grava as duplicatas a partir do grid das informações de recolhimento
			
@author Erick G. Dias
@since 16/07/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function ASA001GDUP(aRecolh,lAutomato)

Local aPrefixo	:=	GetNewPar('MV_PREFDCN','{"PIS","COF","CPR"}')
Local AcolsSE2	:= {}

Local cStatus		:= '1'
Local cCodRec		:= ''
local cTipo		:= ''
Local cNumTit		:= ''
Local cNat			:= ''
Local cDescr		:= ''
Local cFiltroBrw	:= ''
Local cPrefixo	:= ''
local cTitGerado	:= ''
Local cCodLP		:= ''
Local cForn	 	:= 	Iif(Empty(SuperGetMV("MV_UNIAO",.F.,"UNIAO")),"UNIAO",SuperGetMV("MV_UNIAO",.F.,"UNIAO"))
Local cLoja	 	:= Iif(TamSx3("A2_LOJA")[1]==4,"0000","00")
Local cNatPsC 	:= 	IIF(!Empty(GetNewPar("MV_PISAPC","")),SuperGetMV("MV_PISAPC"),SuperGetMv("MV_PISNAT"))
Local cNatCfC 	:= 	IIF(!Empty(GetNewPar("MV_COFAPC","")),SuperGetMV("MV_COFAPC"),SuperGetMv("MV_COFINS"))
Local cNatPsNC 	:= 	IIF(!Empty(GetNewPar("MV_PISAPNC","")),SuperGetMV("MV_PISAPNC"),SuperGetMv("MV_PISNAT"))
Local cNatCfNC 	:= 	IIF(!Empty(GetNewPar("MV_COFAPNC","")),SuperGetMV("MV_COFAPNC"),SuperGetMv("MV_COFINS"))
Local cCodPis   	:= GetNewPar("MV_CODPIS","")
Local cCodCof   	:= GetNewPar("MV_CODCOF","")

Local dtVencto	:= CTod("  /  /    ")

Local lDuplicata	:= !LCARREGA .AND. !(MV_PAR13 == 2)
Local lContabil	:= !LCARREGA .AND. MV_PAR14 == 1
Local lRet			:= .F.
Local lPostVen	:= SuperGetMv('MV_VENCPIS')
Local lAltTit		:= Iif(IIF(SX1->(dbSeek(PadR("ISA001",Len(SX1->X1_GRUPO))+"21")) .AND. valtype(MV_PAR21) == "N" ,MV_PAR21, 1)  == 2,.T.,.F.)

Local nI			:= 0
Local nValor		:= ''
Local nTamNF		:= TamSX3('F2_DOC')[1]

Local oBrowse
Local oTitulo
Local oGuias	
Local oDifer
Local aGuias	:= {}

local cNatCPRB := alltrim( GetNewPar("MV_CPRBNAT","") )
local aNatCPRB := {}
local i := 0
local cCodINSS := SubStr(GetMv("MV_FORINSS"),1, TAMSX3("A2_COD")[1]) 
local nPosCPRB := 0
Local nPos 	   := 0

local oModel :=	nil
local oModelAba5 := nil
local cTrib := ""

local dDtIni := MV_PAR01
Local lGravaTit := .F.
Local nRecCKR	:= 0

Private cCadastro := 'Contas a Pagar'
Private lF050Auto := .F.

Default aRecolh	:= {}
Default lAutomato	:= .F.
If SX1->(dbSeek(PadR("ISA001",Len(SX1->X1_GRUPO))+"21")) .and. Valtype(MV_PAR21) == 'N'
	lAltTit		:= Iif(!LCARREGA .AND. MV_PAR21 == 2,.T.,.F.)
	// Tratamento para não estourar error log na chamada do AXALTERA
	Private nOldValor 	:= 0
	Private nOldSaldo 	:= 0
	Private nOldIss		:= 0
	Private nOldIrr		:= 0
	Private nOldInss  	:= 0
	Private nOldSEST  	:= 0
	Private nValorAnt	:= 0
	Private nMaxParc 	:= 0
	Private nOldPis		:= 0
	Private nOldCofins	:= 0
	Private nOldCsll	:= 0
	Private nOldCID   	:= 0
	Private nVlRetPis	:= 0
	Private nVlRetCof 	:= 0
	Private nVlRetCsl	:= 0 
	Private INCLUI		:= .F.
	Private	nValdig		:= 0
	Private lAltera		:= .T.
	Private dVencreaAnt := CtoD('')
	Private lDupA631	:= If(SuperGetMv("MV_IMPTRAN",.F.,"1") == "1" .And. IsBlind() .And. FwIsInCallStack("FINA631"), .T., .F.)		
	
EndIF

//Esta função é chamada para alterar a modelo, pois se não houver alteração
//por parte do usuário, exibe mensagem de que o modelo não houve alteração
//e que não será salvo, por este motivo faço alteração no modelo
//para que possa ser gravado ao clicar no botão confirmar da rotina sem 
//que tenha de fato alteração por parte do usuário
If !lAutomato
	AtualizGrv()
EndIf

If !LCARREGA //.AND. MV_PAR13 == 2

	oModel :=	FWModelActive()
	oModelAba5	:= oModel:GetModel( 'MODEL_ABA5A' )

	If ABA5APOS(aRecolh,lAutomato, oModelAba5)


		aPrefixo   := Iif (Len(aPrefixo) > 1,&(aPrefixo),aPrefixo)
						
		// Tratamento para caso o parametro MV_CPRBNAT esteja informado no formato "{'CODIGO DA RECEITA = NATUREZA', 'CODIGO DA RECEITA = NATUREZA'}"
		// por exemplo: "{'1234 = 00000001', '1235 = 00000001'}"
		if !empty(cNatCPRB) .and. at( "{", cNatCPRB) == 1 .and. at( "}", cNatCPRB) == len(cNatCPRB)
			cNatCPRB := &(cNatCPRB)
			for i := 1 to len(cNatCPRB)
				aAdd( aNatCPRB, { alltrim( substr( cNatCPRB[i], 1, at("=",cNatCPRB[i]) - 1) ) ,  alltrim( substr( cNatCPRB[i], at("=",cNatCPRB[i] ) + 1, len(cNatCPRB[i]) ) )  } )
			
			next
		
		endif

		oGuias	:= APURPISCOF():New()
		oGuias:SetConsol(CCONSOL)	
		oGuias:SetRegime(MV_PAR06)
		oGuias:SetDtIni(MV_PAR01)
		
		oTitulo:= TITPAGAR():New()

		//Carrega as informações no objeto
		aGuias	:= oGuias:LoadRecolh()

		Begin Transaction
		For nI:=1 to oModelAba5:Length()
		
			oModelAba5:GoLine( nI )

			nRecCKR := 0

			If lAutomato
				cCodRec := ''
				dtVencto:= CTod('')
				If nI <= Len(aRecolh)
					cCodRec := aRecolh[nI][1]
					dtVencto:= aRecolh[nI][2]
				EndIf
			Else
				cCodRec	:= oModelAba5:GetValue('ABA5A_CMP2')
				dtVencto:= oModelAba5:GetValue('ABA5A_CMP4')
			EndIf
			
			cTrib	:= substr(oModelAba5:GetValue('ABA5A_CMP1' ),1,1) 
			nValor	:= oModelAba5:GetValue('ABA5A_CMP3' )
			cNumTit	:= ''
			
			If valtype(nValor) == "N" .and. nValor > 0	
				cStatus := '1'	

				If Val(cTrib) > 4
					nPos := aScan( aGuias , { |X| alltrim(X[1]) == cTrib } )
					cTrib := Iif(AllTrim(aGuias[nPos,6]) <> "", AllTrim(aGuias[nPos,6]), cTrib)
				EndIf

				Do Case
					Case cTrib == '1'
						cNat:=	cNatPsNC
						cDescr	:= STR0164//'PIS - NÃO CUMULATIVO'
						cTipo	:= 'PIS'
						cPrefixo	:= Iif(Len(aPrefixo) >=1, aPrefixo[1],'PIS')
						cCodLP	:= '605'
					Case cTrib == '2'
						cNat:=	cNatPsC
						cDescr	:= STR0165//'PIS - CUMULATIVO'
						cTipo	:= 'PIS'
						cPrefixo	:= Iif(Len(aPrefixo) >=1, aPrefixo[1],'PIS')
						cCodLP	:= '605'																	
					Case cTrib == '3'
						cNat:=	cNatCfNC
						cDescr	:= STR0166//'COFINS - NÃO CUMULATIVO'
						cTipo	:= 'COF'
						cPrefixo	:= Iif(Len(aPrefixo) >=2, aPrefixo[2],'COF')
						cCodLP	:= '606'																	
					Case cTrib == '4'						
						cNat:=	cNatCfC
						cDescr	:= STR0167//'COFINS - CUMULATIVO'
						cTipo	:= 'COF'
						cPrefixo	:= Iif(Len(aPrefixo) >=2, aPrefixo[2],'COF')
						cCodLP	:= '606'
					Case Val(cTrib) > 4							

						cNat := ""
						if valtype(cNatCPRB) == "C" 
							cNat := cNatCPRB

						elseif len(aNatCPRB) > 0
						
							nPosCPRB := aScan( aNatCPRB , { |X| alltrim(X[1]) == alltrim(cCodRec) } )
							if nPosCPRB > 0
								cNat := aNatCPRB[nPosCPRB][2]
							endif
							
						endif
						
						cDescr	:= 'CPRB'
						cTipo	:= 'CPR'
						cPrefixo := Iif(Len(aPrefixo) >=3, aPrefixo[3],'CPR')
						cForn   := cCodINSS
						cCodLP	:= '765'			

				EndCAse	 	

				// Tratamento para gravação código de retenção.
				if empty(cCodRec)
					If cTipo $ "PIS"
						cCodRec := cCodPis
					Elseif cTipo $ "COF"
						cCodRec := cCodCof
					EndIf

				endif

				If MV_PAR13 == 5 .AND. !lDuplicata // Deverá solicitar confirmação para geração de guia.
			 		lDuplicata	:= ApMsgYesNo(STR0168)//'Deseja realizar geração de título?'
			 		
			 		If MV_PAR14 == 3 .AND. !lContabil // Deverá solicitar confirmação para contabilização
					 	lContabil	:= ApMsgYesNo(STR0169)//'Deseja realizar contabilização?'	 
					 EndIF			 				 
				EndIF
				
				IF lDuplicata
					If (cTipo $ 'PIS' .Or. cTipo $ 'COF') .And. (MV_PAR13 == 1 .Or. MV_PAR13 == 3)
						lGravaTit := .T.
					ElseIf cTipo $ 'CPR' .And. (MV_PAR13 == 1 .Or. MV_PAR13 == 4)
						lGravaTit := .T.
					EndIf
					
					If lGravaTit
						If SX5->( dbSeek(xFilial()+"53"+'PISCOF'))
							cNumTit:=Soma1(Substr(X5Descri(),1,nTamNF),nTamNF) 
						EndIF	
				
						oTitulo:SetPrefixo(cPrefixo)
						oTitulo:SetNumTit(cNumTit)
						oTitulo:SetParcela(Space(TamSx3('E2_PARCELA')[1]))
						oTitulo:SetTipo(cTipo)
						oTitulo:SetFornece(cForn)
						// Tratamento de forncedor
						IF SA2->(DbSeek(xFilial('SA2')+cForn))
							oTitulo:SetLoja(SA2->A2_LOJA)
							oTitulo:SetNomeFor(SA2->A2_NOME)
						ELSE
							oTitulo:SetLoja(cLoja)
							oTitulo:SetNomeFor('UNIAO')
						EndIF
						oTitulo:SetNatureza(cNat)
						oTitulo:SetDescNat(cDescr)
						oTitulo:SetValor(nValor)
						oTitulo:SetEmis1(dDatabase)
						oTitulo:SetEmissao(dDatabase)
						oTitulo:SetVencto(dtVencto)
						oTitulo:SetVenCrea(DataValida(dtVencto,lPostVen))
						oTitulo:setVenOri(dtVencto)
						oTitulo:SetSaldo(nValor)
						oTitulo:SetVlCruz(nValor)
						oTitulo:SetMoeda(1) 
						oTitulo:SetRateio('N')
						oTitulo:SetFluxo('S')
						oTitulo:SetCodRet(cCodRec)
						oTitulo:SetOrigem('FISA001')
						oTitulo:SetContab(lContabil)
						oTitulo:SetCodLp(cCodLP)	
						oTitulo:SetExibCtb(.T.) 
						
						If cTipo $"PIS||COF" .And. CKR->(MSSEEK(xFilial('CKR')+dTos(dDtIni)+CCONSOL+Iif(cTipo =='PIS','1','2'))) //Seto posição na CKR para que contabilização seja efetuada de acordo com o tipo de imposto
							nRecCKR := CKR->(Recno())
						EndIf

						oTitulo:GrvTitulo()	

						If lAltTit
							nOldValor 	:= SE2->E2_VALOR  
							nOldSaldo 	:= SE2->E2_SALDO
							nOldIss		:= SE2->E2_ISS
							nOldIrr		:= SE2->E2_IRRF
							nOldInss  	:= SE2->E2_INSS
							nOldSEST  	:= SE2->E2_SEST
							nOldPis		:= SE2->E2_PIS
							nOldCofins	:= SE2->E2_COFINS
							nOldCsll	:= SE2->E2_CSLL
							nVlRetPis	:= SE2->E2_VRETPIS
							nVlRetCof 	:= SE2->E2_VRETCOF
							nVlRetCsl	:= SE2->E2_VRETCSL 
							nValdig		:= SE2->E2_VALOR
							dVencreaAnt := SE2->E2_VENCREA
							//Estou chamando a função do Financeiro (FINA050) para retornar os campos que poderão ser editados, seguindo a mesma regra que o FINA050 faz para editar títulos
							//Já que não se pode alterar qualquer campo do título.
							
							If FindFunction( "CTB105MVC")
								CTB105MVC(.T.)
							EndIf

							aColsSe2	:= fa050MCpo(4)     
							AxAltera("SE2",SE2->(Recno()),3,,aColsSe2,,,/*"SF6TudoOk()"*/)
						EndIf
						//Verifica se gravou o título
						IF oTitulo:GetGrvTit()	
							cStatus := '2'
							//Atualiza SX5 com o último número de título gerado
							If SX5->(dbSeek(xFilial("SX5")+"53"+'PISCOF'))
								RecLock('SX5',.F.)
								SX5->X5_DESCRI	:= cNumTit
								SX5->X5_DESCSPA 	:= cNumTit
								SX5->X5_DESCENG 	:= cNumTit
								MsUnlock()
								cTitGerado +=cNumTit+'/'
							EndIF
							//Busca informações dos títulos gerados e atualiza CL3
							oGuias:GrvRecolhi( cTrib ,nValor,'',,SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA)						
							
						EndIF
					
						//Verifica se gravou contabilidade
						If 	oTitulo:GetContab()
							cStatus := '3'
						EndIF
					
						//Atualiza STATUS da tabela de apuração para STATUS de geração de Guia		
						If cTipo $"PIS||COF" .and. nRecCKR > 0
							RecLock('CKR',.F.)
							CKR->CKR_STATUS	:=	cStatus//Concluída gerou guia
							MsUnLock()
						EndIF
					EndIF
				EndIF
			EndIf
			lGravaTit := .F.
		Next nI
		FreeObj(oTitulo)
		oTitulo:= Nil
		
		
		
		// Tratamento para gerar lançamento contábil para Diferimento de PIS / COFINS ( dentro do mesmo período e período anterior )
		// Primeiramente será nescessário verificar se há valor de Diferimento na tabela CKS para então realizar o Lançamento Padrão
	
		if lContabil //Verifica se deverá efetuar a contabilização 
			
			DBSelectArea( 'CKS' )
			CKS->( DBSetOrder( 1 ) )
			if CKS->( MsSeek(xFilial("CKS")+dTos(MV_PAR01)))
			
				oDifer:= TITPAGAR():New()
								
				do while !CKS->( eof () ) .and. CKS->CKS_FILIAL == xFilial('CKS') .and. CKS->CKS_PER == MV_PAR01
				
					//DIFERIMENTO PIS/COFINS NO MÊS (Período)
					if CKS->CKS_DIF > 0 					
						cCodLP	:= 	iif(CKS->CKS_TRIB == '1','757','758')				
						CtbDifer(oDifer, cCodLP, lContabil)
					endif
					
					//DIFERIMENTO PIS/COFINS NO MÊS (Período)
					if CKS->CKS_DIFANT > 0 					
						cCodLP	:= 	iif(CKS->CKS_TRIB == '1','759','760')				
						CtbDifer(oDifer, cCodLP, lContabil)
					endif		
					CKS->(dbSkip())
				enddo
				
				FreeObj(oDifer)
				oDifer:= Nil
			endif
		endif
		
		End Transaction
		
		IF ! empty(cTitGerado) 
			CALIAS004	:= 'SE2'
			cFiltroBrw	:= ' E2_TIPO $ "PIS/COF/CPR" .AND. E2_ORIGEM == "FISA001" .AND. E2_NUM $ "' +  cTitGerado + '"'	
			If !lAutomato
				VisualGen(cFiltroBrw,STR0170,'SE2')//'Visualização dos Títulos gerados'
			EndIf		
		EndIF
		lRet	:= .T.
	ElseIf lDuplicata .And. !lAutomato
		lRet	:= .F.
		Alert(STR0171)//'É necessário preencher o código da Receita e data de vencimento em informações de recolhimento.'	
	Else
		lRet	:= .T.
	EndIF
	
Else
	lRet	:= .T.
EndIF

//lRet	:= .T.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbDifer
Função que realiza a contabilização online referente ao Diferimento de 
Pis / Cofins 
 
@author Simone Oliveira
@since 03/01/2017
@version 1.0

/*/
//-------------------------------------------------------------------
function CtbDifer(oDifer, cCodLDif, lContabil)

default cCodLDif	:= ''
default lContabil	:= .f.

if ! empty( cCodLDif )
	oDifer:SetOrigem('FISA001')
	oDifer:SetContab(lContabil)
	oDifer:SetCodLp(cCodLDif)	
	oDifer:SetExibCtb(.t.) 
	oDifer:Contabiliz()		
endif

return

Static Function AtualizGrv()
Local oModel		:=	FWModelActive()
Local oModelZA2	:= oModel:GetModel( 'MODEL_ABA6' )
lOCAL oView 		:= 	FWViewActive()

//Se for somente para carregar a tela, não irá atualizar o grid.
IF !LCARREGA

	oModelZA2:GoLine( 1)
	oModelZA2:SetValue( 'ABA6_CMP1' , ' ')
	
	oview:Refresh( 'VIEW_ABA6' )
EndIF

Return


Static Function VisualGen(cFiltro,cDescr,cAlias)

Local oBrowse

CALIAS004	:= cAlias
oBrowse := FWmBrowse():New()
oBrowse:SetDescription( cDescr)
oBrowse:SetAlias( cAlias )
oBrowse:SetMenuDef( 'FISA004' ) 
oBrowse:SetMainProc('FISA004')
oBrowse:DisableDetails()
oBrowse:ForceQuitButton()
oBrowse:SetFilterDefault( cFiltro )
oBrowse:Activate()
CALIAS004	:= cAlias

Return

Function ABA5APOS(aRecolh,lAutomato, oModelAba5)

local oModel		:= nil
Local nI 			:= 0
Local nX 			:= 0
Local oGuias
Local cCodRec	:= ''
Local dDataVenc	:= CTod("  /  /    ")
Local nValor		:= 0
Local lCorreto	:= .T.
Local cTrib	:=''

Default aRecolh	:= {}
Default lAutomato	:= .F.

default oModelAba5	:= nil

if valtype(oModelAba5) == "U"
	oModel :=	FWModelActive()
	oModelAba5	:= oModel:GetModel( 'MODEL_ABA5A' )
	
endif

//-----------------------------------------
//AJUSTE NA ABA DOS DÉBITOS NÂO CUMULATIVOS
//-----------------------------------------
aArea	:= GetArea()
oGuias	:= APURPISCOF():New()	
oGuias:SetConsol(CCONSOL)
oGuias:SetRegime(MV_PAR06)
oGuias:SetDtIni(MV_PAR01)
				
For nI := 1 To oModelAba5:Length()
	oModelAba5:GoLine( nI )	
	//Através do código do tributo no grid, as informações da CL3 serão atualizadas
	cTrib	:= substr(oModelAba5:GetValue('ABA5A_CMP1' ),1,1) 
	IF !Empty(cTrib)
		
		nValor	:= oModelAba5:GetValue('ABA5A_CMP3' )		
		If nValor > 0
			
			nX++
			cCodRec	:= Iif(!lAutomato, oModelAba5:GetValue('ABA5A_CMP2'), aRecolh[nX][1])	
			dDataVenc	:= Iif(!lAutomato, oModelAba5:GetValue('ABA5A_CMP4'), aRecolh[nX][2])	
			
			IF !Empty(AllTrim(cCodRec)) .AND. dDataVenc <> CTod("  /  /    ")
				oGuias:GrvRecolhi(cTrib,nValor,cCodRec, dDataVenc)
			Else
				lCorreto:= .F.
				Exit			
			EndIF		
		
		EndIF	
	EndIF

Next nI

oModelAba5:GoLine( 1 )


oGuias	:= Nil
RestArea(aArea)
 
Return  lCorreto