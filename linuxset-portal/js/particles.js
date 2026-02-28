// Dynamic Particle Background - Optimized
class ParticleNetwork {
    constructor() {
        this.canvas = document.createElement('canvas');
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.mouse = { x: null, y: null, radius: 100 };
        this.isActive = true;
        this.frameCount = 0;
        
        this.init();
    }

    init() {
        // Set canvas size
        this.canvas.style.position = 'fixed';
        this.canvas.style.top = '0';
        this.canvas.style.left = '0';
        this.canvas.style.width = '100%';
        this.canvas.style.height = '100%';
        this.canvas.style.zIndex = '-3';
        this.canvas.style.pointerEvents = 'none';
        document.body.appendChild(this.canvas);

        this.resize();
        this.createParticles();
        this.animate();
        this.addEventListeners();
    }

    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    createParticles() {
        // Increase particle count for more visual impact
        const numberOfParticles = Math.min(
            Math.floor((this.canvas.width * this.canvas.height) / 12000),
            120 // Maximum 120 particles
        );
        this.particles = [];

        for (let i = 0; i < numberOfParticles; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                vx: (Math.random() - 0.5) * 0.25,
                vy: (Math.random() - 0.5) * 0.25,
                radius: Math.random() * 2 + 1,
                color: this.getRandomColor(),
                pulsePhase: Math.random() * Math.PI * 2,
                pulseSpeed: 0.01 + Math.random() * 0.015
            });
        }
    }

    getRandomColor() {
        const colors = [
            'rgba(0, 212, 255, 0.8)',
            'rgba(123, 44, 191, 0.8)',
            'rgba(255, 0, 110, 0.8)',
            'rgba(0, 255, 136, 0.8)',
            'rgba(255, 204, 0, 0.8)'
        ];
        return colors[Math.floor(Math.random() * colors.length)];
    }

    drawParticles() {
        this.particles.forEach(particle => {
            // Pulsing effect
            particle.pulsePhase += particle.pulseSpeed;
            const pulseFactor = 1 + Math.sin(particle.pulsePhase) * 0.3;
            const currentRadius = particle.radius * pulseFactor;
            
            // Glow effect
            this.ctx.beginPath();
            this.ctx.arc(particle.x, particle.y, currentRadius * 3, 0, Math.PI * 2);
            const gradient = this.ctx.createRadialGradient(
                particle.x, particle.y, 0,
                particle.x, particle.y, currentRadius * 3
            );
            gradient.addColorStop(0, particle.color.replace('0.8', '0.4'));
            gradient.addColorStop(1, 'transparent');
            this.ctx.fillStyle = gradient;
            this.ctx.fill();
            
            // Core particle
            this.ctx.beginPath();
            this.ctx.arc(particle.x, particle.y, currentRadius, 0, Math.PI * 2);
            this.ctx.fillStyle = particle.color;
            this.ctx.fill();
        });
    }

    drawConnections() {
        // Draw connections every frame for smoother animation
        const maxConnections = 4;
        const connectionDistance = 150;
        
        for (let i = 0; i < this.particles.length; i++) {
            let connections = 0;
            for (let j = i + 1; j < this.particles.length && connections < maxConnections; j++) {
                const dx = this.particles[i].x - this.particles[j].x;
                const dy = this.particles[i].y - this.particles[j].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < connectionDistance) {
                    const opacity = 1 - (distance / connectionDistance);
                    this.ctx.beginPath();
                    this.ctx.strokeStyle = `rgba(0, 212, 255, ${opacity * 0.3})`;
                    this.ctx.lineWidth = 0.8;
                    this.ctx.moveTo(this.particles[i].x, this.particles[i].y);
                    this.ctx.lineTo(this.particles[j].x, this.particles[j].y);
                    this.ctx.stroke();
                    connections++;
                }
            }
        }
    }

    drawMouseConnections() {
        if (!this.mouse.x || !this.mouse.y) return;

        // Enhanced mouse interaction
        let connections = 0;
        const maxMouseConnections = 8;
        const mouseRadius = 180;

        this.particles.forEach(particle => {
            if (connections >= maxMouseConnections) return;
            
            const dx = this.mouse.x - particle.x;
            const dy = this.mouse.y - particle.y;
            const distance = Math.sqrt(dx * dx + dy * dy);

            if (distance < mouseRadius) {
                const opacity = 1 - (distance / mouseRadius);
                
                // Gradient line
                const gradient = this.ctx.createLinearGradient(
                    this.mouse.x, this.mouse.y,
                    particle.x, particle.y
                );
                gradient.addColorStop(0, `rgba(0, 212, 255, ${opacity * 0.8})`);
                gradient.addColorStop(1, particle.color.replace('0.8', `${opacity * 0.5}`));
                
                this.ctx.beginPath();
                this.ctx.strokeStyle = gradient;
                this.ctx.lineWidth = 1.2;
                this.ctx.moveTo(this.mouse.x, this.mouse.y);
                this.ctx.lineTo(particle.x, particle.y);
                this.ctx.stroke();
                connections++;
                
                // Attraction effect - particles move towards mouse (slower)
                const attractionStrength = 0.008;
                particle.vx += (dx / distance) * attractionStrength;
                particle.vy += (dy / distance) * attractionStrength;
            }
        });
    }

    updateParticles() {
        this.particles.forEach(particle => {
            particle.x += particle.vx;
            particle.y += particle.vy;

            // Bounce off edges
            if (particle.x < 0 || particle.x > this.canvas.width) {
                particle.vx *= -1;
            }
            if (particle.y < 0 || particle.y > this.canvas.height) {
                particle.vy *= -1;
            }
        });
    }

    animate() {
        if (!this.isActive) return;

        this.frameCount++;
        
        // Clear canvas
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Draw connections first (behind particles)
        this.drawConnections();
        this.drawMouseConnections();
        
        // Draw particles
        this.drawParticles();
        
        // Update positions
        this.updateParticles();

        // Use requestAnimationFrame with throttle
        requestAnimationFrame(() => this.animate());
    }

    addEventListeners() {
        // Debounce resize handler
        let resizeTimeout;
        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                this.resize();
                this.createParticles();
            }, 250);
        });

        // Throttle mouse move
        let mouseTimeout;
        window.addEventListener('mousemove', (e) => {
            if (mouseTimeout) return;
            mouseTimeout = setTimeout(() => {
                this.mouse.x = e.clientX;
                this.mouse.y = e.clientY;
                mouseTimeout = null;
            }, 50);
        });

        window.addEventListener('mouseout', () => {
            this.mouse.x = null;
            this.mouse.y = null;
        });

        // Pause animation when tab is hidden
        document.addEventListener('visibilitychange', () => {
            this.isActive = document.visibilityState === 'visible';
            if (this.isActive) {
                this.animate();
            }
        });
    }
}

// Initialize particle network when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new ParticleNetwork();
    });
} else {
    new ParticleNetwork();
}
