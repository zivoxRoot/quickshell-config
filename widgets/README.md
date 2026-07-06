# Analog clock

```qml
Canvas {

    width: 250
    height: 250

    onPaint: {

        const ctx = getContext("2d")
        ctx.reset()

        const cx = width / 2
        const cy = height / 2

        const radius = 90
        const amplitude = 3
        const lobes = 12

        ctx.beginPath()

        for (let deg = 0; deg <= 360; deg++) {

            const theta = deg * Math.PI / 180

            const r =
                radius +
                amplitude * Math.cos(theta * lobes)

            const x = cx + r * Math.cos(theta)
            const y = cy + r * Math.sin(theta)

            if (deg === 0)
                ctx.moveTo(x, y)
            else
                ctx.lineTo(x, y)
        }

        ctx.closePath()

        ctx.fillStyle = "#3B82F6"
        ctx.fill()
    }
}

```
