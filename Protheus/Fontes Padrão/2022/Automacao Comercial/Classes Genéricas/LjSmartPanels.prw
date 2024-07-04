#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSmartPanels
Classe de suporte para auxiliar na implementação de interfaces

@type    class
@since   17/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class LjSmartPanels

    // -- LjSmartPanel
    Data lDevelopment
    Data oPanel
    Data aPanels
    Data nScrollbarsize 
    Data nColumns
    Data nLines

    // -- Dialog
    Data oDialog             as Object
    Data nWidth              as Numeric //Largura
    Data nHeight             as Numeric //Altura

    // -- Paineis
    Data nMinimumPanelWidth  as Numeric
    Data nMinimumPanelHeight as Numeric
    Data nBetweenPanels      as Numeric
    Data nInitialWidth       as Numeric
    Data nInitialHeight      as Numeric

    Method New(lDevelopment,oDialog,nWidth,nHeight,nMinPanelWidth,nMinPanelHeight,nBetweenPanels)
    Method Creat(nPanels,nColumns,lNotInterger)
    Method PanelWidthCalculation(nColumns)
    Method PanelHeightCalculation(nPanels,nColumns,nPanelHeight)
    Method SetScrollbarsize()
    Method GetScrollbarsize()
    Method GetPanels()
    Method Rearrange(nFromThePanel,nColumns,nLines)

    Method IsDevelopment(xContentDev)

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      lDevelopment, Lógico, Define se esta sendo executado no modo desenvolvimento
@param      oDialog, Objeto, Objeto de interface onde os componentes serão criados
@param      nWidth, Numérico, Largura máxima para criação dos componentes
@param      nHeight, Numérico, Altura máxima para criação dos componentes
@param      nMinPanelWidth, Numérico, Largura mínima que cada painel criado pode ter
@param      nMinPanelHeight, Numérico, Altura mínima que cada painel criado pode ter
@param      nBetweenPanels, Numérico, Tamanho do espaço entre os painéis

@return     LjSmartPanels, Objeto instânciado
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(lDevelopment,oDialog,nWidth,nHeight,nMinPanelWidth,nMinPanelHeight,nBetweenPanels,nInitialWidth,nInitialHeight) Class LjSmartPanels

    Default nInitialWidth    := 0 
    Default nInitialHeight   := 0

    Self:lDevelopment        := lDevelopment

    Self:oDialog             := oDialog
    Self:nWidth              := nWidth
    Self:nHeight             := nHeight
    Self:nMinimumPanelWidth  := nMinPanelWidth
    Self:nMinimumPanelHeight := nMinPanelHeight
    Self:nBetweenPanels      := nBetweenPanels
    Self:nInitialWidth       := nInitialWidth
    Self:nInitialHeight      := nInitialHeight

    Self:nWidth              := Self:nWidth * 0.50
    Self:nHeight             := Self:nHeight * 0.50

    Self:nScrollbarsize      := 0
    
    Self:aPanels             := {}

Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Creat
Cria os painéis

@type       Method
@param      nPanels, Numérico, Quantidade de painéis que serão criados
@param      nColumns, Numérico, Quantidade de colunas  
@param      lNotInterger, Lógico, Se .F. ira incrementar o parâmetro nPanels, caso a divisão (nPanels / nColumns) tenha decimais.

@return     Array, Com os painéis criados (tPanel)
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Creat(nPanels,nColumns,lNotInterger) Class LjSmartPanels

    Local nPanelWidth       := 0
    Local nPanelHeight      := 0

    Local nHorizontalCoordinate := Self:nBetweenPanels 
    Local nVerticalCoordinate   := Self:nBetweenPanels 

    Local nX:=1
    Local nAuxPanels  := nPanels / nColumns

    Default nColumns := 1
    Default lNotInterger := .F.

    If !lNotInterger 
        While nAuxPanels - int(nAuxPanels) <> 0
            nAuxPanels := ( nPanels + nX ) / nColumns
            nX++
        EndDo
        nPanels := nAuxPanels * nColumns
    EndIf

    nPanelHeight :=  Self:nMinimumPanelHeight
    
    If Self:PanelHeightCalculation(nPanels,nColumns,nPanelHeight) > Self:nHeight 
        Self:SetScrollbarsize()
    EndIf 

    nWidthAux :=  Self:PanelWidthCalculation(nColumns)
    If nWidthAux >= Self:nMinimumPanelWidth
        nPanelWidth  :=  nWidthAux
    Else
        //Ajusto a quantidade de colunas removendo de 1 em 1 ate que seja possivel posicinar na Dialog
        While nWidthAux < Self:nMinimumPanelWidth
            nColumns--
            nWidthAux := Self:PanelWidthCalculation(nColumns)
            If nWidthAux >= Self:nMinimumPanelWidth
                nPanelWidth  :=  nWidthAux
                EXIT 
            EndIf 
        EndDo

    EndIf 

    oScroll := TScrollArea():New(Self:oDialog,self:nInitialHeight,self:nInitialWidth,Self:nHeight,Self:nWidth  + Self:GetScrollbarsize())
    Self:oPanel :=  tPanel():New(0,0,"",oScroll,Nil,.T.,,Self:IsDevelopment(CLR_YELLOW),Self:IsDevelopment(CLR_RED),Self:nWidth,Self:PanelHeightCalculation(nPanels,nColumns,nPanelHeight))
    oScroll:SetFrame( Self:oPanel )
    oScroll:lTracking := .T.

    nCurrentColumn := 1
    nCurrentLine   := 1

    For nX := 1 To nPanels
        
        AAdd(Self:aPanels,{tPanel():New(nVerticalCoordinate,nHorizontalCoordinate,Self:IsDevelopment("Painel " + cValToChar(nX)),Self:oPanel,Nil,.T.,,Self:IsDevelopment(CLR_YELLOW),Self:IsDevelopment(CLR_BLUE),nPanelWidth,nPanelHeight),nCurrentLine,nCurrentColumn})//Largura x altura
        
        If (nHorizontalCoordinate + nPanelWidth + Self:nBetweenPanels)  >= Self:nWidth 
            nVerticalCoordinate   := nVerticalCoordinate + nPanelHeight + Self:nBetweenPanels
            nHorizontalCoordinate := Self:nBetweenPanels
            nCurrentLine++
            nCurrentColumn := 1
        Else
            nHorizontalCoordinate := nHorizontalCoordinate + nPanelWidth + Self:nBetweenPanels
            nCurrentColumn++  
        EndIf 
    Next

    Self:nColumns := nColumns
    
Return Self:aPanels

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PanelWidthCalculation
Calcula a largura que cada painel deve ter

@type       Method
@param      nColumns, Numérico, Quantidade de colunas  

@return     Numérico, Largura do painel
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method PanelWidthCalculation(nColumns) Class LjSmartPanels
Return (Self:nWidth - ((nColumns + 1) *  Self:nBetweenPanels ))  / nColumns

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PanelHeightCalculation
Calcula a altura do painel

@type       Method
@param      nPanels, Numérico, Quantidade de painéis que serão criados
@param      nColumns, Numérico, Quantidade de colunas  
@param      nPanelHeight, Numérico, Altura mínima de cada painel

@return     Numérico, Altura do painel
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method PanelHeightCalculation(nPanels,nColumns,nPanelHeight) Class LjSmartPanels
    Self:nLines := Ceiling(nPanels / nColumns)
Return (Self:nLines * nPanelHeight) + ((Self:nLines + 1 ) * Self:nBetweenPanels)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetScrollbarsize
Atualiza informações da barra de rolagem

@type       Method
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetScrollbarsize() Class LjSmartPanels
    Self:nScrollbarsize := 8
    Self:nWidth -= Self:nScrollbarsize
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetScrollbarsize
Retorna o tamanho da barra de rolagem

@type       Method
@return     Numérico, Tamannho da barra de rolagem
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetScrollbarsize() Class LjSmartPanels
Return Self:nScrollbarsize

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPanels
Retorna os painéis criados (tPanel)

@type       Method
@return     Array, Com os painéis criados
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetPanels() Class LjSmartPanels
return Self:aPanels

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Rearrange
Reorganiza o painel a partir dos parâmetros fornecidos

@type       Method
@param      nFromThePanel, Numérico, Define qual painel será modificado
@param      nColumns, Numérico, Colunas que painel deve ter
@param      nLines, Numérico, Linhas que painel deve ter

@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Rearrange(nFromThePanel,nColumns,nLines) Class LjSmartPanels
    Local nCont    := 1
    Local nC
    Local nX
    Local aLines   := {}
    Local aColumns := {}

    Local aPanels
    Local nHeight  := 0
    Local nWidth   := 0
   
    nPosVertical     := Self:aPanels[nFromThePanel][1]:nTop * 0.50
    nPosHorizontal   := Self:aPanels[nFromThePanel][1]:nLeft * 0.50

    aPanels          := Array(nColumns * nLines)
    
    nStartingLine    := Self:aPanels[nFromThePanel][2]
    nFinalLine       := (nStartingLine + nLines) -1

    nStartingColumn  := Self:aPanels[nFromThePanel][3]
    nFinalColumn := (nStartingColumn + nColumns) -1

    For nC := 1 To Len(Self:aPanels)
        If Self:aPanels[nC][2] >= nStartingLine .AND. Self:aPanels[nC][2] <= nFinalLine
            
            If !AScan(aLines,Self:aPanels[nC][2])
                AAdd(aLines,Self:aPanels[nC][2])
                nHeight += Self:aPanels[nC][1]:nHeight
            EndIf 
                        
            If Self:aPanels[nC][3] >= nStartingColumn .AND. Self:aPanels[nC][3] <= nFinalColumn
                aPanels[nCont] := nC
                
                If !AScan(aColumns,Self:aPanels[nC][3])
                    AAdd(aColumns,Self:aPanels[nC][3])
                    nWidth += Self:aPanels[nC][1]:nWidth
                EndIf 
                
                nCont++
                If nCont > len(aPanels)
                    Exit
                EndIf 
            EndIf 

        EndIf 
    Next 

    nHeight := (nHeight * 0.50 ) +  (Self:nBetweenPanels * (Len(aLines) - 1))
    nWidth  := (nWidth  * 0.50 ) +  (Self:nBetweenPanels * (Len(aColumns) - 1))

    Self:aPanels[nFromThePanel][1] := tPanel():New(nPosVertical,nPosHorizontal,Self:IsDevelopment("Painel " + cValToChar(nFromThePanel)),Self:oPanel,Nil,.T.,,Self:IsDevelopment(CLR_YELLOW),Self:IsDevelopment(CLR_BLUE),nWidth,nHeight)   

    For nX := 1 To len(aPanels)
        If aPanels[nX] <> nFromThePanel
            FreeObj( Self:aPanels[aPanels[nX]][1])
        EndIf 
    Next 

return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsDevelopment
Metodo para auxiliar no desenvolvimento das interfaces, quando o modo desenvolvimento estiver ativo (self:lDevelopment := .T.)

@type       Method
@param      xContentDev, Indefinido, Conteúdo que será atualizado no componente
@return     Indefinido, Conteúdo que será atualizado no componente

@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method IsDevelopment(xContentDev) Class LjSmartPanels
    Local xResult := Nil

    If Self:lDevelopment
        xResult := xContentDev
    EndIf 

Return xResult