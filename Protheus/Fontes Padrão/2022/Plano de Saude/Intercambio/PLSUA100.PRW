#include "PROTHEUS.CH"

//Funções utilizadas no PTU A300
//-------------------------------------------------------------------
/*/{Protheus.doc} A100EstCiv
Retorna o estado civil no padrão do Manual do Intercambio

@author  Lucas Nonato
@version P12
@since   20/04/2018
/*/
//-------------------------------------------------------------------
function A100EstCiv(cEstCiv)
local cRetorno
	
    do Case
       	Case cEstCiv == "C"
       		cRetorno := "M"
       	Case cEstCiv == "D"
       		cRetorno := "D"
       	Case cEstCiv == "M"
       		cRetorno := "M"
       	Case cEstCiv == "Q"
       		cRetorno := "D"
       	Case cEstCiv == "S"
       		cRetorno := "S"
       	Case cEstCiv == "V"
       		cRetorno := "W"
       	Otherwise
       		cRetorno := "S"
    EndCase	

return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VeUsupBloq
Retorna a data de bloqueio do beneficiario como caracter, utilizado no PLSUA300

@author  Lucas Nonato
@version P12
@since   20/04/2018
/*/
//-------------------------------------------------------------------
Function VEUSOPBLOQ(cMatricula,cTipoReg,dFim,cBlqOpc)
Local cDtBlo := VeUsuBloq(cMatricula,cTipoReg,dFim)
Default cBlqOpc := Space(8)

If Empty(cDtBlo) .And. !Empty(cBlqOpc)
	cDtBlo := cBlqOpc
EndIf

Return cDtBlo
//-------------------------------------------------------------------
/*/{Protheus.doc} VeUsuBloq
Retorna a data de bloqueio do beneficiario

@author  Lucas Nonato
@version P12
@since   20/04/2018
/*/
//-------------------------------------------------------------------
static function VeUsuBloq(cMatricula,cTipoReg,dFim,cRN412,cMotBlo,cNivBlq)
local cQryBloq	:= ""
local cDatBlo	:= ""

cRN412	:= Space(1)	
cMotBlo := Space(3)
cNivBlq := Space(1)	

// Verifica se o usuario esta bloqueado.
cQryBloq  := " SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ, BCA_SOL412 FROM " + RetSQLName("BCA") + " BCA "
cQryBloq  += " WHERE BCA_FILIAL = '" + xFilial("BCA") + "' AND BCA_MATRIC = '" + cMatricula + "' AND"
cQryBloq  += " BCA_TIPREG = '" + cTipoReg + "' AND"
cQryBloq  += " BCA_DATA <= '" + dtos(dFim) + "' AND "	
cQryBloq  += " BCA.D_E_L_E_T_ <> '*' "
cQryBloq  += " ORDER BY R_E_C_N_O_, BCA_DATA"

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryBloq),"BCAQRY",.F.,.T.)

while !BCAQRY->(eof())
	if BCAQRY->BCA_TIPO == "0" //Bloqueio
    	cDatBlo := BCAQRY->BCA_DATA
		cRN412	:= iif(BCAQRY->BCA_SOL412 == '1','S','N')
        cMotBlo := BCAQRY->BCA_MOTBLO	
        cNivBlq := BCAQRY->BCA_NIVBLQ
	else
		cDatBlo := Space(8)
		cRN412  := Space(1)	    	
 	endif 
 	BCAQRY->(DbSkip())
enddo

BCAQRY->(dbclosearea())

return cDatBlo

//-------------------------------------------------------------------
/*/{Protheus.doc} A100CodDep
Retorna o código do dependente no padrão do Manual do Intercambio

@author  Lucas Nonato
@version P12
@since   20/04/2018
/*/
//-------------------------------------------------------------------
function A100CodDep(cTipReg, cGrauPa)
local cGraDep
	
//Alimenta codigo de dependecia PTU	
If cTipReg == "00"
	cGraDep := "00" //Titular
Else                   
   If Empty(cGrauPa)
       cGrauPa :=  cTipReg
    EndIf
	
    If BRP->(MsSeek(xFilial("BRP")+cGrauPa))
    	cGraDep := BRP->BRP_CODPTU
    Else                          
    	cGraDep := "60" //Outros dependentes
    Endif
Endif

return cGraDep