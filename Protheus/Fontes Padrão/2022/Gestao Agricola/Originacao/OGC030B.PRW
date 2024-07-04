#Include 'Protheus.ch'
#Include 'OGC030B.ch'

sTatic cRet :=''

/** {Protheus.doc} OGC030B
Consulta Padrão especifica de Status de Romaneio,
que permite selecionar os status de romaneio a retornar

@param: 	Nil
@return:	OGC030BA() -> Itens selecionados separados por (;)
@author: 	Equipe Agroindústria
@since: 	14/07/2015
@Uso: 		Agro (OGR295)
*/
 
Function OGC030B()

	Local nTamH 		:= ( GetScreenRes()[1] - 600 )
	Local nTamV 		:= ( GetScreenRes()[2] - 400 )
	Local aButtons	    := {}
	Local nOpc			:= 0
	Local nI			:= 0
	
	Private cTrbAli
	Private cIndice1	:= CriaTrab(NIL,.F.) //--Criando Arq. de Indice Por Codigo 
	Private aColumns	:= {}
  	Private oMrkSTUS	:= Nil
	Private aMarcados	:= separa(&(readvar()), ';')
	Private cMarca	    := GetMark()	//Definindo o Caracter da Marca
	Private oDlg		:= Nil

  
	oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Consulta Status de Romaneio"
	oDlg:lEscClose := .f.

	fGerTrbSTS()		//-- Gerando Arquivo de Temporario --
	fObrwSTUS(odlg)	//-- Gerando o Fwmarkbrowse			--

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpc := 1, oDlg:End() },{|| nOpc := 0, oDlg:End() },, @aButtons ) } )

	cRet := ''
	If nOpc > 0 .And. Len( aMarcados ) > 0
		For nI := 1 to Len( aMarcados )
			cRet+= alltrim(aMarcados[nI])
			If ! nI = Len( aMarcados )
				cRet += ';'
			EndIf
		nExt nI
	Else
		cRet:= &(readvar())
	EndIf
	
	fDelTrb()	//Deletando o Arquivo Temporario

Return( .t. )


/** {Protheus.doc} fGerTrbSTS
Função que Cria o Arq. de auxilio, que será utilizado pelo
browse oMrkSTS , e tbem o Acolumns do Browse

@param: 	Nil
@return:	Acolumns e cTrbAli (vars. Private) estarão criados
@author: 	Equipe Agroindústria
@since: 	14/07/2015
@Uso: 		Agro (OGR295)
*/

Static Function fGerTrbSTS()
					   
	Local nX         := 0
	Local aAuxMrkdos := aMarcados
	Local aLstStus   := {} 
	Local aFieldSTUS := {{"CODSTS","C",2,0,STR0002, "@!"},;	  //"Código Status"
						   {"DESSTS","C",20,0,STR0003, "@!"},; //Descrição Status
						   {"MARCAX","C", 2,0}	} //"Mark"		
	
	aMarcados	:= {} // Inicializa aRRay amarcados
		
	CursorWait()
		
	If Select( cTrbAli ) > 0 // -- verifica se temporario está aberto executar Zap
		DbSelectArea( cTrbAli )
		Zap
	Else
	  cTrbAli  := GetNextAlias()
	  oTrbSTUS := AGRCRTPTB( cTrbAli, {aFieldSTUS, {{"","CODSTS"}} } )
	Endif

	
	//get Status
	aLstStus = gGetStsNJJ()	
	for nX := 1 to Len( aLstStus )
		reclock(cTrbAli,.t. )
			(cTrbAli)->CODSTS = aLstStus[nX][1] //código
			(cTrbAli)->DESSTS = aLstStus[nX][2] //descrição
			(cTrbAli)->MARCAX = ''
			
			//verifica se já é para vir marcado
			IF aScan( aAuxMrkdos, aLstStus[nX][1] ) > 0 	// Verificando se devo gravar algum item como já selecionado
				(cTrbAli)->MARCAX  := cMarca
				aAdd(aMarcados , alltrim(aLstStus[nX][1]) )			//aDiciona Item Marcado ao array aMarcados
			EndIf
			 
	end
			
	
	//Define as colunas a serem apresentadas na markbrowse
		
	AAdd( aColumns,FWBrwColumn():New() )				
	aColumns[ Len(aColumns) ]:SetData( &("{||CODSTS}")	)
	aColumns[ Len(aColumns) ]:SetType("C"			)
	aColumns[ Len(aColumns) ]:SetTitle(STR0002  ) //código
	aColumns[ Len(aColumns) ]:SetSize(2        )
	aColumns[ Len(aColumns) ]:SetPicture( "@!"				)
		
	AAdd( aColumns,FWBrwColumn():New() )				
	aColumns[ Len(aColumns) ]:SetData( &("{||DESSTS}")	)
	aColumns[ Len(aColumns) ]:SetType("C"			)
	aColumns[ Len(aColumns) ]:SetTitle(STR0003  ) //descrição
	aColumns[ Len(aColumns) ]:SetSize(20        )
	aColumns[ Len(aColumns) ]:SetPicture( "@!"				)
		
	CursorArrow()
	
Return( nil )

/** {Protheus.doc} fObrwSTUS
	Função que Cria/Atualiza o MarkBrowse da tabela de vincs.
	
@param: 	oPnd1	-> Owner do browse(onde o brose será ancorado
@return:	nil			(Atencao oMrkSTUS é objeto Private )
@author:    Equipe Agroindústria
@since:     14/07/2015
@Uso:       Agro (OGR295)
*/
	
Static Function fObrwSTUS(oOwner)
	
	Local cAliasMrk    	:= cTrbAli
	Local aColsBRW		:= aColumns

	//------------------------------------------
	//Criação da MarkBrowse da NJJSTS
	//------------------------------------------
	IF oMrkSTUS == nil
		oMrkSTUS:=FwMarkBrowse():New()

		oMrkSTUS:SetDescription( STR0004) //"Selecione os Status de Romaneio" 
          
		oMrkSTUS:SetFieldMark("MARCAX")
		
		oMrkSTUS:SetOwner(oOwner)
		oMrkSTUS:SetDataQuery(.F.)
		oMrkSTUS:SetDataTable(.T.)
		oMrkSTUS:SetAlias( cAliasMrk )
		oMrkSTUS:cMark:=cMarca
		
		oMrkSTUS:SetCustomMarkRec({|| fmarcar( oMrkSTUS ) })
			
		oMrkSTUS:bAllMark := { ||  }
			
		oMrkSTUS:SetMenuDef("OGC030A")
		oMrkSTUS:SetColumns( aColsBRW )
		oMrkSTUS:DisableConfig(.t.)
		oMrkSTUS:DisableReport(.t.)
		oMrkSTUS:Activate()
	Else
		
		oMrkSTUS:SetAlias( cAliasMrk )
		oMrkSTUS:Refresh()
	EndIF
	oLegend := FWLegend():New()
	oMrkSTUS:oBrowse:Setfocus()
	
	
	(oMrkSTUS:Alias())->( dBGotop() )

Return
	
	
/*{Protheus.doc} 
	Função q Deleta o Arq. Temporario
@param		nil.
@return   	nil
@author:   Equipe Agroindústria
@since:    14/07/2015
@Uso:      Agro (OGR295)*/

Static Function fDelTrb()
	
	If Select( cTrbAli ) > 0
		(cTrbAli)->( DbCloseArea() )
		FErase(cTrbAli + GetDbExtension() ) 	// Deletando o arquivo
		FErase(cTrbAli + OrdBagExt() )			// Deletando índice
	EndIF
	
Return
	
	
/*{Protheus.doc} fMarcar(oMrkBrowse)
	Atualiza Marcador do FWMarkBrowse.	
@param        ExpO     Objeto da MarkBrowse(FWMarkBrowse).
@return    ExpL    Verdadeiro / Falso
@author:   Equipe Agroindústria
@since:    14/07/2015
@Uso:      Agro (OGR295)*/

Static Function fMarcar( oMrkBrowse )

	DbSelectArea( cTrbAli )
	
		
	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARCAX  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
		aAdd(aMarcados,alltrim((oMrkBrowse:Alias())->CODSTS) )
			
	Else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->marcax  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
			
		nPosItMrk := aScan(aMarcados, alltrim((oMrkBrowse:Alias())->CODSTS )) // retorno esperado
		If nPosItMrk > 0
			aDel(aMarcados, nPosItMrk)
			aSize(aMarcados,len(aMarcados)-1)
		EndIf
	EndIf
			
	
Return( .T. )

/*
@param: nil
@description: Função que obtem os dados dos status da NJJ.
@author: Equipe Agroindústria
@since: 13/08/2015
@return: array
*/

static function gGetStsNJJ()
	local aStsNJJ := {}
	Local nI		:= 0
	local aAux 	:= Separa(AGRRETSX3BOX("NJJ_STATUS"),';')
	local aAux2   := {}
		
	For nI := 1 to Len(aAux) Step 1
		  aAux2 = separa(aAux[nI],'=')
		  aAdd(aStsNJJ,{alltrim(aAux2[1]),alltrim(aAux2[2])})
	nExt
	
return (aStsNJJ)

/** {Protheus.doc} OGC030BA
Função que Retorna os Itens Marcados

@param: 	Nil
@return:	cRet -> Cod. dos Status Selecionados
@author:   Equipe Agroindústria
@since:    14/07/2015
@Uso:      Agro (OGR295)*/


function OGC030BA()
Return(cRet)