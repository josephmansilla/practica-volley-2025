class Equipo {
  const property jugadores = #{}
  method promedioAltura(criterio){
    const jugadoresRestantes = jugadores.filter{criterio}
    return jugadoresRestantes.sum{ j => j.altura() } / jugadoresRestantes
  }
  method alturaPromedio() = jugadores.map{jugador => jugador.altura()}.sum() / jugadores.length()
  method rotarEquipo() {
    jugadores.forEach{ jugador => jugador.cambiarPosicion() }
  }
}

const alturaMinimaRemate = 1.60 // En metros

class Jugador {
  const property altura
  var property posicionActual

  method puedeRematar() = self.cumpleAlturaMinima() && self.validarRemate()
  method cumpleAlturaMinima() = altura >= alturaMinimaRemate
  method validarRemate() = posicionActual.puedeRematar() 
  method cambiarPosicion() {
    posicionActual = posicionActual.siguientePosicion()
  }
}


class Posicion {
  const property posicion
  method puedeRematar()
  method siguientePosicion()
}

class Delantero inherits Posicion { // 2,3,4
  override method puedeRematar() = true
}
object delanteroIzquierdo inherits Delantero(posicion = 4) {
  override method siguientePosicion() = delanteroCentro
}
object delanteroCentro inherits Delantero(posicion = 3) {
  override method siguientePosicion() = delanteroDerecho
}
object delanteroDerecho inherits Delantero(posicion = 2) {
  override method siguientePosicion() = zagueroDerecho
}

class Zaguero inherits Posicion { // 1,6,5
  override method puedeRematar() = false
}
object zagueroIzquierdo inherits Zaguero(posicion = 5) { 
  override method siguientePosicion() = delanteroIzquierdo
}
object zagueroCentral inherits Zaguero(posicion = 6) {
  override method siguientePosicion() = zagueroIzquierdo
}
object zagueroDerecho inherits Zaguero(posicion = 1) {
  override method siguientePosicion() = zagueroCentral
}

class Partido {
    var property fase
    const property puntaje = #{}
    method equipoConVentaja() = fase.equipoConVentaja(self)
    method anoto(equipo) {
        fase.anoto(equipo, self)
    }
    
}

class PuntosPorEquipo {
    const property equipo
    var property puntaje

    method sumarPunto() {
        puntaje += 1
    }
}

class FaseJuego {
    method equipoConVentajaSiHayEmpate()
    method anoto(equipo, partido)
    method equipoConVentaja(partido)
}

class EnJuego inherits FaseJuego {
    var property equipoQueEstaSacando
    override method equipoConVentajaSiHayEmpate() = equipoQueEstaSacando
    override method anoto(equipo, partido) {
        self.sumarPunto(equipo, partido)
    }
    override method equipoConVentaja(partido) {

        const equipoA = partido.puntaje().head()
        const equipoB = partido.puntaje().last()
        const criterio = {j => j.puedeRematar()}

        if(equipoA.puntaje() > equipoB.puntaje() ||
        equipoA.alturaPromedio(criterio) > equipoB.alturaPromedio(criterio)){
            return equipoA.equipo()
        }
        if(equipoA.puntaje() < equipoB.puntaje() ||
        equipoA.alturaPromedio(criterio) < equipoB.alturaPromedio(criterio)){
            return equipoB.equipo()
        }
        return equipoQueEstaSacando
    }
    method sumarPunto(equipo, partido) {
        partido.puntaje().find { equipoPuntaje => equipoPuntaje.equipo() == equipo}.sumarPunto()
    }
}

class Terminado inherits FaseJuego {
    override method equipoConVentajaSiHayEmpate() {
        throw new PartidoTerminadoException()
    }
    override method anoto(equipo, partido) {
        throw new PartidoTerminadoException()
    }
    override method equipoConVentaja(partido) {
        partido.puntaje().max{ equipoPuntaje => equipoPuntaje.puntaje() }
    }
}


class PorElSaque inherits FaseJuego {
    override method equipoConVentajaSiHayEmpate() {
        throw new JueganPorElSaqueException()
    }
    override method anoto(equipo, partido) {
        partido.fase(new EnJuego(equipoQueEstaSacando = equipo))
    }
    override method equipoConVentaja(partido) {
        throw new JueganPorElSaqueException()
    }
}


class JueganPorElSaqueException inherits Exception {}
class PartidoTerminadoException inherits Exception {}