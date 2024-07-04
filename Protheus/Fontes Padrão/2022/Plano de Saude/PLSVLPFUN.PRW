#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"       	
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"

STATIC lPLSBB8SK 	:= existBlock("PLSBB8SK")
STATIC UID_VLTBPR 	:= 'PLVLTBPR'
Static lPLNUMCOI	:= Existblock("PLUNMCOI")

/*/{Protheus.doc} PLAHESP

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLAHESP(cTrbTpPre,cCodPad,cCodPro)
local lRet    := .f.
local aNiveis := PLSESPNIV(cCodPad)

//Classe Rda x Procedimentos
cSQL := " SELECT R_E_C_N_O_ REC FROM " + BE0->(retSqlName("BE0")) + " WHERE "
cSQL += " BE0_FILIAL = '" + xFilial("BE0") + "' AND "
cSQL += " BE0_CODIGO = '" + cTrbTpPre 	+ "' AND "
cSQL += " BE0_CODPAD = '" + cCodPad 	+ "' AND "

cSQL += PLREQNI("BE0", "BE0_CODPRO", aNiveis[2], allTrim(cCodPro))

cSQL += "D_E_L_E_T_ = ' ' "

cSQL +=  " ORDER BY BE0_NIVEL DESC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

if ! PLSAUTPDIR->(eof())
	lRet := .t.
	BE0->(dbGoTo(PLSAUTPDIR->(REC)))
endIf

PLSAUTPDIR->(dbCloseArea())

return(lRet)

/*/{Protheus.doc} PLINTERC
Retorna se um pagto ou cobr. dever obedecer regras de interc 
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLINTERC(cTipo, cCodRda, cOpeOri, cRegPag, cRegCob)
local aAreaBAU	 := BAU->(getArea())
local cCodOpeInt := ""
local cTipPre    := ""  
local lInterc    := .f.     
local lChangeBAU := .f.    

default cRegPag	 := ""
default cRegCob	 := ""

if BAU->BAU_CODIGO <> cCodRda
   BAU->(dbSetOrder(1))
   BAU->(msSeek(xFilial("BAU")+cCodRda))
   lChangeBAU := .t.
endIf        

cTipPre := BAU->BAU_TIPPRE

//Pagamento
if cTipo == "1" 
	
	//Estou pagando um usuario meu indo a outra operadora
   	if cTipPre == getNewPar("MV_PLSTPIN","OPE") .or. cRegPag == '2' 
      
		lInterc    := .t.
        cCodOpeInt := BAU->BAU_CODOPE
	
	//Estou pagando uma RDA minha atendendo um usuario de outra operadora
   	elseIf cOpeOri <> PLSINTPAD() 
   
		if getNewPar("MV_PLDEGRP",'0') == "1" .or. cRegPag == '1'
         	lInterc    := .T.
			cCodOpeInt := cOpeOri
      	else
         	lInterc    := .F.
      	endIf
   
   //nao e intercambio, e um usuario meu rda minha   
   else   
		lInterc    := .f.
		cCodOpeInt := ""
   endIf     

//Recebimento
elseIf cTipo == "2"  

   if cOpeOri <> PLSINTPAD() .or. cRegCob == '2'
		
		lInterc    := .t.
		cCodOpeInt := cOpeOri
		
   elseIf cTipPre == getNewPar("MV_PLSTPIN","OPE") .or. cRegCob == '1'
		lInterc    := .f. //cobro sempre a regra contratado com meu usuario, mesmo ele sendo atendido em outra
   else
		lInterc    := .f.
   endIf   

endIf   

if lChangeBAU
	BAU->(restArea(aAreaBAU))
endIf	

return( {lInterc, cCodOpeInt, cTipPre } )


	/*/{Protheus.doc} PLCALHE
Funcao criada para otimizar a busca do percentual de horario especial
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLCALHE(cCodAti,dDatCir,cHorCir,cCodRda,cCodLoc,cHorFim)
local nPerHorEsp	:= 0
local cDiaSem		:= iIf(PLSFeriado(dDatCir,.t.,cCodRda,cCodLoc), "8", allTrim(str(Dow(dDatCir))))
local cHorPrFinal   := 0
local cMinPrFinal	:= 0
local cHorPrInici	:= 0
local cMinPrInici	:= 0
local nTotPrest1	:= 0
local nTotPrest2	:= 0
local nTotPrest		:= 0
local cIni			:= ""
local cFinal		:= ""
local nHoraFinal	:= 0
local nMinFinal		:= 0
local nHoraIni		:= 0
local nMinIni		:= 0
local nTotHorE1		:= 0
local nTotHorE2		:= 0
local nTotHorE		:= 0

default cHorFim 	:= ""


//criei um select para melhorar a performance
cSql := "SELECT DISTINCT BAS_DIASEM, BAR_HORINI,BAR_HORFIN,BAR_VIGINI,BAR_VIGFIN,BAR_PERC "
cSql += "  FROM " + retSqlName("BAS") + " BAS," + retSqlName("BAR") + " BAR"
cSql += " WHERE BAS_FILIAL = '" + xFilial('BAS') + "' "
cSql += "   AND BAS_CODATI = '" + cCodAti + "'"
cSql += "   AND BAS_DIASEM = '" + cDiaSem + "'"
cSql += "   AND BAR_FILIAL = '" + xFilial('BAR') + "' "
cSql += "   AND BAR_CODIGO = BAS_CODIGO "
cSql += "   AND BAS.D_E_L_E_T_ = ' ' "

if ! empty(dDatCir)
	cSql += " AND BAR_VIGINI <= '" + dtos(dDatCir) + "' "
	cSql += " AND ( BAR_VIGFIN >= '" + dtos(dDatCir) + "' OR BAR_VIGFIN = ' ' ) "
endIf

cSql += " AND BAR.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbHesp",.f.,.t.)
	
if !TrbHesp->(eof())

	plsTField("TrbHesp",.f.,{ "BAR_VIGFIN","BAR_VIGFIN","BAR_PERC" } )

	if (SubStr(cHorFim,1,2) == '00')
		cHorFim := '24' + SubStr(cHorFim,3,4)
	endif 

	cHorPrFinal := val(SubStr(cHorFim,1,2))     // trabalho total do prestador independente do regime especial 
	cMinPrFinal := val(SubStr(cHorFim,3,4))                            
	cHorPrInici := val(SubStr(cHorCir,1,2))                            
	cMinPrInici := val(SubStr(cHorCir,3,4))      

	nTotPrest1 := (cHorPrFinal) * 60 + cMinPrFinal
	nTotPrest2 := (cHorPrInici) * 60 + cMinPrInici
	nTotPrest  := (nTotPrest1 - nTotPrest2)/2
					
	while !TrbHesp->(eof()) 

			if(cHorCir > TrbHesp->BAR_HORINI)
				cIni := cHorCir 
			else
				cIni := TrbHesp->BAR_HORINI
			endif 

			if(cHorFim < TrbHesp->BAR_HORFIN)
				cFinal := cHorFim
			else
				cFinal := TrbHesp->BAR_HORFIN 
			endif
			
			nHoraFinal   := val(SubStr(cFinal,1,2)) // hora final que o prestador trabalho em horario de regime especial
			nMinFinal    := val(SubStr(cFinal,3,4)) // minuto final que o prestador trabalho em horario de regime especial
			nHoraIni     := val(SubStr(cIni,1,2))   // hora Inicial que o prestador trabalho em horario de regime especial
			nMinIni      := val(SubStr(cIni,3,4))   // minuto Inicial que o prestador trabalho em horario de regime especial

			nTotHorE1 := (nHoraFinal) * 60 + nMinFinal
			nTotHorE2 := (nHoraIni)   * 60 + nMinIni   // periodo de trabalho feito em regime especial do prestador 
			nTotHorE  := nTotHorE1 - nTotHorE2

			if( nTotHorE > nTotPrest .or. cHorCir >= TrbHesp->BAR_HORINI .and. cHorCir <= TrbHesp->BAR_HORFIN )
				nPerHorEsp := TrbHesp->BAR_PERC
				exit 
			endif
	
	TrbHesp->(dbSkip())
	endDo
	
endIf

TrbHesp->(dbCloseArea())

return(nPerHorEsp)

/*/{Protheus.doc} PLFATM
Funcao desenvolvida para alterar a taxa de comercializacao de material e medicamento por prestador.
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLFATM(cCodPad,cCodPro,cCodInt,cCodRDA,cCodEsp,cCodLoc,nQtd,cPadInt,cRegAte,aDadUsr,cPadCon,;
                    lCobCoPart,dDatCir,cHorCir,cTipoGuia,lCompra,cConsFt,cCdProduto,cVrProduto,nFatMul,cCodTab)
local I			:= 0
local aNiveis	:= PLSESPNIV(cCodPad)
local lRet      := .f.
local aRetFTM   := {}

//O Fator Multiplicador sera considerado somente se o cConsFt for "1"
if cConsFt == "1"

	cSql := "SELECT BYZ_CODIGO,BYZ_CODPAD,BYZ_CODPRO,BYZ_FATORM "
	cSql += "  FROM " + retSqlName("BYZ") 
	cSql += " WHERE BYZ_FILIAL = '" + xFilial("BYZ") + "'"
	cSql += "   AND BYZ_CODINT = '" + cCodInt + "' " 
	cSql += "   AND BYZ_CODIGO = '" + cCodRda + "' "
	cSql += "   AND BYZ_CODTDE = '" + cCodTab + "' "
	cSql += "   AND BYZ_CODPAD = '" + cCodPad + "' "
	cSql += "   AND (BYZ_CODPRO = '" + cCodPro + "' OR BYZ_CODPRO = ' ' ) "
	cSql += "   AND BYZ_FATORM > 0 "
	cSql += "   AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY BYZ_CODIGO,BYZ_CODPAD,BYZ_CODTDE,BYZ_CODPRO DESC "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"BYZA",.f.,.t.)
	
	while ! BYZA->(eof())
		
		aFtCmp := {}		
		cifCmp := ""

		aadd(aFtCmp,{BYZA->BYZ_CODIGO,cCodRda,!empty(BYZA->BYZ_CODIGO)})
		aadd(aFtCmp,{BYZA->BYZ_CODPAD,cCodPad,!empty(BYZA->BYZ_CODPAD)})
		aadd(aFtCmp,{BYZA->BYZ_CODPRO,cCodPro,!empty(BYZA->BYZ_CODPRO)})
		
		for I:= 1 to len(aFtCmp)
		
			if aFtCmp[I,3]
			
				if cifCmp > ""
					cifCmp += " .AND. '" + aFtCmp[I,1] + "' == '" + aFtCmp[I,2] + "' "
				else
					cifCmp := "'" + aFtCmp[I,1] + "' == '" + aFtCmp[I,2] + "'"
				endIf
				
			endIf
			
		next I
		
		if &cifCmp
			
			nFatMul := BYZA->BYZ_FATORM
			lRet 	:= .t.					
			exit
			
		else
		
			cSQL := "SELECT R_E_C_N_O_ REC FROM " + BYZ->(retSqlName("BYZ")) + " WHERE "
			cSQL += "BYZ_FILIAL = '" + xFilial("BYZ") + "' AND "
			cSQL += "BYZ_CODIGO = '" + cCodRda + "' AND "
			cSQL += "BYZ_CODINT = '" + cCodInt + "' AND "
			cSQL += "BYZ_CODPAD = '" + cCodPad + "' AND "
			cSql += "BYZ_FATORM > 0 AND "
			
			cSQL += PLREQNI("BYZ", "BYZ_CODPRO", aNiveis[2], allTrim(cCodPro))
			
			cSQL += "D_E_L_E_T_ = ' ' "
			
			cSQL +=  " ORDER BY BYZ_NIVEL DESC "
			
			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)
			
			if ! PLSAUTPDIR->(eof())

				BYZ->(dbGoTo(PLSAUTPDIR->(REC)))

				nFatMul := BYZ->BYZ_FATORM
				lRet 	:= .t.
				
			endIf
			
			PLSAUTPDIR->(dbCloseArea())
		
		endIf
		
	BYZA->(dbSkip())
	endDo
	
	BYZA->(dbCloseArea())

	if lRet
		aRetFTM := { nFatMul, cConsFt }
	endIf
	
endIf

return (aRetFTM)

/*/{Protheus.doc} PLSRFatM
Funcao desenvolvida para alterar a taxa de comercializacao de material e medicamento por prestador.
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRFatM(cPadInt,cPadCon,cCodInt)
local nFatMul	:= 1
local lFator    := .f.

default cPadInt := ""
default cPadCon := ""    
default cCodInt := PLSINTPAD()             

//localiza o fator de multiplicacao para o padrao de conforto...
if ! empty(cPadCon)
   
   BN5->( dbSetOrder(1) )//BN5_FILIAL+BN5_CODINT+BN5_CODIGO
   if BN5->(msSeek(xFilial("BN5")+cCodInt+cPadCon)) .and. BN5->BN5_FATMUL > 0
   
      nFatMul := BN5->BN5_FATMUL
      lFator  := .t.
   
   endIf  
    
endIf

//localiza o fator de multiplicacao para a acomodacao   
if ! lFator .and. ! empty(cPadInt)
 
	BI4->(dbSetOrder(1))//BI4_FILIAL+BI4_CODACO
	if BI4->(msSeek(xFilial("BI4")+cPadInt)) .and. BI4->BI4_FATMUL > 0
		nFatMul := BI4->BI4_FATMUL
		lFator  := .t.
	endIf
	      
endIf

//Nova implementacao... verificar se no produto tem um  
//fator diferente e valido...                       
if ! lFator .and. ! empty(cPadInt) .and. ! BI3->(eof()) .and. BI3->BI3_FATMUL > 0

    nFatMul := BI3->BI3_FATMUL 
    lFator  := .t.
	    
endIf         

return nFatMul

/*/{Protheus.doc} PLCHRETB
Checa se o procedimento existe na TDE amarrada
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLCHRETB(cCodPro, cCodTab)
local aAreaBA8	:= BA8->(GetArea())
local lRet		:= .f.

if len(allTrim(cCodTab)) == 3
	cCodTab := plsIntPad() + cCodTab
endIf

BA8->(dbSetOrder(4)) //BA8_FILIAL+BA8_CODPRO+BA8_CODTAB
lRet := BA8->(msSeek(xFilial("BA8") + cCodPro + cCodTab))

RestArea(aAreaBA8)

return lRet

/*/{Protheus.doc} PLMAIPAUX
retorna o evento de maior porte e seus auxiliares
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLMAIPAUX(aAuxCBHPM, cCodTab, cCodPad, cCodPro, cCodOpe, dDatPro, aPreAut, cTipoGuia, cCodRDA, cCodEsp, cCodLoc)
local nI			:= 0
local cTabEve		:= "" 
local cPortEve 		:= "" 	
local aComEve		:= PLSCOMEVE(cCodTab, cCodPad, cCodPro, cCodOpe, dDatPro, cTipoGuia, nil, nil, cCodRDA, cCodEsp, nil, cCodLoc)
local aVetAux  		:= {} 		
local cMVPLSCAUX	:= getNewPar("MV_PLSCAUX","AUX")
local cUndPorte		:= allTrim(PLSCHMP())
local nVPorte		:= 0

default aPreAut	:= {}

if aScan(aComEve, {|x| x[1] $ cMVPLSCAUX } ) > 0
	
	BW4->(dbSetOrder(1))
	
	for nI := 1 to len(aComEve)
	
		if aComEve[nI,1] $ cUndPorte
		
			cTabEve  := aComEve[nI,15]
			cPortEve := aComEve[nI,12]
			
 			if BW4->( msSeek( xFilial("BW4") + cCodOpe + cTabEve + cPortEve ) )
				nVPorte	 := BW4->BW4_VLRREA
 			endIf
			
		endIf

		if aComEve[nI,1] $ cMVPLSCAUX
			aadd(aVetAux, aComEve[nI])
		endIf
		
	next
	
	if len(aVetAux) > 0 .and. nVPorte > 0 .and. nVPorte > aAuxCBHPM[4] 
		aAuxCBHPM := { cCodPad, cCodPro, cPortEve, nVPorte, aVetAux, aPreAut }
	endIf
	
endIf	

return

/*/{Protheus.doc} PLUNMAUA
Funcao criada para criar a composicao nao prevista de anes tesista num evento
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLUNMAUA(pCodInt,pCodTab,pUnMed,pSeqPor,pDatPro,pTamAre)
local aRetUnm := array(pTamAre)
local cQryTrb := ""

BD3->(dbSetOrder(1))
BD3->(msSeek(xFilial("BD3")+pUnMed))

cQryTrb := "SELECT BKF_COEFIC, BKF_VLRREA, BKF_VIGINI, BKF_VIGFIN FROM " + retSqlName("BKF")
cQryTrb += " WHERE BKF_FILIAL = '" + xFilial("BKF") + "' "
cQryTrb += "   AND BKF_CODINT = '" + pCodInt + "' "
cQryTrb += "   AND BKF_CODTAB = '" + pCodTab + "' "
cQryTrb += "   AND ( ( BKF_VIGINI <= '" + dtos(pDatPro) + "' AND BKF_VIGFIN >= '" + dtos(pDatPro) + "') "
cQryTrb += "    OR   ( BKF_VIGINI <= '" + dtos(pDatPro) + "' AND BKF_VIGFIN = '        ') "
cQryTrb += "    OR   ( BKF_VIGINI = '        ' AND BKF_VIGFIN <= '        ') ) "
cQryTrb += "   AND BKF_SEQPOR = '" + pSeqPor + "' "
cQryTrb += "   AND D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cQryTrb),"TRBKF",.f.,.t.)

if !TRBKF->(eof())
	aRetUnm[01] := pUnMed
	aRetUnm[02] := BD3->BD3_ORDEM
	aRetUnm[03] := val(pSeqPor)
	aRetUnm[04] := 0
	aRetUnm[05] := 0
	aRetUnm[06] := BD3->BD3_RDMAKE
	aRetUnm[07] := BD3->BD3_UNIDAD
	aRetUnm[08] := BD3->BD3_TIPVAL
	aRetUnm[09] := "0"
	aRetUnm[10] := ""
	aRetUnm[11] := ""
	aRetUnm[12] := ""
	aRetUnm[13] := ""
	aRetUnm[14] := ""
	aRetUnm[15] := pCodTab
	aRetUnm[16] := ""
	aRetUnm[17] := ""
	aRetUnm[18] := .f.
	aRetUnm[19] := 0
else
	aRetUnm := {}
endIf

TRBKF->(dbCloseArea())

return aRetUnm

/*/{Protheus.doc} PLVLTBPR
Retorna a estrutura da nova tabela de preços, com no novo sistema de valorizacao de pagamento.
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLVLTBPR(cTabPre,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri,;
				  cAlias,cCodEsp,cCodUnd, lCobCoPart)
local aRet    	:= {.f.,{}}
local cSql    	:= ""
local aAux    	:= {}
local cTabAux 	:= cTabPre
local lPLVLRQRY := existBlock("PLVLRQRY")

default cFinAte 	:= ""
default cCodTab		:= ""
default lObsoleto 	:= .f.
default nPorteOri	:= 0
default cAlias		:= ""
default cCodEsp		:= ""
default cCodUnd    	:= ""
default lCobCoPart  := .F.

// Ponto de entrada que permite alterar o codigo da tabela de preço na ultima hora.
if existBlock("PLSTABESP")

	if ! empty(cAlias)
	
		cTabAux := execBlock("PLSTABESP",.f.,.f.,{cAlias,&(cAlias)->(recno()),cTabPre,cCodInt,cCodPad,cCodPro,dDatAnalise,;
													cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri})
		if !empty(cTabAux)
			cTabPre := cTabAux
		endIf
	endIf
			
endIf
	
cSql := " SELECT B23_REGATE, B23_FINATE, B23.R_E_C_N_O_ "
cSql += "   FROM " + retSqlName("B23") + " B23 " //," + retSqlName("B22") + " B22 "

cSql += " Inner Join " + retSqlName("B22") + " B22 "
cSql += " On "

cSql += "        B22_FILIAL = '" + xFilial("B22") + "' "
cSql += "    AND B22_CODINT = B23_CODINT "
cSql += "    AND B22_CODTAB = B23_CODTAB "

if allTrim(cCodUnd) $ "HM,HMR,PPM,RCC,CIR"
	cSql += " AND (B22_TIPO = ' ' OR B22_TIPO = '1') "
endIf

if allTrim(cCodUnd) $ "FIL"
	cSql += " AND (B22_TIPO = ' ' OR B22_TIPO = '2') "
endIf

if allTrim(cCodUnd) $ "COP,COR,UCO"
	cSql += " AND (B22_TIPO = ' ' OR B22_TIPO = '3') "
endIf

if allTrim(cCodUnd) $ "PA,PAP,PAR"
	cSql += " AND (B22_TIPO = ' ' OR B22_TIPO = '4') "
endIf

if allTrim(cCodUnd) $ "TCR,VDI,VMD,VMT,VTX,REA"
	cSql += " AND (B22_TIPO = ' ' OR B22_TIPO = '5') "
endIf

if allTrim(cCodUnd) $ "AUX,AUR"
	cSql += " AND (B22_TIPO = ' ' OR B22_TIPO = '6') "
endIf
cSql += " AND ( '" + dtos(dDatAnalise) + "' BETWEEN B22_DATINI AND B22_DATFIM OR ( B22_DATINI = ' ' OR B22_DATFIM = ' ' ) ) "
cSql += " AND B22.D_E_L_E_T_ = ' ' "

cSql += "  WHERE B23_FILIAL = '" + xFilial("B23") + "' "
cSql += "    AND B23_CODINT = '" + cCodInt + "' "
cSql += "    AND B23_CODTAB = '" + cTabPre + "' "

cSql += " AND ( ( B23_CDPAD1 = '" + cCodPad + "' AND B23_CDPRO1 = '" + cCodPro + "' AND B23_CDPAD2 = '" + cCodPad + "' AND B23_CDPRO2 = '" + cCodPro + "'  ) OR "
cSql += "	    ( B23_CDPAD1 = '" + cCodPad + "' AND B23_CDPAD2 = '" + cCodPad + "' AND '" + cCodPro + "' BETWEEN B23_CDPRO1 AND B23_CDPRO2 ) "
cSql += " ) "

cSql += " AND ( '" + dtos(dDatAnalise) + "' BETWEEN B23_VIGINI AND B23_VIGFIM OR ( B23_VIGINI = ' ' OR B23_VIGFIM = ' ' ) ) "

cSql += " AND B23.D_E_L_E_T_ = ' ' "
				
//	cSql += " ORDER BY B22_TIPO DESC "
	
//Ponto de entrada para manipular a Query que busca o evento dentro da nova rotina de tabela de preço
if lPLVLRQRY
	cSql :=	execBlock("PLVLRQRY",.f.,.f.,{cSql}) 
endIf

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRB1",.f.,.t.)

// Armazena registros encontrados.
aAux := {}

while !TRB1->(eof())
	aadd(aAux, { TRB1->B23_REGATE, TRB1->B23_FINATE, TRB1->R_E_C_N_O_ } )
TRB1->( dbSkip() )
endDo

TRB1->( dbCloseArea() )

if len(aAux) > 0
	aRet := PLVLRETB(aAux,cRegAte,cFinAte,dDatAnalise,cCodInt,lObsoleto,nPorteOri,cCodPad,cCodPro,lCobCoPart)
endIf

//Ponto de entrada para manipular a aRet com os dados da tabele de preço
if existBlock("PLVLRET")
	
	if empty(cAlias)
		cAlias := "BFM"
	endIf
		
	aRet := execBlock("PLVLRET",.f.,.f.,{cAlias,&(cAlias)->(recno()),aRet,cTabPre,cCodInt,cCodPad,cCodPro,dDatAnalise,cRegAte,cFinAte,cCodTab,lObsoleto,nPorteOri})
		
endIf

return(aRet)
     
/*/{Protheus.doc} PLVLRETB
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
static function PLVLRETB(aAux, cRegAte, cFinAte, dDatAnalise, cCodInt, lObsoleto, nPorte, cCodPad, cCodPro, lCobCoPart)
local aRet 			:= {.f.,{}}
local _aTabVlrUS	:= {}
local _aTabVlrFM	:= {}
local _aTabVlrUC	:= {}
local _aTabVlrPA	:= {}
local _aCompTmp		:= {}

default nPorte		:= 0
default lObsoleto	:= .f.
default lCobCoPart  := .f.

// Alinha variaveis.                                         
cFinAte := allTrim(cFinAte)
cRegAte := allTrim(cRegAte)

//TODO - necessario implemtar na PLSRETTAB passar a Finalidade e Regime

nPos := aScan(aAux,{|x| ( allTrim(x[1]) == cRegAte ) .and. (allTrim(x[2]) == cFinAte )})

if nPos == 0 
	nPos := aScan(aAux,{|x| ( allTrim(x[1]) == cRegAte ) .and. (allTrim(x[2]) == cFinAte .or. empty(x[2]) )})
endif

if nPos == 0 
	nPos := aScan(aAux,{|x| (allTrim(x[1]) == "3" .or. allTrim(x[1]) == cRegAte .OR. empty(x[1] )) .and. (allTrim(x[2]) == cFinAte)})
endif

if nPos == 0 
	nPos := aScan(aAux,{|x| ( allTrim(x[1]) == "3" .or. allTrim(x[1]) == cRegAte .OR. empty(x[1]) ) .and.;
	 (allTrim(x[2]) == cFinAte .OR. EmpTy(x[2])) })
endif

// Encontrou uma ocorrencia.
if nPos > 0

	// Posiciona o item da tabela de preço.
	B23->( dbGoTo(aAux[nPos][3]) )
	
	if ! B23->( eof() )
	
		// Informacoes da tabela de US, caso ela tenha sido preenchida. -- vem da B28_VALOR
		if ! empty(B23->B23_CDTBUS)

			_aTabVlrUS := PLTBVLR(B23->B23_CDTBUS,dDatAnalise,cCodInt)
		
		endIf
	
		// Informacoes da tabela de Filme, caso ela tenha sido preenchida. -- vem da B28_VALOR
		if ! empty(B23->B23_CDTBFM)

			_aTabVlrFM := PLTBVLR(B23->B23_CDTBFM, dDatAnalise,cCodInt)

		endIf
	
		// Informacoes da tabela de UCO, caso ela tenha sido preenchida. -- vem da B28_VALOR
		if ! empty(B23->B23_CDTBUC)

			_aTabVlrUC := PLTBVLR(B23->B23_CDTBUC, dDatAnalise, cCodInt)

		endIf

	    //pode mudar o valor do porte conforme B28 ou BKF caso nao tenha tabela de preco definida na B28    
		if ! empty(B23->B23_PORTAN)
			nPorte := B23->B23_PORTAN
		endIf

		// Valor do Porte anestesico.
		if ! empty(B23->B23_CDPTAN)

			_aTabVlrPA := PLTBVLR(B23->B23_CDPTAN, dDatAnalise, cCodInt, nPorte)
			
		endIf

		//se informado somente TDE vai buscar a composicao do evento 
		//esta variacao pode ocorrer por que a busta da tabela de preco na funcao PLVLTBPR pode ser somente pelo codigo do evento
		//nao considerando assim a CODPAD.
       	if ! empty(B23->B23_CODTDE) 
		  	
			  _aCompTmp := PLSCOMEVE(B23->B23_CODTDE, cCodPad, cCodPro, cCodInt, dDatAnalise)

		endIf
		
		aRet := {.t., {	B23->( recno() ),;				// 01 - Nr Registro B23
						B23->B23_CODTAB,;				// 02 - Codigo da tabela de preco
						B23->B23_CDPAD1,;				// 03 - Codigo da tabela de procedimento De
						B23->B23_CDPRO1,;				// 04 - Codigo do procedimento De
						B23->B23_CDPAD2,;				// 05 - Codigo da tabela de procedimento Ate
						B23->B23_CDPRO2,;				// 06 - Codigo do procedimento Ate
						B23->B23_CODTDE,;				// 07 - Codigo da TDE
						_aTabVlrUS,;					// 08 - Tabela US
						B23->B23_QTDUS,;				// 09*
						B23->B23_BANDUS,;				// 10
						_aTabVlrFM,;					// 11 - Tabela FIL
						B23->B23_QTDFM,;				// 12*
						B23->B23_BANDFM,;				// 13
						_aTabVlrUC,;					// 14 - Tabela UCO
						B23->B23_QTDUC,;				// 15*
						B23->B23_BANDUC,;				// 16
						"",;							// 17
						nPorte,;						// 18
						B23->B23_REGATE,;				// 19
						B23->B23_FINATE,;				// 20
						B22->B22_DESCRI,;				// 21
						B22->B22_OBSERV,; 				// 22  B22->B22_OBSERV,;							
						iIf(len(_aTabVlrUS)>0,.t.,.f.),;// 23 Se nao tiver tabela de US, nao poderá considerar o Porte Anestesico.
						B23->B23_BANPTA,;				// 24 Banda para o porte anestesico.
						_aTabVlrPA,;                    // 25 Tabela PORTE
						_aCompTmp,;						// 26 composicao alternativa da tde
						B23->B23_BANDAR,;				// 27 - banda p rece
						B23->B23_BANDAP,;				// 28 - banda para pagar
						B23->B23_VRPPP,; 				// 29 - valor em real para pgamento PRE PAGAMENTO
						B23->B23_VRRPP,;				// 30 - valor em real para recebimento PRE PAGAMENTO
						B23->B23_VRPCO,;				// 31 - valor em real para pagameto CUSTO
						B23->B23_VRRCO,;				// 32 - valor em real para recebimento CUSTO
						B23->B23_PERACR,;				// 33 - Percentual de Acrescimo
						B23->B23_PERDES,;				// 34 - Percentual de Desconto
						B23->B23_VIGINI,;				// 35 - Vigencia Inicio
						B23->B23_VIGFIM}}				// 36 - Vigencia Fim
	endIf
	
endIf

return(aRet)

/*/{Protheus.doc} PLREQNI
Retorna query conforme nivel
@version 	P12
@since		28.07.17
/*/
function PLREQNI(cAlias, cFieldPro, aNiveis, cCodPro)
local cSql  	:= ""
local nI		:= 0		
local nPosIni	:= 0
local nPosFim	:= 0
local cNivel	:= ""
local cField 	:= ""
local cConteudo := ""

if len(aNiveis) > 0		
	
	for nI := 1 to len(aNiveis)
	
		nPosIni		:= aNiveis[nI,1]
		nPosFim		:= aNiveis[nI,2]
		cNivel		:= aNiveis[nI,3]
		cField 		:= cAlias + '_' + aNiveis[nI,4]
		
		cConteudo 	:= subStr(cCodPro, nPosIni, nPosFim)
		
		if nI == 1
			cSql := " ( " + cFieldPro + " = '" + cCodPro + "' OR "
		endIf	
	
		cSql += cField + " = '" + cConteudo + "' AND " + cAlias + "_NIVEL = '" + cNivel + iIf(nI <= len(aNiveis)-1, "' OR ", "' ) AND " )
			 
	next
	
else
	cSql := cFieldPro + " = '" + cCodPro + "' AND "
endIf

return cSql

/*/{Protheus.doc} SeekBB8E
busca bb8 especialidade
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function SeekBB8E(cCodRDA,cCodInt,cCodLoc)
local lRet := .f.

lRet := BB8->( msSeek( xFilial("BB8") + cCodRDA + cCodInt + cCodLoc ) )

if lPLSBB8SK
   lRet := execBlock("PLSBB8SK",.f.,.f.,{lRet,cCodRda,cCodInt,cCodLoc } )
endIf

return(lRet)

/*/{Protheus.doc} PLTBVLR
Retorna a referencia de acordo com a tabela e com a vigencia ativa na data do procedimento. 
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
static function PLTBVLR(cCodTab,dDatAnalise,cCodInt,nPorte)
local aRet 			:= {}
local nValor		:= 0
local lOk			:= .f.
local cSQL 			:= ""
local cNameB28	 	:= B28->(retSqlName("B28"))

default nPorte := 0

B28->( dbSetOrder(1) ) //B28_FILIAL+B28_CODINT+B28_CODTAB+B28_SEQUEN

cSQL := " SELECT R_E_C_N_O_ REC FROM " + cNameB28 + " WHERE "
cSQL += " B28_FILIAL = '" + xFilial("B28") + "' AND "
cSQL += " B28_CODINT = '" + cCodInt + "' AND "
cSQL += " B28_CODTAB = '" + cCodTab + "' AND "

cSQL += " ( '" + dtos(dDatAnalise) + "' >= B28_VIGINI OR B28_VIGINI  = ' ' ) AND "
cSQL += " ( '" + dtos(dDatAnalise) + "' <= B28_VIGFIM OR B28_VIGFIM = ' ' ) AND "

cSQL +=  cNameB28 + ".D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSQL),"PLSPAP",.f.,.t.)

while !PLSPAP->( eof() )

	B28->(dbGoTo(PLSPAP->(REC)))  		
		
	nValor := B28->B28_VALOR
	
	//diferenciacao quando for porte anestesico nPorte == B23_PORTAN
	if nPorte > 0 .and. B28->B28_PTANES != nPorte
		nValor := 0
	endIf

	if nValor > 0
		
		lOk	:= .t.
		aRet := { B28->( recno() ), B28->B28_SEQUEN, nValor, B28->B28_VIGINI, B28->B28_VIGFIM }
		exit

	endIf
	
	PLSPAP->( dbSkip() )
endDo

PLSPAP->(dbCloseArea())

return( aRet )

/*/{Protheus.doc} PLSVLDBA8
Valida a tabela
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSVLDBA8(cCodInt,cCodPad,cCodPro,cCodTab,cAlias,aCodTab,dDatAnalise)
local lRet 	:= .f.   
local j		:= 0       
local cSql  := '' 
default dDatAnalise := dDataBase

//Se a tabela ainda nao existe
if ! empty(cCodTab)
	
	//Varifica se existe
	BA8->( dbSetOrder(1) )//BA8_FILIAL, BA8_CODTAB, BA8_CDPADP, BA8_CODPRO

	if !BA8->( msSeek(xFilial("BA8")+ cCodInt + cCodTab + cCodPad + cCodPro) )
		cCodTab := ""
		cAlias  := ""
	else
	
		//nao basta eu procurar o procedimento eu tb tenho que procurar se a vigencia dele esta valida
		cSql := " SELECT R_E_C_N_O_ REC FROM " + retSqlName('BD4')
		cSql += "  WHERE BD4_FILIAL = '" + xFilial('BD4')  + "' "
		cSql += "    AND BD4_CODTAB = '" + BA8->BA8_CODTAB + "' "
		cSql += "    AND BD4_CDPADP = '" + BA8->BA8_CODPAD + "' "
		cSql += "    AND BD4_CODPRO = '" + BA8->BA8_CODPRO + "' "
		
		if ! empty(dDatAnalise)
			cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BD4_VIGINI OR BD4_VIGINI = ' ' )  "
			cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BD4_VIGFIM OR BD4_VIGFIM = ' ' )  "
		endIf
		
		cSql += " AND D_E_L_E_T_ = ' ' "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbBD4",.f.,.t.)
			
		if !TrbBD4->(eof()) .and. TrbBD4->rec > 0
			lRet := .t.
		endIf
		
		TrbBD4->(dbCloseArea())
	endIf
	
elseIf len(aCodTab) > 0
	
	BA8->(dbSetOrder(1))//BA8_FILIAL, BA8_CODTAB, BA8_CDPADP, BA8_CODPRO
	for j := 1 to len(aCodTab)
	
		if ! BA8->( msSeek(xFilial("BA8")+ cCodInt+ aCodTab[j] + cCodPad + cCodPro) )
			
			cCodTab := "" 
			cAlias  := ""
			
		else
		
			//nao basta eu procurar o procedimento eu tb tenho que procurar se a vigencia dele esta valida
		
			cSql := " SELECT R_E_C_N_O_ REC FROM " + retSqlName('BD4')
			cSql += "  WHERE BD4_FILIAL = '" + xFilial('BD4')  + "' "
			cSql += "    AND BD4_CODTAB = '" + BA8->BA8_CODTAB + "' "
			cSql += "    AND BD4_CDPADP = '" + BA8->BA8_CODPAD + "' "
			cSql += "    AND BD4_CODPRO = '" + BA8->BA8_CODPRO + "' "
			
			if ! empty(dDatAnalise)
				cSql += " AND ( '" + dtos(dDatAnalise) + "' >= BD4_VIGINI OR BD4_VIGINI = ' ' )  "
				cSql += " AND ( '" + dtos(dDatAnalise) + "' <= BD4_VIGFIM OR BD4_VIGFIM = ' ' )   "
			endIf
		
			cSql += " AND D_E_L_E_T_  = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbBD4",.f.,.t.)
			
			if !TrbBD4->(eof()) .and. TrbBD4->rec > 0					

				cCodTab := aCodTab[j] 
				cAlias  := "BH0"
				lRet 	:= .t.
				 
			endIf
			
		TrbBD4->(dbCloseArea())
		endIf		
		     
		// Sai ao encontrar.
		if lRet
			exit
		endIf
		
    next
    
endIf         

return( lRet )

/*/{Protheus.doc} PLMFORCA
Tranformar uma unidade CALCULADA em INFORMADA
a ideia desta funcao eh a seguinte, caso a unidade seja INFORMADA eu pego o apresentado, isso eh o padraozao
entretanto se a unidade for CALCULADA eu transformo ela em INFORMADA caso seja usuario de intercambio,
seja um pagamento, o valor apresentado esteja maior q zero e o parametro esteja ativo
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLMFORCA(cCodUnd,nVlrApr,lInterc,cTipPre,nVlrAprPag,lCobCoPart,cOpeOri,cCodPad,cCodPro,cCodEmp,cCodLoc,cAno,cMes,aRetTab)
local nOrdBD3     	:= BD3->(indexOrd())
local nRecBD3 	  	:= BD3->(recno())
local bRest       	:= {|| BD3->(dbSetOrder(nOrdBD3)), BD3->(dbGoTo(nRecBD3)) }
local lRet 		  	:= .f.                                      
local lPtoEntr	  	:= .f.
local aCompara		:= {}

default nVlrAprPag 	:= 0                                                          
default lCobCoPart 	:= .f.
default cOpeOri    	:= PLSINTPAD()
default cCodEmp    	:= ""

default aRetTab 	:= {}
       
BD3->(dbSetOrder(1))						
if BD3->(msSeek(xFilial("BD3") + cCodUnd))
	
	//calculada                       
    if BD3->BD3_TIPVAL == "1" 

		if existBlock("PLSVLPR01")
			lPtoEntr := execBlock("PLSVLPR01",.f.,.f.,{cTipPre,lInterc,nVlrApr,nVlrAprPag,lCobCoPart,cOpeOri,cCodPad,cCodPro,cCodUnd})
		endIf	
		
		if lPtoEntr
	 		lRet := .t.
	 	endIf

	 //informada 	
	 elseIf  BD3->BD3_TIPVAL == "2" 
	 	lRet := .t.
	 endIf
	 
endIf
    
eval(bRest)

//A Ideia desse if é fazer o o lRet (que é o lInformada da função PLSRETVREA) passar como falso e ele
//Entrar nas regras das tabelas de pagamento dos prestadores para a Unidade REA, caso ele passe como
//.t., as regras são desprezadas e a valoração irá ser feita de acordo com a TDE vinculada.
//Caso não tenha sido informado valor que deve sobrepor, o sistema continua pegando o valor da TDE
//Referenciada. Como essa parametrização é mais específica, mesmo que o Cliente utilize o ponto de entrada,
//Deve prevalecer esta configuração.
//Se abaixo ja tem uma condição para REA nao faz sentido rodar o codigo abaixo para outras unidades
if lRet .and. cCodUnd == "REA" 
	
	if empty(aRetTab)
		aCompara := PLSRETTAB(	Paramixb[9],Paramixb[10],Paramixb[4],;
								Paramixb[6],Paramixb[5],Paramixb[7],"",cCodLoc,;
								dtos(Paramixb[4]),"1",Paramixb[6],"","1","1",nil,nil,nil,nil,.f.,nil,nil,nil,nil,nil,nil, nil,cCodEmp,cAno,cMes)      
	else
		aCompara := aRetTab
	endIf
				
	if aCompara[6][1]

		if cCodUnd == "REA" .and. (aCompara[6][2][30] > 0 .or. aCompara[6][2][29] > 0)
			lRet := .f.
		endIf

	endIf

endIf

if lPLNUMCOI
	lRet := Execblock("PLUNMCOI", .F., .F., {lRet, cCodUnd})
endif

return lRet

/*/{Protheus.doc} PLRTINS
Retorna o percentual do instrumentador	
@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLRTINS(cCodOpe,cAno,cMes)
local aAreaBFM:= BFM->(getArea())
local nPerIns := 0
local cAlias  := ""

if BFM->( msSeek( xFilial("BFM") + cCodOpe + cAno + cMes) ) .and. BFM->BFM_PERINS > 0
   nPerIns := BFM->BFM_PERINS
   cAlias  := "BFM"
endIf   

BFM->(restArea(aAreaBFM))

return( { nPerIns, cAlias } )

/*/{Protheus.doc} PLSRTPUS
padronizacao do retorno para nova valoracao

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRTPUS(aTabPre, lUndCop, lPorteMed, lPorteAnestesico, lUCONiv, lCobCoPart, cModPag, cAliasInfo, cCodUnd, cAlias, lOK, nUSEspec,;
				  nVlr, nVlrRea, nBanda, nRef, nAcrescimo, nDesconto, cCodTab, cPorteMed, aVigAtu, dVigIni, dVigFim, lOkAD)
local aCmpTmp 	 := {}
local lRefTab	 := .f.

default dVigIni	 := ctod("")
default dVigFim	 := ctod("")
default lOkAD	 := .F.

if len(aTabPre) > 0 .and. aTabPre[1]
								
	// pagamento ou recebimento
	if ! lCobCoPart .or. ( lCobCoPart .and. nUSEspec == 0 )
		
		// _aTabVlrUC - Usa o valor da tabela de UCO quando a unidade for COP.S - campo B23_CDTBUC nao estiver vazio
		if lUndCop 
			
			if len(aTabPre[2][14]) > 0

				nVlr 	:= aTabPre[2][14][3] //B28_VALOR
				dVigIni	:= aTabPre[2][14][4]
				dVigFim := aTabPre[2][14][5]

				//Uco - B23_QTDUC 
				if aTabPre[2][15] > 0
					nRef 	:= aTabPre[2][15]
					lRefTab := .t.
				endIf

				//Pagamento - B23_BANDUC
				nBanda := aTabPre[2][16]

			endIf	

		//porte anestesico _aTabVlrPA	
		elseIf lPorteAnestesico
			
			//Valor do porte anestesico em reais campo B23_CDPTAN nao esta vazio
			//e achou valor _aTabVlrPA
			if len(aTabPre[2][25]) > 0

				nVlr 	:= aTabPre[2][25][3] 					//B28_VALOR
				nVlrRea := iIf(lPorteMed, aTabPre[2][25][3], 0) //B28_VALOR

				dVigIni := aTabPre[2][25][4]
				dVigFim := aTabPre[2][25][5]

				//Para PPM com PA ou PAP e necessario informar a tabela de preco e/ou o porte.
				//Sequencia do porte
				if aTabPre[2][18] > 0
					nRef := aTabPre[2][18] //B23_PORTAN
				endIf
					
				//Pagamento - B23_BANPTA
				nBanda := aTabPre[2][24]

			endIf
			
		//_aTabVlrUS achou valor de US pode vir da B28 se o campo B23_CDTBUS estiver preechido  
		// ou dos campos B23_USRPP e B23_USRCO											
		else

			if len(aTabPre[2][8]) > 0

				nVlr 	:= aTabPre[2][8][3] // B28_VALOR ou B23_USRPP, B23_USPPP, B23_USRCO, B23_USPCO
				dVigIni := aTabPre[2][8][4]
				dVigFim := aTabPre[2][8][5]
		
				//US - B23_QTDUS														
				if aTabPre[2][9] > 0
					nRef 	:= aTabPre[2][9]
					lRefTab := .t.
				endIf

				//Pagamento - B23_BANDUS
				nBanda := aTabPre[2][10] 

			endIf

		endIf

	endIf

	//somente se o codigo da TDE nao estiver em branco - B23_CODTDE
	if ! empty(aTabPre[2][7]) 

		// Valor da banda da US para pagar e para receber
		if nBanda == 0 

			nBanda := iIf( ! lCobCoPart, aTabPre[2][28], aTabPre[2][27] )  //B23_BANDAP//B23_BANDAR

		endIf

		// Altera o valor da referencia do procedimento, com base na nova regra
		if ! lPorteAnestesico .and. len(aTabPre[2]) >= 26 .and. len(aTabPre[2][26]) >= 1

			aCmpTmp := aClone(aTabPre[2][26])

			if ( nI := aScan(aCmpTmp,{|x| allTrim(x[1]) == allTrim(cCodUnd)}) ) > 0

				if ! empty(aCmpTmp[nI][12])
				
					cCodTab   := aCmpTmp[nI][15]
					cPorteMed := aCmpTmp[nI][12]
					
				endIf
				
				//referencia da TDE B23_CODTDE
				if ! lRefTab
					nRef := aCmpTmp[nI][3]
				endIf	

			endIf

		endIf

	endIf
	
	nAcrescimo 	:= aTabPre[2][33] //B23_PERACR
	nDesconto  	:= aTabPre[2][34] //B23_PERDES

	//somente quando vem da PLSRTBANDA - lUCONiv  
	if lUCONiv
		lOK := ( nBanda > 0 )
	elseIf nVlr > 0 .or. nVlrRea > 0
		lOK := .t.
	endIf

	if lOK
		
		cAlias 	:= cAliasInfo
		aVigAtu	:= { cAlias, dVigIni, dVigFim }
	elseif nAcrescimo + nDesconto > 0 .AND. lPorteMed
		lOkAD := .T.
	endIf

endIf

return(lOK)

/*/{Protheus.doc} PLSRTPPA
padronizacao do retorno para nova valoracao

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRTPPA(aTabPre, cAliasInfo, cAlias, lOK, nPorte, nVlrPARea, nBanda, aVigAtu, dVigIni, dVigFim)
default dVigIni	 := ctod("")
default dVigFim	 := ctod("")

if len(aTabPre) > 0 .and. aTabPre[1]
	
	//B23_PORTAN			
	if len(aTabPre[2][25]) > 0
	
		nVlrPARea 	:= aTabPre[2][25][3] //B28_VALOR 
		dVigIni 	:= aTabPre[2][25][4] 
		dVigFim 	:= aTabPre[2][25][5]

	endIf

	nPorte := aTabPre[2][18] //B23_PORTAN

	if nPorte > 0 .or. nVlrPARea > 0
	
		if len(aTabPre[2][25]) > 0 .OR. !empty(aTabPre[2][24])
			nBanda 	:= aTabPre[2][24] //B23_BANPTA
		else
			nBanda 	:= aTabPre[2][28]
		endif
		lOK		:= .t.
		cAlias 	:= cAliasInfo
		aVigAtu	:= { cAlias, dVigIni, dVigFim }

	endIf
	
endIf

return(lOK)				  

/*/{Protheus.doc} PLSRTPFI
padronizacao do retorno para nova valoracao

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRTPFI(aTabPre, cAliasInfo, cAlias, lOK, nVlrFil, nBanda, nRef, aVigAtu, dVigIni, dVigFim)
default dVigIni	 := ctod("")
default dVigFim	 := ctod("")

if len(aTabPre) > 0 .and. aTabPre[1]
								
	if len(aTabPre[2][11]) > 0

		nVlrFil := aTabPre[2][11][3] //B28_VALOR
		dVigIni := aTabPre[2][11][4] 
		dVigFim := aTabPre[2][11][5]
		
		if aTabPre[2][12] > 0
			nRef := aTabPre[2][12] 	 //B23_QTDFM
		endIf

		nBanda 	:= aTabPre[2][13] 	 //B23_BANDFM

	endIf

	if nVlrFil > 0
		
		lOK		:= .t.
		cAlias 	:= cAliasInfo
		aVigAtu	:= { cAlias, dVigIni, dVigFim }
		
	endIf
	
endIf

return(lOK)

/*/{Protheus.doc} PLSRTPUC
padronizacao do retorno para nova valoracao

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLSRTPUC(aTabPre, cAliasInfo, cAlias, lOk, nUCO, nBanda, nRef, aVigAtu, dVigIni, dVigFim)

default dVigIni	 := ctod("")
default dVigFim	 := ctod("")

if len(aTabPre) > 0 .and. aTabPre[1]
								
	if len(aTabPre) > 1 .and. len(aTabPre[2][14]) > 0

		nUCO 	:= aTabPre[2][14][3] //B28_VALOR
		dVigIni := aTabPre[2][14][4] 
		dVigFim := aTabPre[2][14][5]
		
		if aTabPre[2][15] > 0
			nRef := aTabPre[2][15] 	 //B23_QTDUC
		endIf

		nBanda 	:= aTabPre[2][16] 	 //B23_BANDUC

	endIf

	if nUCO > 0

		lOk		:= .t.
		cAlias 	:= cAliasInfo
		aVigAtu	:= { cAlias, dVigIni, dVigFim }
		
	endIf

endIf

return(lOk)

/*/{Protheus.doc} PLRTPREA
padronizacao do retorno para nova valoracao real

@type function
@author PLS TEAM
@since 02.09.2002
@version 1.0
/*/
function PLRTPREA(aTabPre, cAliasInfo, cAlias, cModPag, lCobCoPart, lOk, nVlrRea, nDesconto, nAcrescimo, aVigAtu, dVigIni, dVigFim, lOkAD)
local nVlrAux	:= 0

default dVigIni	 := ctod("")
default dVigFim	 := ctod("")
default lOkAD := .F.

if len(aTabPre) > 0 .and. aTabPre[1]

	//Recebimento - VL PP Recto  | Pagamento - VL PP Pagto B23_VRRPP, B23_VRPPP
	nVlrAux := iIf(lCobCoPart, aTabPre[2][30], aTabPre[2][29])

	if allTrim(cModPag) != "1"
		
		//Recebimento - VL CO Recto | Pagamento - VL CO Pagto - B23_VRRCO, B23_VRPCO
		nVlrAux := iIf(lCobCoPart, aTabPre[2][32], aTabPre[2][31])

	endIf	
	
	if nVlrAux > 0 .OR. !(EmpTy(aTabPre[2][7]))
		nVlrRea 	:= nVlrAux
		nAcrescimo 	:= aTabPre[2][33] //B23_PERACR
		nDesconto  	:= aTabPre[2][34] //B23_PERDES
	elseif aTabPre[2][33] + aTabPre[2][34] > 0
		lOkAD 		:= .T.
		nAcrescimo 	:= aTabPre[2][33] //B23_PERACR
		nDesconto  	:= aTabPre[2][34] //B23_PERDES	
	endIf

	if len(aTabPre[2]) >= 36 
		dVigIni := aTabPre[2][35] //B23_VIGINI
		dVigFim := aTabPre[2][36] //B23_VIGFIM
	endIf	

	if nVlrAux > 0

		lOk		:= .t.
		cAlias 	:= cAliasInfo
		aVigAtu	:= { cAlias, dVigIni, dVigFim }
		
	endIf

endIf

return(lOk)

/*/{Protheus.doc} PLSRTPTP 
retorno padrao

@type function
@author PLS TEAM
@since 26.09.2017
@version 1.0
/*/
function PLSRTPTP(cAliasInfo, cCodTab, cAlias, lObsoleto, cSlvTab, cSlvAli, aVigAtu, dVigIni, dVigFim)
local lRet 	:= .f.

default dVigIni	 := ctod("")
default dVigFim	 := ctod("")

if ! empty(cCodTab)
								
   	cAlias := cAliasInfo
   
   	if empty(cSlvTab)
		cSlvTab := cCodTab
		cSlvAli := cAlias
   	endIf
	
	aVigAtu	:= { cAlias, dVigIni, dVigFim }
		
	lRet := .t.
	
endIf

return(lRet)	

/*/{Protheus.doc} PLSTBBD4 
como nao foi definido a tabela (TDE) na B23 retorna a tabela da BD4 e o alias do nivel parametrizado o valor
@type function
@author PLS TEAM
@since 26.09.2017
@version 1.0
/*/
function PLSTBBD4(cCodPad, cCodPro, dDatAnalise)
local aArea 	:= BD4->(getArea())
local cCodTab 	:= ""

BD4->( dbSetOrder(2) )//BD4_FILIAL+BD4_CODPRO+BD4_CODTAB+BD4_CODIGO
if BD4->( msSeek( xFilial("BD4") + allTrim(cCodPro) ) )	
	
	while ! BD4->(eof()) .and. BD4->BD4_FILIAL + allTrim(BD4->BD4_CODPRO) == xFilial("BD4") + allTrim(cCodPro)
	
		if BD4->BD4_CDPADP == cCodPad .and. PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dDatAnalise)
			cCodTab := subStr(BD4->BD4_CODTAB,5,3)
			exit
		endIf
		
	BD4->(dbSkip())
	endDo
	
endIf	

BD4->(restArea(aArea))

return(cCodTab)	
