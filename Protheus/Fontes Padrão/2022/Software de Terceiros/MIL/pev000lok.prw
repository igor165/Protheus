USER Function PEV000LOK()
//
if cOpeMov != "0" // SO VALE PARA COMPRA
	return {.t.,""}
endif
//
If !(cPaisLoc == "BRA")	
	If acols[n,FG_POSVAR("VVG_ESTVEI")] == "1" 
		DBSelectArea("VAZ")
		DBSetOrder(1)
		DBSeek(xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")])
		while xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")] == VAZ->VAZ_FILIAL + VAZ->VAZ_CHASSI
			if VAZ->VAZ_APROVA == "1" .and. Empty(VAZ->VAZ_NUMATE)
				return {.t., Right(VAZ->VAZ_CODIGO,TamSX3("VVF_NUMNFI")[1]) }
			endif	
			DBSkip()
		enddo
		MsgInfo("Nao existe avalicao valida para o veiculo escolhido.","Atencao")
		return {.f., ""}
	endif
endif	
return {.t.,""}

