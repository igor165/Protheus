#include 'protheus.ch' 
#include 'totvs.ch'
#include 'mdfeinfpag.ch'
 
#define ENTER           CHR(10)+CHR(13)
#define PAG_GRID_PAGTO  1 //Informações de Pagamentos
#define PAG_GRID_COMP   2 //Componente do Pagamento
#define PAG_GRID_PRAZO  3 //Parcelas do Pagamento
 
#define PAG_NOME        1
#define PAG_CPFCNPJ     2
#define PAG_VCONTRA     3
#define PAG_INDPAG      4
#define PAG_ADIANT      5
#define PAG_CNPJEPEF    6
#define PAG_BANCO       7
#define PAG_AGENCIA     8
#define PAG_PIX         9
#define PAG_DESEMPE     10
#define PAG_INDANTE     11
#define PAG_TPANTE      12

#define PAG_TPCOMP      1
#define PAG_VCOMP       2
#define PAG_XCOMP       3

#define PAG_PARC        1
#define PAG_VPARC       2
#define PAG_DVENC       3
 
#define TAMTXT          60

/*/{Protheus.doc} MDFeInfPag
 
Classe para manipulação das informações de pagamento do MDFe.
 
@since 26/03/2020
@version 1.0
/*/
class MDFeInfPag
 
    data cClassName
 
    // Atributos para controle de tela
    data aInfPag
 
    // Atributos para controle de tela
    data oGetDPgto
    data oGetDPComp
    data oGetDPPraz
    data aHeadPgto
    data aHeadComp
    data aHeadPrazo
    data aColsPgto
    data aColsComp
    data aColsPrazo
    data lShow
 
    method new()
 
    // Métodos para controle de dados 
    method XmlInfPag()
    method GetInfPag()
    method SetInfPag()
    method UpdControl()
 
    // Métodos para controle de tela
    method GetHeadPgto()
    method GetHeadComp()
    method GetHeadPraz()
    method GetNewLine()
    method CreateGrid()
    method Show()
    method AtuGridPgt()
    method VldLinePgt()
    method ValidaOk()
    method Refresh()
    method ActDesact()

end class
 
/*/{Protheus.doc} 
Metodo construtor
@since 26/03/2020
@version 1.0
/*/
method new() class MDFeInfPag
    self:cClassName := "MDFeInfPag"
 
    self:oGetDPgto  := nil
    self:oGetDPComp := nil
    self:oGetDPPraz := nil
    self:aHeadPgto  := self:GetHeadPgto()
    self:aHeadComp  := self:GetHeadComp()
    self:aHeadPrazo := self:GetHeadPraz()
    self:aColsPgto  := self:GetNewLine(self:aHeadPgto)
    self:aColsComp  := self:GetNewLine(self:aHeadComp)
    self:aColsPrazo := self:GetNewLine(self:aHeadPrazo)
    self:aInfPag    := {}
    self:lShow      := .F.
 
return self
 
/*/{Protheus.doc} 
Metodo get da estrutura InfPag
@since 26/03/2020
@version 1.0
/*/
method XmlInfPag() class MDFeInfPag
    local cXML      := ""
    local aInfPag   := self:getInfPag()
    local nInfPag   := 0
    local nComp     := 0
    local nPrazo    := 0
    local cInfPrazo := ""
    local lInfPrazo := .F.
    local dDtVenc   := ctod("")
    Local aPgtoEmpt := aClone(self:GetNewLine(self:aHeadPgto)[1])
    Local aCompEmpt := aClone(self:GetNewLine(self:aHeadComp)[1])
    Local aPrazEmpt := aClone(self:GetNewLine(self:aHeadPrazo)[1])

    self:UpdControl(PAG_GRID_PAGTO) //Atualiza a variavel de controle

    for nInfPag := 1 to Len(aInfPag)
        if !aInfPag[nInfPag,PAG_GRID_PAGTO,len(aInfPag[nInfPag,PAG_GRID_PAGTO])]  .And.; //Não deletada
            !aCompare(aInfPag[nInfPag,PAG_GRID_PAGTO],aPgtoEmpt)

            cXML += '<infPag>'
                if !empty(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_NOME])
                    cXML += '<xNome>' + alltrim(SpecCharc(SubStr(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_NOME],1,TAMTXT))) + '</xNome>'
                endif
                aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ] := AllTrim(StrTran(StrTran(StrTran(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ],"."),"/"),"-"))
                if Len(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ]) == 11
                    cXML += '<CPF>' + AllTrim(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ]) + '</CPF>'
                elseif Len(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ]) == 14
                    cXML += '<CNPJ>' + AllTrim(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ]) + '</CNPJ>'
                else
                    cXML += '<idEstrangeiro>' + alltrim(SubStr(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CPFCNPJ],1,20)) + '</idEstrangeiro>'
                endif
                for nComp := 1 to Len(aInfPag[nInfPag,PAG_GRID_COMP])
                    if !aInfPag[nInfPag,PAG_GRID_COMP,nComp,Len(aInfPag[nInfPag,PAG_GRID_COMP,nComp])] .And.;//Não deletada
                        !aCompare(aInfPag[nInfPag,PAG_GRID_COMP,nComp],aCompEmpt)

                        cXML += '<Comp>'
                            If !Empty(aInfPag[nInfPag,PAG_GRID_COMP,nComp,PAG_TPCOMP])
                                cXML += '<tpComp>' + StrZero(Val(aInfPag[nInfPag,PAG_GRID_COMP,nComp,PAG_TPCOMP]),2) + '</tpComp>'
                            EndIf
                            cXML += '<vComp>' + ConvType(aInfPag[nInfPag,PAG_GRID_COMP,nComp,PAG_VCOMP],16,2) + '</vComp>'
                            if !empty(aInfPag[nInfPag,PAG_GRID_COMP,nComp,PAG_XCOMP])
                                cXML += '<xComp>' + alltrim(SpecCharc(SubStr(aInfPag[nInfPag,PAG_GRID_COMP,nComp,PAG_XCOMP],1,TAMTXT))) + '</xComp>'
                            endif
                        cXML += '</Comp>'
                    endif
                next
                cXML += '<vContrato>' + ConvType(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_VCONTRA],16,2)  + '</vContrato>'
                //Verificação para quando no method GetHeadPgto() não for adicionada a posição do campo Oper. Alto Desempenho
                if !FWIsInCallStack("MDFeManage") .and. len( aInfPag[ nInfPag, PAG_GRID_PAGTO ] ) > 9 .and. aInfPag[ nInfPag, PAG_GRID_PAGTO, PAG_DESEMPE ] == "1"
                    cXML += '<indAltoDesemp>1</indAltoDesemp>'
                endIf
                cXML += '<indPag>' + SubStr(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_INDPAG],1,1)  + '</indPag>'
                cXML += if(aInfPag[ nInfPag,PAG_GRID_PAGTO,PAG_ADIANT ] > 0 , '<vAdiant>' + convType( aInfPag[ nInfPag,PAG_GRID_PAGTO,PAG_ADIANT ], 16, 2)  + '</vAdiant>', '')

                if !empty(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_INDANTE]) .and. aInfPag[ nInfPag, PAG_GRID_PAGTO, PAG_INDANTE ] == "1"
                    cXML += '<indAntecipaAdiant>1</indAntecipaAdiant>'
                endif
                for nPrazo := 1 to Len(aInfPag[nInfPag,PAG_GRID_PRAZO])
                    cInfPrazo := ""
                    lInfPrazo := .F.
                    dDtVenc := ctod("")
                    if !aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,Len(aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo])] .And.;//Não deletada                    
                        !aCompare(aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo],aPrazEmpt)

                        if aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,PAG_PARC] > 0
                            cInfPrazo += '<nParcela>' + StrZero(aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,PAG_PARC],3)  + '</nParcela>'
                            lInfPrazo := .T.
                        endif
                        if !Empty(aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,PAG_DVENC])
                            dDtVenc := aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,PAG_DVENC]
                            cInfPrazo += '<dVenc>' + ConvType(dDtVenc ) + '</dVenc>'
                            lInfPrazo := .T.
                        endif
                        if lInfPrazo .or. aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,PAG_VPARC] > 0
                            cInfPrazo += '<vParcela>' + ConvType(aInfPag[nInfPag,PAG_GRID_PRAZO,nPrazo,PAG_VPARC],16,2)  + '</vParcela>'
                        endif
                        if !empty(cInfPrazo)
                            cXML += '<infPrazo>'
                            cXML += cInfPrazo
                            cXML += '</infPrazo>'
                        endif
                    endif
                next

                if (SubStr(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_INDANTE],1,1) == "1")
                    cXML += '<tpAntecip>' + SubStr(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_TPANTE],1,1)  + '</tpAntecip>'
                endif

                cXML += '<infBanc>'
                if !empty(AllTrim(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CNPJEPEF]))
                    cXML += '<CNPJIPEF>' + AllTrim(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_CNPJEPEF]) + '</CNPJIPEF>'
                elseIf !empty( AllTrim( aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_BANCO] ) ) .and. !empty( AllTrim( aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_AGENCIA] ) ) 
                    cXML += '<codBanco>' + AllTrim(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_BANCO]) + '</codBanco>'
                    cXML += '<codAgencia>' + AllTrim(aInfPag[nInfPag,PAG_GRID_PAGTO,PAG_AGENCIA]) + '</codAgencia>'
                else
                    cXML += '<PIX>' + AllTrim( aInfPag[ nInfPag, PAG_GRID_PAGTO, PAG_PIX ] ) + '</PIX>'
                endif
                cXML += '</infBanc>'
            cXML += '</infPag>'
        endif
 
    next nInfPag
 
return cXML
 
/*/{Protheus.doc} 
Metodo get da estrutura InfPag
@since 26/03/2020
@version 1.0
/*/
method getInfPag() class MDFeInfPag
self:UpdControl(PAG_GRID_PAGTO) //Atualiza a variavel de controle
return aClone(self:aInfPag)
 
/*/{Protheus.doc} 
Metodo set da estrutura InfPag
@since 26/03/2020
@version 1.0
/*/
method setInfPag(aPgt) class MDFeInfPag
    local cPag       := ""
    local cCnpjEpef  := ""
    local cCodBan    := ""
    local cCodAg     := ""
    local cChavePIX  := ""
    local nComp      := 0
    local nPraz      := 0
    local nPag       := 0
    local xInfo      := ""
 
    private aInfPagtos := {}
    private aComp      := {}
    private aPraz      := {} 

    self:aInfPag := {}
 
    If ValType(aPgt) <> "U" 
        If ValType(aPgt) <> "A"
            aPgt := {aPgt}
        EndIf
    Else
        aPgt := {}
    EndIf
  
    aInfPagtos := aPgt
    
    if Len(aInfPagtos) > 0
        self:aColsPgto  := {}
        self:aColsComp  := {}
        self:aColsPrazo := {}
        aSize(self:aHeadPgto, 0)
        aSize(self:aHeadComp, 0)
        aSize(self:aHeadPrazo, 0)
        self:aHeadPgto  := self:GetHeadPgto()
        self:aHeadComp  := self:GetHeadComp()
        self:aHeadPrazo := self:GetHeadPraz()
    endif

    for nPag := 1 to Len(aInfPagtos)
 
        aAdd(self:aInfPag,{ self:GetNewLine( self:aHeadPgto )[1],{},{}})
 
        cPag := AllTrim(Str(nPag))
        
        xInfo := ""
        if ValAtrib("aInfPagtos["+cPag+"]:_XNOME") <> "U"
            xInfo := aInfPagtos[nPag]:_XNOME:TEXT
        endif
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_NOME] := PadR(xInfo, TAMTXT)
        
        xInfo := Space(20)
        if ValAtrib("aInfPagtos["+cPag+"]:_CNPJ") <> "U"
            xInfo := aInfPagtos[nPag]:_CNPJ:TEXT
        elseif ValAtrib("aInfPagtos["+cPag+"]:_CPF") <> "U"
            xInfo := aInfPagtos[nPag]:_CPF:TEXT
        elseif ValAtrib("aInfPagtos["+cPag+"]:_IDESTRANGEIRO") <> "U"
            xInfo := aInfPagtos[nPag]:_IDESTRANGEIRO:TEXT
        endif
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_CPFCNPJ] := PadR(xInfo,20)
        
        xInfo := 0
        if ValAtrib("aInfPagtos["+cPag+"]:_VCONTRATO") <> "U"
            xInfo := Val(aInfPagtos[nPag]:_VCONTRATO:TEXT)
        endif
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_VCONTRA] := xInfo

        xInfo := ""
        if !FWIsInCallStack("MDFeManage")
            if ValAtrib( "aInfPagtos[" + cPag + "]:_INDALTODESEMP" ) <> "U"
                xInfo := aInfPagtos[ nPag ]:_INDALTODESEMP:TEXT
            endIf
            self:aInfPag[ nPag, PAG_GRID_PAGTO, PAG_DESEMPE ] := xInfo
        else
            self:aInfPag[ nPag,PAG_GRID_PAGTO,PAG_DESEMPE ] := ""
        endIf

        xInfo := ""
        if ValAtrib("aInfPagtos["+cPag+"]:_INDPAG") <> "U"
            xInfo := aInfPagtos[nPag]:_INDPAG:TEXT
        endif
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_INDPAG] := PadR(AllTrim(xInfo), 1)
        
        xInfo := 0
        if ValAtrib( "aInfPagtos[" + cPag + "]:_VADIANT" ) <> "U"
            xInfo := Val(aInfPagtos[ nPag ]:_VADIANT:TEXT)
        endIf
        self:aInfPag[ nPag, PAG_GRID_PAGTO, PAG_ADIANT ] := xInfo

        xInfo := ""
        if ValAtrib( "aInfPagtos[" + cPag + "]:_INDANTECIPAADIANT" ) <> "U"
            xInfo := aInfPagtos[nPag]:_INDANTECIPAADIANT:TEXT
        endIf
       self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_INDANTE] := PadR(AllTrim(xInfo), 1)

        xInfo := ""
        if ValAtrib( "aInfPagtos[" + cPag + "]:_TPANTECIP" ) <> "U"
            xInfo := aInfPagtos[nPag]:_TPANTECIP:TEXT
        endIf
       self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_TPANTE] := PadR(AllTrim(xInfo), 1)

        cCnpjEpef   := ""
        cCodBan     := ""
        cCodAg      := ""
        cChavePIX   := ""
        if ValAtrib("aInfPagtos["+cPag+"]:_INFBANC:_CNPJIPEF") <> "U"
            cCnpjEpef := aInfPagtos[nPag]:_INFBANC:_CNPJIPEF:TEXT
        elseif ValAtrib("aInfPagtos["+cPag+"]:_INFBANC:_CODBANCO") <> "U" .and. ValAtrib("aInfPagtos["+cPag+"]:_INFBANC:_CODAGENCIA") <> "U"
            cCodBan := aInfPagtos[nPag]:_INFBANC:_CODBANCO:TEXT
            cCodAg := aInfPagtos[nPag]:_INFBANC:_CODAGENCIA:TEXT
        elseIf ValAtrib( "aInfPagtos[" + cPag + "]:_INFBANC:_PIX" ) <> "U"
            cChavePIX := aInfPagtos[nPag]:_INFBANC:_PIX:TEXT
        endif
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_CNPJEPEF] := PadR(cCnpjEpef, 14)
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_BANCO] := PadR(cCodBan, 5)
        self:aInfPag[nPag,PAG_GRID_PAGTO,PAG_AGENCIA] := PadR(cCodAg, 10)
        self:aInfPag[ nPag, PAG_GRID_PAGTO, PAG_PIX ] := PadR(cChavePIX, 60)
 
        if ValAtrib("aInfPagtos["+cPag+"]:_COMP") <> "U"
            aComp := aInfPagtos[nPag]:_COMP
            if ValTVar(aInfPagtos[nPag]:_COMP) <> "A"
                aComp := {aInfPagtos[nPag]:_COMP}
            endif
 
            for nComp := 1 to Len(aComp)
                aAdd(self:aInfPag[nPag,PAG_GRID_COMP], self:GetNewLine(self:aHeadComp)[1])
                xInfo := PadR(xInfo,2)
                if ValAtrib("aComp["+AllTrim(Str(nComp))+"]:_TPCOMP") <> "U"
                    xInfo := AllTrim(Str(Val(aComp[nComp]:_TPCOMP:TEXT)))
                endif
                self:aInfPag[nPag,PAG_GRID_COMP,nComp,PAG_TPCOMP] := xInfo

                xInfo := 0
                if ValAtrib("aComp["+AllTrim(Str(nComp))+"]:_VCOMP") <> "U"
                    xInfo := Val(aComp[nComp]:_VCOMP:TEXT)
                endif
                self:aInfPag[nPag,PAG_GRID_COMP,nComp,PAG_VCOMP] := xInfo

                xInfo := ""
                if ValAtrib("aComp["+AllTrim(Str(nComp))+"]:_XCOMP") <> "U"
                    xInfo := aComp[nComp]:_XCOMP:TEXT
                endif
                self:aInfPag[nPag,PAG_GRID_COMP,nComp,PAG_XCOMP] := PadR(xInfo, TAMTXT)
            next
        else
            aAdd(self:aInfPag[nPag,PAG_GRID_COMP], self:GetNewLine(self:aHeadComp)[1])
        endif
 
        if ValAtrib("aInfPagtos["+cPag+"]:_INFPRAZO") <> "U"
 
            aPraz := aInfPagtos[nPag]:_INFPRAZO
            if ValTVar(aInfPagtos[nPag]:_INFPRAZO) <> "A"
                aPraz := {aInfPagtos[nPag]:_INFPRAZO}
            endif
            for nPraz := 1 to Len(aPraz)
                aAdd(self:aInfPag[nPag,PAG_GRID_PRAZO], self:GetNewLine(self:aHeadPrazo)[1])
                xInfo := 0
                if ValAtrib("aPraz["+AllTrim(Str(nPraz))+"]:_NPARCELA") <> "U"
                    xInfo := Val(aPraz[nPraz]:_NPARCELA:TEXT)
                endif
                self:aInfPag[nPag,PAG_GRID_PRAZO,nPraz,PAG_PARC] := xInfo
                
                xInfo := stod("")
                if ValAtrib("aPraz["+AllTrim(Str(nPraz))+"]:_DVENC") <> "U"
                    xInfo := AllTrim(StrTran(aPraz[nPraz]:_DVENC:TEXT,"-",""))
                    xInfo := sToD(xInfo)
                endif
                self:aInfPag[nPag,PAG_GRID_PRAZO,nPraz,PAG_DVENC] := xInfo

                xInfo := 0
                if ValAtrib("aPraz["+AllTrim(Str(nPraz))+"]:_VPARCELA") <> "U"
                    xInfo := Val(aPraz[nPraz]:_VPARCELA:TEXT)
                endif
                self:aInfPag[nPag,PAG_GRID_PRAZO,nPraz,PAG_VPARC] := xInfo
            next
        else
            aAdd(self:aInfPag[nPag,PAG_GRID_PRAZO], self:GetNewLine(self:aHeadPrazo)[1])
        endif

        aAdd( self:aColsPgto , aClone(self:aInfPag[nPag,PAG_GRID_PAGTO]) )
   
    next
 
    if len(self:aInfPag) > 0
        self:aColsComp := aClone(self:aInfPag[1,PAG_GRID_COMP])
        self:aColsPrazo := aClone(self:aInfPag[1,PAG_GRID_PRAZO])
        If Valtype(self:oGetDPgto) <> "U" .And. self:oGetDPgto:nAt <> 1 .And. self:lShow
            self:oGetDPgto:GoTop()
        EndIf
    endif
return 
 
/*/{Protheus.doc} GetHeadPgto
Retorna um array com as colunas a serem exibidas na GetDados da Informações de Pagamentos
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
@return aRet -> Array com estrutura de campos do gride da Informações de Pagamentos
        aRet[x][1] - Título
        aRet[x][2] - Campo
        aRet[x][3] - Máscara
        aRet[x][4] - Tamanho
        aRet[x][5] - Casas decimais
        aRet[x][6] - Valid
        aRet[x][7] - Usado
        aRet[x][8] - Tipo
        aRet[x][9] - F3
        aRet[x][10] - X3_CONTEXT (Real = "R" ou Virtual = "V")
        aRet[x][11] - ComboBox
        aRet[x][12] - Relação (Inicializador)
        aRet[x][13] - 
        aRet[x][14] - 
        aRet[x][15] - 
        aRet[x][16] - PicVar
/*/
//-----------------------------------------------------------------------
method GetHeadPgto() class MDFeInfPag
    local aRet := {}

    aadd(aRet, {PAG_NOME, {STR0001, "MdfePgNome", "@!", TAMTXT, 0, "", "", "C", "", "R", "", "", "", "", "", ""}}) //Nome Responsável Pagamento
    aadd(aRet, {PAG_CPFCNPJ, {STR0002 , "MdfePgCgc" , "@!", 20, 0, "", "", "C", "", "R", "", "", "", "", "", ""}}) //CPF/CNPJ/ID Estrangeiro Resp. Pgto
    aadd(aRet, {PAG_VCONTRA, {STR0003, "MdfePgVCon", "@E 9, 999, 999, 999, 999.99", 15, 2, "", "", "N", "", "R", "", "", "", "", "", ""}}) //Valor Total Contrato"
    aadd(aRet, {PAG_INDPAG, {STR0004, "MdfePgIndP", "@!", 1, 0, "", "", "C", "", "R", STR0040, "", "", "", "", ""}}) //Forma de Pagamento, 0=Pagamento à vista;1=Pagamento à prazo
    aadd(aRet, {PAG_ADIANT, {STR0043, "MdfePgVAdi", "@E 9, 999, 999, 999, 999.99", 15, 2, "", "", "N", "", "R", "", "", "", "", "", ""}}) //Valor Adiantamento"
    aadd(aRet, {PAG_CNPJEPEF, {STR0005, "MdfePgIPEF", "@R 99.999.999/9999-99", 14, 0, "Empty(MdfePgIPEF).Or.CGC(Strzero(Val(MdfePgIPEF), 14))", "", "C", "", "R", "", "", "", "", "", ""}}) //CNPJ IPEF
    aadd(aRet, {PAG_BANCO, {STR0006, "MdfePgCBan", "@!", 5, 0, "", "", "C", "", "R", "", "", "", "", "", ""}}) //Cod. Banco
    aadd(aRet, {PAG_AGENCIA, {STR0007, "MdfePgABan", "@!", 10, 0, "", "", "C", "", "R", "", "", "", "", "", ""}}) //Cod. Agencia
    aadd(aRet, {PAG_PIX, {STR0008, "MdfeChvPix", "@!", 60, 0, "", "", "C", "", "R", "", "", "", "", "", ""}}) //Chave PIX
    aadd(aRet, {PAG_DESEMPE, {STR0009, "MdfeDesemp", "@!", 1, 0, "", "", "C", "", "R", STR0041, "", "", "", "", ""}}) //Oper. Alto Desempenho, 0=Não;1=Sim
    aadd(aRet, {PAG_INDANTE, {STR0044, "MdfeAntAdi", "@!", 1, 0, "", "", "C", "", "R", STR0045, "", "", "", "", ""}}) // 0=Não;1=Sim
    aadd(aRet, {PAG_TPANTE,  {STR0046, "MdfeTpAnt" , "@!", 1, 0, "", "", "C", "", "R", STR0047, "", "", "", "", ""}}) //Permissão da antecipação 0=Não permite antecipar;1=Permite antecipar as parcelas;2=Permite antecipar as parcelas mediante confirmação

    aRet := Asort(aRet,,,{|x,y| x[1] < y[1]}) //Ordena de acordo com as DEFINES
    aEval(aRet, { |x| x := x[2] } ) //Retira o primeiro array (de ordenação)
 
return aRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeadComp
Retorna um array com as colunas a serem exibidas na GetDados de Componentes do Pagamento
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
@return aRet -> Array com estrutura de campos do gride de Componentes do Pagamento
        aRet[x][1] - Título
        aRet[x][2] - Campo
        aRet[x][3] - Máscara
        aRet[x][4] - Tamanho
        aRet[x][5] - Casas decimais
        aRet[x][6] - Valid
        aRet[x][7] - Usado
        aRet[x][8] - Tipo
        aRet[x][9] - F3
        aRet[x][10] - X3_CONTEXT (Real = "R" ou Virtual = "V")
        aRet[x][11] - ComboBox
        aRet[x][12] - Relação (Inicializador)
        aRet[x][13] - 
        aRet[x][14] - 
        aRet[x][15] - 
        aRet[x][16] - PicVar
/*/
//-----------------------------------------------------------------------
method GetHeadComp() class MDFeInfPag
    local aRet := {}
 
    aadd(aRet, {PAG_TPCOMP, {STR0010, "MdfePgtCom", "@!", 2, 0, "", "", "C", "", "R", STR0042, "", "", "", "", ""}}) //Tipo Componente, 1=Vale Pedágio;2=Impostos, taxas e contribuições;3=Despesas;99=Outros;
    aadd(aRet, {PAG_VCOMP, {STR0011, "MdfePgVCom", "@E 9, 999, 999, 999.99", 13, 2, "", "", "N", "", "R", "", "", "", "", "", ""}}) //Valor Componente
    aadd(aRet, {PAG_XCOMP, {STR0012, "MdfePgXCom", "@!", TAMTXT, 0, "", "", "C", "", "R", "", "", "", "", "", ""}}) //Descrição Componente
 
    aRet := Asort(aRet,,,{|x,y| x[1] < y[1]}) //Ordena de acordo com as DEFINES
    aEval(aRet, { |x| x := x[2] } ) //Retira o primeiro array (de ordenação)
 
return aRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} GetHeadPraz
Retorna um array com as colunas a serem exibidas na GetDados de Parcelas do Pagamento
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
@return aRet -> Array com estrutura de campos do gride de Parcelas do Pagamento
        aRet[x][1] - Título
        aRet[x][2] - Campo
        aRet[x][3] - Máscara
        aRet[x][4] - Tamanho
        aRet[x][5] - Casas decimais
        aRet[x][6] - Valid
        aRet[x][7] - Usado
        aRet[x][8] - Tipo
        aRet[x][9] - F3
        aRet[x][10] - X3_CONTEXT (Real = "R" ou Virtual = "V")
        aRet[x][11] - ComboBox
        aRet[x][12] - Relação (Inicializador)
        aRet[x][13] - 
        aRet[x][14] - 
        aRet[x][15] - 
        aRet[x][16] - PicVar
/*/
//-----------------------------------------------------------------------
method GetHeadPraz() class MDFeInfPag
    local aRet := {}
 
    aadd(aRet, {PAG_PARC, {STR0013, "MdfePgnPar", "@E 999", 3, 0, "", "", "N", "", "R", "", "", "", "", "", ""}}) //Número da parcela
    aadd(aRet, {PAG_VPARC, {STR0014, "MdfePgvPar", "@E 9,999,999,999.99", 13, 2, "", "", "N", "", "R", "", "", "", "", "", ""}}) //Valor Parcela
    aadd(aRet, {PAG_DVENC, {STR0015, "MdfePgVenc", "@D", 8, 0, "", "", "D", "", "R", "", "ctod('//')", "", "", "", ""}}) //Vencimento da parcela
 
    aRet := Asort(aRet,,,{|x,y| x[1] < y[1]}) //Ordena de acordo com as DEFINES
    aEval(aRet, { |x| x := x[2] } ) //Retira o primeiro array (de ordenação)
 
return aRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} GetNewLine
Realiza o carregamento da 1 linha da aLinhas em branco na aCols
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
/*/
//-----------------------------------------------------------------------
method GetNewLine(aHeader) class MDFeInfPag
    local aRet       := {}
    local nI         := 0
    local nLen       := 0
    local nLenHeader := 0
 
    default aHeader := {}
 
    nLenHeader := Len(aHeader)
 
    //Cria um linha do aLinhas em branco
    aAdd(aRet, Array( nLenHeader+1 ) )
    nLen := Len(aRet)
    for nI := 1 to nLenHeader
        if aHeader[nI][8] == "N" //Numericos
            aRet[nLen,nI] := 0
        elseif aHeader[nI][8] == "D"
            aRet[nLen,nI] := ctod("  /  /    ")
        else //Caracter
            aRet[nLen,nI] := space(aHeader[nI][4])
        endif
    next nI
 
    //Atribui .F. para a coluna que determina se alinha do aLinhas esta deletada
    aRet[nLen][nLenHeader+1] := .F.
 
return aRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} CreateGrid
Realiza a criação da grid para manipulação das informações InfPag
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
/*/
//-----------------------------------------------------------------------
method CreateGrid(oPainel, nOpc, aPosPgto, aPosComp, aPosPrazo, lGroup) class MDFeInfPag 
    local lRet       := .F.
    local ntopGD     := 0
    local nLeftGD    := 0
    local nDownGD    := 0
    local nRightGD   := 0
    local nCont      := 0
    local aEditCamp  := {}
 
    default nOpc        := 3
    default aPosPgto    := {1.3, 0.5, 9.3, 46}
    default aPosComp    := {10.5, 0.6, 21.5, 22.7}
    default aPosPrazo   := {10.5, 23.7, 21.5, 46}
    default lGroup      := .T.

    begin sequence
 
    if valtype(oPainel) <> "O"
        break
    endif

    if lGroup
		oBoxPgto:= TGROUP():Create(oPainel)
		oBoxPgto:cName			    := "oBoxPgto"
		oBoxPgto:cCaption		    := STR0016 //Informações de Pagamentos
		oBoxPgto:nLeft			    := MDFeResol(0.5,.T.)
		oBoxPgto:nTop			    := MDFeResol(0.3,.F.)
		oBoxPgto:nWidth			    := MDFeResol(91.7,.T.)
		oBoxPgto:nHeight		    := MDFeResol(43.2,.F.)
		oBoxPgto:lShowHint		    := .F.
		oBoxPgto:lReadOnly		    := .F.
		oBoxPgto:Align			    := 0
		oBoxPgto:lVisibleControl    := .T.
	
	    oBoxComp:= TGROUP():Create(oPainel)
		oBoxComp:cName              := "oBoxComp"
		oBoxComp:cCaption           := STR0017 //Componentes do Pagamento
		oBoxComp:nLeft              := MDFeResol(0.5,.T.)
		oBoxComp:nTop               := MDFeResol(18.5,.F.)
		oBoxComp:nWidth             := MDFeResol(45.5,.T.)
		oBoxComp:nHeight            := MDFeResol(28.5,.F.)
		oBoxComp:lShowHint          := .F.
		oBoxComp:lReadOnly          := .F.
		oBoxComp:Align              := 0
		oBoxComp:lVisibleControl    := .T.

		oBoxPrazo:= TGROUP():Create(oPainel)
		oBoxPrazo:cName             := "oBoxPrazo"
		oBoxPrazo:cCaption          := STR0018 //Parcelas do Pagamento
		oBoxPrazo:nLeft 	        := MDFeResol(46.7,.T.)
		oBoxPrazo:nTop  	        := MDFeResol(18.5,.F.)
		oBoxPrazo:nWidth 	        := MDFeResol(45.5,.T.)
		oBoxPrazo:nHeight 	        := MDFeResol(28.5,.F.)
		oBoxPrazo:lShowHint         := .F.
		oBoxPrazo:lReadOnly         := .F.
		oBoxPrazo:Align             := 0
		oBoxPrazo:lVisibleControl   := .T.
	EndIf
    //Monta a GetDados "Inf pag"
    ntopGD      := MDFeResol(aPosPgto[1],.F.)
    nLeftGD     := MDFeResol(aPosPgto[2],.T.)
    nDownGD     := MDFeResol(aPosPgto[3],.F.)
    nRightGD    := MDFeResol(aPosPgto[4],.T.)
    
    for nCont:= 1 to len(self:aHeadPgto) 
        if !FWIsInCallStack("MDFeManage")
            Aadd(aEditCamp, self:aHeadPgto[nCont][2])
        elseif self:aHeadPgto[nCont][2] <> self:aHeadPgto[10][2]
            Aadd(aEditCamp, self:aHeadPgto[nCont][2])
        endif
    next
    self:oGetDPgto := MsNewGetDados():New(ntopGD,nLeftGD,nDownGD,nRightGD,nOpc,{|| self:VldLinePgt(PAG_GRID_PAGTO)},,,aEditCamp,,,,,,oPainel,self:aHeadPgto,self:aColsPgto, {|| self:AtuGridPgt() })

    //Monta a GetDados "Comp"
    ntopGD      := MDFeResol(aPosComp[1],.F.)
    nLeftGD     := MDFeResol(aPosComp[2],.T.)
    nDownGD     := MDFeResol(aPosComp[3],.F.)
    nRightGD    := MDFeResol(aPosComp[4],.T.)
    self:oGetDPComp := MsNewGetDados():New(ntopGD,nLeftGD,nDownGD,nRightGD,nOpc,{|| self:VldLinePgt(PAG_GRID_COMP)},,,,,,,,,oPainel,self:aHeadComp,self:aColsComp)

    //Monta a GetDados "Informações de Prazo"
    ntopGD      := MDFeResol(aPosPrazo[1],.F.)
    nLeftGD     := MDFeResol(aPosPrazo[2],.T.)
    nDownGD     := MDFeResol(aPosPrazo[3],.F.)
    nRightGD    := MDFeResol(aPosPrazo[4],.T.)
    self:oGetDPPraz := MsNewGetDados():New(ntopGD,nLeftGD,nDownGD,nRightGD,nOpc,{|| self:VldLinePgt(PAG_GRID_PRAZO)},,,,,,,,,oPainel,self:aHeadPrazo,self:aColsPrazo)

    self:refresh()

    lRet := .T.
 
    end sequence
 
return lRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} Show
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
/*/
//-----------------------------------------------------------------------
method Show() class MDFeInfPag 
    self:oGetDPComp:show()
    self:oGetDPPraz:show()
    self:oGetDPgto:show()
    self:lShow := .T.
return

//----------------------------------------------------------------------
/*/{Protheus.doc} ValidaOk
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
/*/
//-----------------------------------------------------------------------
method ValidaOk(lVldVazio) class MDFeInfPag 
    Local lRet          := .T.
    Local nI            := 0
    Default lVldVazio   := .F.

    //Colocar aqui as validações de todos os grides (botão OK)
    self:UpdControl(PAG_GRID_PAGTO) //Atualiza a variavel de controle

    For nI := 1 To Len(self:getInfPag())
        lRet := Self:VldLinePgt(PAG_GRID_PAGTO, nI, .T., lVldVazio)
        If !lRet
            Exit
        EndIf
    Next nI

return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Refresh
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
/*/
//-----------------------------------------------------------------------
method Refresh() class MDFeInfPag 
    local lRet := .T.
    self:AtuGridPgt(1)
    self:oGetDPPraz:Refresh(.T.)
    self:oGetDPComp:Refresh(.T.)
    self:oGetDPgto:Refresh(.T.)
return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} ActDesact
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
/*/
//-----------------------------------------------------------------------
method ActDesact(lActivate) class MDFeInfPag 
    local lRet := .T.

    If lActivate
        self:oGetDPPraz:ENABLE()
        self:oGetDPComp:ENABLE()
        self:oGetDPgto:ENABLE()
    Else
        self:oGetDPPraz:DISABLE()
        self:oGetDPComp:DISABLE()
        self:oGetDPgto:DISABLE()
    EndIf
return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} AtuGridPgt
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
@return aRet -> Array com estrutura de campos do gride
/*/
//-----------------------------------------------------------------------
method AtuGridPgt(nPosPgt) class MDFeInfPag
    local lRet      := .T.
 
    default nPosPgt := self:oGetDPgto:nAt
 
    if Len(self:aInfPag) < nPosPgt
        aAdd(self:aInfPag,{aClone(self:oGetDPgto:aCols[self:oGetDPgto:nAt]),{},{}})
    endif
 
    if Len(self:aInfPag) >= nPosPgt
        self:oGetDPComp:aCols := aClone(iif(Len(self:aInfPag[nPosPgt][PAG_GRID_COMP]) > 0, self:aInfPag[nPosPgt][PAG_GRID_COMP], self:GetNewLine( self:aHeadComp)))
        self:aColsComp := self:oGetDPComp:aCols
 
        self:oGetDPPraz:aCols := aClone(iif(Len(self:aInfPag[nPosPgt][PAG_GRID_PRAZO]) > 0,self:aInfPag[nPosPgt][PAG_GRID_PRAZO], self:GetNewLine(self:aHeadPrazo)))
        self:aColsPrazo := self:oGetDPPraz:aCols

        If self:lShow
            self:oGetDPComp:Refresh(.F.)
            self:oGetDPPraz:Refresh(.F.)
        EndIf
    endif
    self:oGetDPgto:aCols := self:aColsPgto

return lRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} VldLinePgt
 
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
@return lRet -> .T. / .F.
/*/
//-----------------------------------------------------------------------
method VldLinePgt(nOrig, nLinha, lAtuControl, lVldVazio) class MDFeInfPag
    Local lRet      := .T.
    Local nI        := 0
    Local nQtdLinha := 0
    Local nQtdValido:= 0
    Local cErro     := ""
    Local cErroPg   := ""
    Local cErroCo   := ""
    Local cErroPr   := ""
    Local aVldPag   := {}
    Local aPgtoEmpt := aClone(self:GetNewLine(self:aHeadPgto)[1])
    Local aCompEmpt := aClone(self:GetNewLine(self:aHeadComp)[1])
    Local aPrazEmpt := aClone(self:GetNewLine(self:aHeadPrazo)[1])

    Default nLinha      := self:oGetDPgto:nAt
    Default lAtuControl := .F.
    Default lVldVazio   := .F.

    //Colocar aqui as validações das linhas
    If !lAtuControl
        self:UpdControl(nOrig)
    EndIf

    If Self:lShow
        aVldPag := aClone(self:getInfPag())
        If nOrig == PAG_GRID_PAGTO
            If !aVldPag[nLinha,PAG_GRID_PAGTO,Len(aVldPag[nLinha,PAG_GRID_PAGTO])] .And. ;
                !aCompare(aVldPag[nLinha,PAG_GRID_PAGTO],aPgtoEmpt)
                
                If !Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_NOME]) .And. Len(AllTrim(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_NOME])) <= 2
                    cErroPg += STR0019 + ENTER //- Nome Responsável Pagamento deve ter no mínimo 3 caracteres.
                    lRet := .F.
                Endif

                If Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_CPFCNPJ])
                    cErroPg += STR0020 + ENTER //- CPF/CNPJ/ID Estrangeiro Resp. Pgto.
                    lRet := .F.
                ElseIf Len(AllTrim(StrTran(StrTran(StrTran(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_CPFCNPJ],"."),"/"),"-"))) <= 4
                    cErroPg += STR0021 + ENTER //- CPF/CNPJ/ID Estrangeiro Resp. Pgto dever ter mais que 5 caracteres
                    lRet := .F.
                EndIf

                If Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_VCONTRA])
                    cErroPg += STR0022 + ENTER //- Valor Total Contrato.
                    lRet := .F.
                EndIf

                If Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_INDPAG])
                    cErroPg += STR0023 + ENTER //- Forma de Pagamento.
                    lRet := .F.
                EndIf

                If Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_CNPJEPEF]) .And. (Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_BANCO]) .Or.;
                    Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_AGENCIA])) .and. empty( aVldPag[ nLinha, PAG_GRID_PAGTO, PAG_PIX ] )
                    cErroPg += STR0024 + ENTER //- CNPJ IPEF ou Cod. Banco e Cod. Agencia ou Chave PIX.
                    lRet := .F.
                ElseIf !Empty(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_BANCO]) .And. Len(AllTrim(aVldPag[nLinha,PAG_GRID_PAGTO,PAG_BANCO])) < 3
                    cErroPg += STR0025 + ENTER //- Cod. Banco deve ter de 3 a 5 caracteres.
                    lRet := .F.
                elseIf !empty( aVldPag[ nLinha, PAG_GRID_PAGTO, PAG_PIX ] ) .and. len( allTrim( aVldPag[ nLinha, PAG_GRID_PAGTO, PAG_PIX ] ) ) < 2
                    cErroPg += STR0026 + ENTER //- Chave PIX deve ter de 2 a 60 caracteres.
                    lret := .F.
                EndIf

                If !Empty(cErroPg)
                    cErroPg := STR0027 + ENTER +  cErroPg //"Por favor preencher o(s) seguinte(s) campo(s) das Informações de Pagamentos:" 
                EndIf
            
                //Validando o tipo do componente
                nQtdLinha := 0
                For nI := 1 To Len(aVldPag[nLinha,PAG_GRID_COMP])
                    If !aVldPag[nLinha,PAG_GRID_COMP,nI,Len(aVldPag[nLinha,PAG_GRID_COMP,nI])] .And. ;
                        (lVldVazio .Or. !aCompare(aVldPag[nLinha,PAG_GRID_COMP,nI],aCompEmpt))
                        nQtdLinha++
                        if Empty(aVldPag[nLinha,PAG_GRID_COMP,nI,PAG_TPCOMP])
                            cErroCo += STR0028 + ENTER // - Tipo Componente.
                            lRet := .F.
                        EndIf
                        if Empty(aVldPag[nLinha,PAG_GRID_COMP,nI,PAG_VCOMP])
                            cErroCo += STR0029 + ENTER // - Valor Componente.
                            lRet := .F.
                        EndIf
                        If aVldPag[nLinha,PAG_GRID_COMP,nI,PAG_TPCOMP] == '99' .And. Empty(aVldPag[nLinha,PAG_GRID_COMP,nI,PAG_XCOMP])
                            cErroCo += STR0030 + ENTER // - Descrição Componente.
                            lRet := .F.
                        EndIf
                    EndIf
                    If !lRet
                    Exit
                    EndIf
                Next nI
                If nQtdLinha == 0
                    cErroCo += STR0031 + ENTER // - Informar ao menos uma linha de componente do pagamento.
                    lRet := .F.
                EndIf
                If !Empty(cErroCo)
                    cErroCo := STR0032 + AllTrim(Str(nQtdLinha)) + ":" + ENTER + cErroCo //Por favor preencher o(s) seguinte(s) campo(s) do Componente do Pagamento - Linha || :
                EndIf

                //Validando o tipo do componente
                nQtdLinha := 0
                nQtdValido := 0
                For nI := 1 To Len(aVldPag[nLinha,PAG_GRID_PRAZO])
                    If !aVldPag[nLinha,PAG_GRID_PRAZO,nI,Len(aVldPag[nLinha,PAG_GRID_PRAZO,nI])] .And.;
                        (lVldVazio .Or. !aCompare(aVldPag[nLinha,PAG_GRID_PRAZO,nI],aPrazEmpt))
                        nQtdLinha++
                        iif(!aCompare(aVldPag[nLinha,PAG_GRID_PRAZO,nI],aPrazEmpt),nQtdValido++,Nil)
                        if aVldPag[nLinha,PAG_GRID_PAGTO,PAG_INDPAG] == '1' .And. (Empty(aVldPag[nLinha,PAG_GRID_PRAZO,nI,PAG_VPARC]) .or. Empty(aVldPag[nLinha,PAG_GRID_PRAZO,nI,PAG_DVENC]))
                            cErroPr += STR0034 // - Valor parcela e/ou Vencimento da Parcela.
                            lRet := .F.
                        EndIf
                    EndIf
                    If !lRet
                        Exit
                    EndIf
                Next nI
                If nQtdLinha == 0 .And. aVldPag[nLinha,PAG_GRID_PAGTO,PAG_INDPAG] == '1' //a prazo
                    cErroPr += STR0035 + ENTER // - Informar ao menos uma linha da parcela do pagamento quando forma de pagamento à Prazo.
                    lRet := .F.
                ElseIf nQtdValido > 0 .And. aVldPag[nLinha,PAG_GRID_PAGTO,PAG_INDPAG] == '0' //a vista
                    cErroPr += STR0036 + ENTER // - Não deve ser informado nenhuma linha da parcela do pagamento quando forma de pagamento à Vista.
                    lRet := .F.
                ElseIf !Empty(cErroPr)
                    cErroPr := STR0037 + AllTrim(Str(nQtdLinha))  + STR0033 + ENTER + cErroPr // "Por favor preencher o(s) seguinte(s) campo(s) da Parcela do Pagamento - Linha " || :
                EndIf
            EndIf
        EndIf

        aSize(aVldPag,0)
        aVldPag := Nil
        aSize(aPgtoEmpt,0)
        aPgtoEmpt := Nil
        aSize(aCompEmpt,0)
        aCompEmpt := Nil
        aSize(aPrazEmpt,0)
        aPrazEmpt := Nil

        If !lRet
            cErro += iif(!Empty(cErroPg),cErroPg + ENTER+ENTER,"")
            cErro += iif(!Empty(cErroCo),cErroCo + ENTER+ENTER,"")
            cErro += iif(!Empty(cErroPr),cErroPr + ENTER+ENTER,"")
            MsgInfo(cErro, STR0038) //Atenção
        EndIf
    EndIf

return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} UpdControl
 Atualiza variavel de controle dos grides
 
@author Felipe Sales Martinez
@since 23.03.2020
@version P12
@return Nil
/*/
//-----------------------------------------------------------------------
method UpdControl(nOrig) class MDFeInfPag
    local nPosPgt := self:oGetDPgto:nAt

    if len(self:aInfPag) == 0
        aAdd(self:aInfPag,{aClone(self:oGetDPgto:aCols[self:oGetDPgto:nAt]),{},{}})
    endif

    if nOrig == PAG_GRID_PAGTO
        aSize(self:aInfPag[nPosPgt,PAG_GRID_PAGTO],0)
        self:aInfPag[nPosPgt,PAG_GRID_PAGTO] := aClone(self:oGetDPgto:aCols[nPosPgt])
    endif
 
    aSize(self:aInfPag[nPosPgt,PAG_GRID_COMP],0)
    self:aInfPag[nPosPgt,PAG_GRID_COMP] := aClone(self:oGetDPComp:aCols)
 
    aSize(self:aInfPag[nPosPgt,PAG_GRID_PRAZO],0)
    self:aInfPag[nPosPgt,PAG_GRID_PRAZO] := aClone(self:oGetDPPraz:aCols)
 
return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeResol
Montagem da Dialog do Gerenciador do MDFe
 
@author Natalia Sartori
@since 10/02/2014
@version P11
 
@param  nPerc  - Valor em percentual de video desejado
@return lWidht - Flag para controlar se a medida e vertical ou horz
/*/
//-----------------------------------------------------------------------
static function MDFeResol(nPerc,lWidth)
    local nRet       := 0
    local nResHor    := GetScreenRes()[1] //Tamanho resolucao de video horizontal
    local nResVer    := GetScreenRes()[2] //Tamanho resolucao de video vertical
    default lWidth := .F.

    if lWidth
        nRet := nPerc * nResHor / 100
    else
        nRet := nPerc * nResVer / 100
    endif
return nRet
 
//----------------------------------------------------------------------
/*/{Protheus.doc} ConvType
Tratamento da informação para o XML
 
 
/*/
//-----------------------------------------------------------------------
static function ConvType(xValor,nTam,nDec)
    local cNovo := ""
 
    default nDec    := 0
 
    do case
        case ValType(xValor)=="N"
            if xValor <> 0
                cNovo := AllTrim(Str(xValor,nTam,nDec)) 
            else
                cNovo := "0"
            endif
        case ValType(xValor)=="D"
            cNovo := FsDateConv(xValor,"YYYYMMDD")
            cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
        case ValType(xValor)=="C"
            if nTam==Nil
                xValor := AllTrim(xValor)
            endif
            default nTam := TAMTXT
            cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
    endcase
 
return cNovo
 
//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeInfPag
Função para retorna as informações do pagamento para o rdmake
 
@since 26/03/2020
@version P12
/*/
//-----------------------------------------------------------------------
function MDFeInfPag()
    local aRet := {"",{}}
 
    if ValAtrib('oDlgPgt') == "O"
        aRet[1] := oDlgPgt:XmlInfPag()
        aRet[2] := oDlgPgt:getInfPag()
    endif
 
return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} aCompare
Compara os conteudos dos arrays informados
@autor Felipe Sales Martinez
@since 27/03/2020
@version P12
/*/
//-----------------------------------------------------------------------
Static Function aCompare(xVal1,xVal2)
Local cT1 := valtype(xVal1)
Local cT2 := valtype(xVal2)
Local nI 

If cT1 != cT2
	// Os tipos são diferentes ? A comparação retorna .F.
	Return .F.
Endif

If cT1 != 'A'
	// Nao estamos comparando arrays. Utiliza o operador de igualdade entre as variáveis 
	Return xVal1 == xVal2
Endif

If len(xVal1) != len(xVal2)
	// Estamos comparando arrays. O tamanho deles é diferente ? A comparação retorna .F. 
	Return .F.
Endif

// Compara cada elemento do array recursivamente 
For nI := 1 to len(xVal1)
	If !ACompare( xVal1[nI] , xVal2[nI] )
		// No primeiro elemento que a compparação não for verdadeira, já retorna .F. 
		Return .F. 
	Endif
Next

// Chegou até o final, os elementos dos dois arrays tem o mesmo conteúdo 
Return .T.

/*/{Protheus.doc} ValAtrib
Função utilizada para substituir o type onde não seja possível a sua 
retirada para não haver ocorrência indevida pelo SonarQube.

@author 	Felipe Sales Martinez
@since 		30/03/2020
@version 	12
@return 	Nil
/*/
//-----------------------------------------------------------------------
static Function ValAtrib(atributo)
Return (type(atributo) )

/*/{Protheus.doc} ValTVar
Função utilizada para substituir o type onde não seja possivél a sua 
retirada para não haver ocorrencia indevida pelo SonarQube.

@author 	Felipe Sales Martinez
@since 		30/03/2020
@version 	12
@return 	Nil
/*/
static Function ValTVar(xVariavel)
Return Valtype(xVariavel)

/*/{Protheus.doc} ValTVar
Função utilizada para substituir o type onde não seja possivél a sua 
retirada para não haver ocorrencia indevida pelo SonarQube.

@author 	Felipe Sales Martinez
@since 		30/03/2020
@version 	12
@return 	Nil
/*/
static Function VldCnpj(cFiled)

If !Empty(cFiled) .And. CGC(cFiled) .And. Len(AllTrim(cFiled)) == 14
    lRet := .F.
    msginfo(STR0039, STR0038) // O CNPJ informado não é valido, Atenção
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} SpecCharc
Função que retira os caracteres especiais de um texto

@author		Felipe Sales Martinez (FSM)
@since 		07.08.2019
@version 	1.00
@param		cTexto = Texto para retirar caracteres especiais
@return		cTexto = Texto sem caracteres especiais
/*/
//-----------------------------------------------------------------------
Static Function SpecCharc(cTexto)

Local nI		:= 0
Local aCarac 	:= {}

Aadd(aCarac,{"Á","A"})
Aadd(aCarac,{"À","A"})
Aadd(aCarac,{"Â","A"})
Aadd(aCarac,{"Ã","A"})
Aadd(aCarac,{"á","a"})
Aadd(aCarac,{"à","a"})
Aadd(aCarac,{"â","a"})
Aadd(aCarac,{"ã","a"})
Aadd(aCarac,{"É","E"})
Aadd(aCarac,{"Ê","E"})
Aadd(aCarac,{"é","e"})
Aadd(aCarac,{"ê","e"})
Aadd(aCarac,{"Í","I"})
Aadd(aCarac,{"í","i"})
Aadd(aCarac,{"Ó","O"})
Aadd(aCarac,{"Ô","O"})
Aadd(aCarac,{"Õ","O"})
Aadd(aCarac,{"ó","o"})
Aadd(aCarac,{"ô","o"})
Aadd(aCarac,{"õ","o"})
Aadd(aCarac,{"Ú","U"})
Aadd(aCarac,{"ú","u"})
Aadd(aCarac,{"Ç","C"})
Aadd(aCarac,{"ç","c"})
Aadd(aCarac,{"<",""})
Aadd(aCarac,{">",""})

// Ignora caracteres Extendidos da tabela ASCII
For nI := 128 To 255
	Aadd(aCarac,{Chr(nI)," "})  // Tab
Next nI

For nI := 1 To Len(aCarac)
	If aCarac[nI, 1] $ cTexto
		cTexto := StrTran(cTexto, aCarac[nI,1], aCarac[nI,2])
	EndIf
Next nI

Return cTexto
